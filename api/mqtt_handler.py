import json
import paho.mqtt.client as mqqt
from database import get_db

# Store temperatures organized by shipment_id
latest_temp_data = {}
client = mqqt.Client(client_id="reksti-gres", callback_api_version=mqqt.CallbackAPIVersion.VERSION2)
        
def on_message(client, userdata, msg):
        global latest_temp_data
        payload = msg.payload.decode("utf-8")
        try:
                data = json.loads(payload)
                
                if "shipment_id" in data:
                        shipment_id = data['shipment_id']
                        # Update in-memory cache
                        latest_temp_data[shipment_id] = data
                        temperature = data.get('temperature', 0)
                        humidity = data.get('humidity', 0)
                        
                        conn = get_db()
                        cursor = conn.cursor()
                        
                        # Check if this shipment already has a temperature log
                        cursor.execute("SELECT id FROM temperature_logs WHERE shipment_id = ? ORDER BY timestamp DESC LIMIT 1", 
                                      (shipment_id,))
                        existing_log = cursor.fetchone()
                        
                        if existing_log:
                                # Update existing record
                                cursor.execute("""
                                        UPDATE temperature_logs 
                                        SET temperature = ?, humidity = ?, timestamp = CURRENT_TIMESTAMP 
                                        WHERE id = ?
                                """, (temperature, humidity, existing_log['id']))
                                print(f"Updated temperature log for shipment {shipment_id}: {temperature}°C, {humidity}% humidity")
                        else:
                                # Insert new record
                                cursor.execute("""
                                        INSERT INTO temperature_logs (shipment_id, temperature, humidity) 
                                        VALUES (?, ?, ?)
                                """, (shipment_id, temperature, humidity))
                                print(f"Created new temperature log for shipment {shipment_id}: {temperature}°C, {humidity}% humidity")
                        
                        # Check and update constraint violations
                        cursor.execute("""
                                UPDATE shipments
                                SET constraints_violated = 1
                                WHERE id = ? AND (
                                        EXISTS (
                                                SELECT 1
                                                FROM shipment_items si
                                                JOIN products p ON si.product_id = p.id
                                                WHERE si.shipment_id = shipments.id
                                                AND (
                                                        ? > p.max_temperature OR ? < p.min_temperature OR
                                                        ? > p.max_humidity OR ? < p.min_humidity
                                                )
                                        )
                                )
                        """, (
                                shipment_id, 
                                temperature, temperature,
                                humidity, humidity
                        ))
                        
                        conn.commit()
                        conn.close()
                else:
                        # For messages without shipment_id, store as general data
                        latest_temp_data["general"] = data
                        
        except json.JSONDecodeError:
                print("Invalid JSON received:", payload)
                
def setup_mqtt():
        client.connect("broker.emqx.io")
        client.loop_start()
        client.subscribe("/REKSTI/data")
        client.on_message = on_message
        print("MQTT connected and listening on /REKSTI/data")
        
def publish_mqqt_data(topic: str, payload: dict):
        client.publish(topic=topic, payload=json.dumps(payload))
        
def get_temp(shipment_id=None, limit=1):
        """
        Get temperature data from the database
        
        Args:
                shipment_id: Optional ID to filter by specific shipment
                limit: Number of records to return (default 1 for latest only)
                
        Returns:
                Dictionary or list of temperature readings
        """
        conn = get_db()
        cursor = conn.cursor()
        
        try:
                if shipment_id is not None:
                # Get readings for specific shipment
                        cursor.execute("""
                                SELECT tl.*, s.shipment_code
                                FROM temperature_logs tl
                                JOIN shipments s ON tl.shipment_id = s.id
                                WHERE tl.shipment_id = ?
                                ORDER BY tl.timestamp DESC
                                LIMIT ?
                        """, (shipment_id, limit))
                else:
                # Get latest reading for each shipment
                        cursor.execute("""
                                SELECT tl.*, s.shipment_code
                                FROM temperature_logs tl
                                JOIN (
                                SELECT shipment_id, MAX(timestamp) as max_ts
                                FROM temperature_logs
                                GROUP BY shipment_id
                                ) latest ON tl.shipment_id = latest.shipment_id AND tl.timestamp = latest.max_ts
                                JOIN shipments s ON tl.shipment_id = s.id
                        """)
                        
                rows = cursor.fetchall()
                
                if not rows:
                # If no database records, fall back to in-memory data
                        return latest_temp_data.get(str(shipment_id), {}) if shipment_id else latest_temp_data
                
                if shipment_id is not None and limit == 1:
                # Return single reading for specific shipment
                        if rows:
                                row = rows[0]
                                return {
                                "shipment_id": row["shipment_id"],
                                "shipment_code": row["shipment_code"],
                                "temperature": row["temperature"],
                                "humidity": row["humidity"],
                                "timestamp": row["timestamp"]
                                }
                        return {}
                else:
                # Return list of readings
                        results = []
                        for row in rows:
                                results.append({
                                "shipment_id": row["shipment_id"],
                                "shipment_code": row["shipment_code"],
                                "temperature": row["temperature"],
                                "humidity": row["humidity"],
                                "timestamp": row["timestamp"]
                                })
                        return results
        finally:
                conn.close()