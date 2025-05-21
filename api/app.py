from fastapi import FastAPI, Depends, HTTPException, status
from fastapi.security import OAuth2PasswordRequestForm
from datetime import timedelta
import uuid
import sqlite3


from database import get_db, init_db
from models import *
from auth import *
from mqtt_handler import *

app = FastAPI()

@app.on_event("startup")
def startup_event():
        init_db()
        setup_mqtt()
        
@app.post("/api/register", response_model=UserResponse)
def register(user: UserCreate):
        conn = get_db()
        cursor = conn.cursor()
        
        cursor.execute("SELECT id FROM users WHERE username = ? OR email = ?",
                       (user.username, user.email))
        if cursor.fetchone():
                conn.close()
                raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail="Username or email already registered")
        
        hashed_password = get_hashed_password(user.password)
        cursor.execute("INSERT INTO users (username, email, password, role) VALUES (?, ?, ?, ?)", 
                       (user.username, user.email, hashed_password, user.role))
        conn.commit()
        
        cursor.execute("SELECT id, username, email, role, created_at FROM users WHERE id = last_insert_rowid()")
        new_user = cursor.fetchone()
        conn.close()
        
        return dict(new_user)

@app.post("/api/login", response_model=Token)
def login(form_data: OAuth2PasswordRequestForm = Depends()):
        conn = get_db()
        cursor = conn.cursor()
        
        cursor.execute("SELECT * FROM users WHERE username = ?", (form_data.username,))
        user = cursor.fetchone()
        conn.close()
        
        if not user or not verify_password(form_data.password, user["password"]):
                raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Incorrent username or password")
        
        access_token_expires = timedelta(seconds=60 * 60 * 24)
        access_token = create_token(data={"sub": user["username"], "user_id": user["id"], "role": user["role"]},
                                    expires_delta=access_token_expires)
        
        return {"access_token": access_token, "token_type": "bearer"}

# For manufacturers only
@app.post("/api/products", response_model=ProductResponse)
def create_product(product: ProductCreate, current_user = Depends(get_current_manufacturer)):
        conn = get_db()
        cursor = conn.cursor()
        
        product_code = f"PROD-{uuid.uuid4().hex[:8].upper}"
        
        cursor.execute("""
                INSERT INTO products (product_code, manufacturer_id, name, description, 
                max_temperature, min_temperature, max_humidity, min_humidity)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)        
        """, (
                product_code, current_user.user_id, product.name, product.description,
                product.max_temperature, product.min_temperature,
                product.max_humidity, product.min_humidity
        ))
        conn.commit()
        
        cursor.execute("SELECT * FROM products WHERE id = last_insert_rowid()")
        new_product = cursor.fetchone()
        conn.close()
        
        return dict(new_product)

@app.get("/api/products", response_model=list[ProductResponse])
def get_products(current_user = Depends(get_current_manufacturer)):
        conn = get_db()
        cursor = conn.cursor()
        
        cursor.execute("SELECT * FROM products WHERE manufacturer_id = ?", (current_user.user_id,))
        products = cursor.fetchall()
        conn.close()
        
        return [dict(product) for product in products]

@app.post("/api/shipments", response_model=ShipmentResponse)
def create_shipment(shipment: ShipmentCreate, current_user = Depends(get_current_manufacturer)):
        conn = get_db()
        cursor = conn.cursor()
        
        shipment_code = f"SHIP-{uuid.uuid4().hex[:8].upper()}"
        
        cursor.execute("SELECT id FROM users WHERE username = ? AND role = 'recipient'", 
                       (shipment.recipient_name,))
        recipient = cursor.fetchone()
        recipient_id = recipient['id'] if recipient else None
        
        cursor.execute("""
                INSERT INTO shipments (shipment_code, manufacturer_id, recipient_id, recipient_name, recipient_address, 
                recipient_phone, shipping_date, additional_info)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
        """, (
                shipment_code, current_user.user_id, recipient_id, shipment.recipient_name,
                shipment.recipient_address, shipment.recipient_phone,
                shipment.shipping_date, shipment.additional_info
        ))
        
        shipment_id = cursor.lastrowid
        
        for item in shipment.items:
                cursor.execute("SELECT id FROM products WHERE product_code = ?", (item.product_code,))
                product_row = cursor.fetchone()
                if not product_row:
                        conn.rollback()
                        conn.close()
                        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=f"Product with code {item.product_code} not found")
                
                product_id = product_row['id']
                
                cursor.execute("INSERT INTO shipment_items (shipment_id, product_id, quantity) VALUES (?, ?, ?)", (shipment_id, product_id, item.quantity))
        
        conn.commit()
        publish_mqqt_data("/REKSTI/shipment_code", {"shipment_id": shipment_id})
        result = get_shipment_by_code(shipment_code, conn)
        conn.close()
        
        return result

def get_shipment_by_code(shipment_code, conn=None):
        close_conn = False
        if conn is None:
                conn = get_db()
                close_conn = True
        
        cursor = conn.cursor()
        cursor.execute("SELECT * FROM shipments WHERE shipment_code = ?", (shipment_code,))
        shipment = cursor.fetchone()
        
        if not shipment:
                if close_conn:
                        conn.close()
                raise HTTPException(
                        status_code=status.HTTP_404_NOT_FOUND,
                        detail=f"Shipment with code {shipment_code} not found"
                        )
        
        cursor.execute("""
                SELECT si.id, si.product_id, p.name as product_name, si.quantity, si.constraints_violated
                FROM shipment_items si
                JOIN products p ON si.product_id = p.id
                WHERE si.shipment_id = ?
        """, (shipment['id'],))
        
        items = []
        for item in cursor.fetchall():
                items.append({
                "product_id": item["product_id"],
                "product_name": item["product_name"],
                "quantity": item["quantity"],
                "constraints_violated": bool(item["constraints_violated"])
                })
        
        result = dict(shipment)
        result["items"] = items
        
        if close_conn:
                conn.close()
        
        return result

@app.get("/api/shipments/recent", response_model=list[ShipmentResponse])
def get_recent_shipments(current_user = Depends(get_current_manufacturer)):
        conn = get_db()
        cursor = conn.cursor()
        
        cursor.execute("""
                SELECT shipment_code FROM shipments 
                WHERE manufacturer_id = ? AND (status != 'delivered' OR created_at >= datetime('now', '-30 day'))
                ORDER BY created_at DESC LIMIT 10
        """, (current_user.user_id,))
        
        shipment_codes = [row['shipment_code'] for row in cursor.fetchall()]
        shipments = []
        
        for code in shipment_codes:
                shipments.append(get_shipment_by_code(code, conn))
        
        conn.close()
        return shipments

@app.get("/api/shipments", response_model=list[ShipmentResponse])
def get_all_shipments(current_user = Depends(get_current_manufacturer)):
        conn = get_db()
        cursor = conn.cursor()
        
        cursor.execute("""
                SELECT shipment_code FROM shipments 
                WHERE manufacturer_id = ?
                ORDER BY created_at DESC
        """, (current_user.user_id,))
        
        shipment_codes = [row['shipment_code'] for row in cursor.fetchall()]
        shipments = []
        
        for code in shipment_codes:
                try:
                        shipments.append(get_shipment_by_code(code, conn))
                except HTTPException:
                        continue
        
        conn.close()
        return shipments

# For both usrers
@app.get("/api/shipments/{shipment_code}", response_model=ShipmentResponse)
def get_shipment(shipment_code: str, current_user = Depends(get_current_user)):
        conn = get_db()
        cursor = conn.cursor()
        
        cursor.execute("SELECT id FROM shipments WHERE shipment_code = ? AND (manufacturer_id = ? OR recipient_id = ?)", 
                       (shipment_code, current_user.user_id, current_user.user_id))
        
        if not cursor.fetchone():
                conn.close()
                raise HTTPException(status_code=status.HTTP_403_FORBIDDEN, detail="Not authorized")
        
        result = get_shipment_by_code(shipment_code, conn)
        conn.close()
        return result

@app.post("/api/verify-nfc", response_model=NFCTagResponse)
def verify_nfc_tag(tag_data: NFCTagVerification, current_user = Depends(get_current_user)):
        conn = get_db()
        cursor = conn.cursor()
        
        cursor.execute("""
                SELECT nt.*, p.name as product_name, u.username as manufacturer_name, s.shipment_code
                FROM nfc_tags nt
                JOIN products p ON nt.product_id = p.id
                JOIN users u ON p.manufacturer_id = u.id
                JOIN shipment_items si ON nt.shipment_item_id = si.id
                JOIN shipments s ON si.shipment_id = s.id
                WHERE nt.tag_id = ?
        """, (tag_data.tag_id,))
        
        tag_info = cursor.fetchone()
        conn.close()
        
        if not tag_info:
                return {
                        "is_authentic": False,
                        "product_name": None,
                        "manufacturer": None,
                        "shipment_code": None
                }
        
        return {
                "is_authentic": True,
                "product_name": tag_info["product_name"],
                "manufacturer": tag_info["manufacturer_name"],
                "shipment_code": tag_info["shipment_code"]
        }
        
# For recipients only
@app.get("/api/orders", response_model=list[ShipmentResponse])
def get_order_history(current_user = Depends(get_current_recipient)):
        conn = get_db()
        cursor = conn.cursor()
        
        cursor.execute("""
                SELECT shipment_code FROM shipments 
                WHERE recipient_id = ?
                ORDER BY shipping_date DESC
        """, (current_user.user_id,))
        
        shipment_codes = [row['shipment_code'] for row in cursor.fetchall()]
        orders = []
        
        for code in shipment_codes:
                try:
                        orders.append(get_shipment_by_code(code, conn))
                except HTTPException:
                        continue
                
        conn.close()
        return orders

@app.get("/api/orders/{date}", response_model=list[ShipmentResponse])
def get_orders_by_date(date: str, current_user = Depends(get_current_recipient)):
        conn = get_db()
        cursor = conn.cursor()
        
        cursor.execute("""
                SELECT shipment_code FROM shipments 
                WHERE recipient_id = ? AND date(shipping_date) = date(?)
                ORDER BY shipping_date DESC
        """, (current_user.user_id, date))
        
        shipment_codes = [row['shipment_code'] for row in cursor.fetchall()]
        orders = []
        
        for code in shipment_codes:
                try:
                        orders.append(get_shipment_by_code(code, conn))
                except HTTPException:
                        continue
        
        conn.close()
        return orders

@app.get("/api/notifications", response_model=list[NotificationResponse])
def get_notifications(current_user = Depends(get_current_user)):
        conn = get_db()
        cursor = conn.cursor()
        
        cursor.execute("""
                SELECT n.*, s.shipment_code
                FROM notifications n
                JOIN shipments s ON n.shipment_id = s.id
                WHERE n.user_id = ?
                ORDER BY n.created_at DESC
        """, (current_user.user_id,))
        
        notifications = [dict(row) for row in cursor.fetchall()]
        conn.close()
        
        return notifications

@app.get("/api/temperature/{shipment_id}")
def get_temperature(shipment_id: int):
        temp = get_temp(shipment_id)
        if temp:
                return temp
        return {"error": "No temperature data received yet"}