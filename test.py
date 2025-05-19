#!/usr/bin/env python3
# test_api.py - Test script for Pharmaceutical Distribution API

import requests
import json
import time
from datetime import date, timedelta

# Configuration
BASE_URL = "http://localhost:8000"
MANUFACTURER_CREDS = {"username": "test_manufacturer", "email": "manufacturer@test.com", "password": "test123", "role": "manufacturer"}
RECIPIENT_CREDS = {"username": "test_recipient", "email": "recipient@test.com", "password": "test123", "role": "recipient"}
TOKENS = {}
CREATED_DATA = {"product_codes": [], "shipment_codes": []}

def print_response(response, message=""):
    """Print formatted response with optional message"""
    print(f"\n{'='*80}")
    print(f"TEST: {message}")
    print(f"STATUS: {response.status_code}")
    try:
        print(json.dumps(response.json(), indent=2))
    except:
        print(response.text)
    print(f"{'='*80}\n")
    return response.json() if response.status_code < 400 else None

def register_user(user_data):
    """Register a new user"""
    response = requests.post(
        f"{BASE_URL}/api/register",
        json=user_data
    )
    return print_response(response, f"Register {user_data['role']}")

def login_user(username, password):
    """Login and get access token"""
    response = requests.post(
        f"{BASE_URL}/api/login",
        data={"username": username, "password": password},
        headers={"Content-Type": "application/x-www-form-urlencoded"}
    )
    result = print_response(response, f"Login as {username}")
    if result and "access_token" in result:
        return result["access_token"]
    return None

def create_product(token, product_data):
    """Create a product (manufacturer only)"""
    response = requests.post(
        f"{BASE_URL}/api/products",
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
        json=product_data
    )
    result = print_response(response, "Create product")
    if result and "product_code" in result:
        CREATED_DATA["product_codes"].append(result["product_code"])
    return result

def get_products(token):
    """Get all products (manufacturer only)"""
    response = requests.get(
        f"{BASE_URL}/api/products",
        headers={"Authorization": f"Bearer {token}"}
    )
    return print_response(response, "Get all products")

def create_shipment(token, shipment_data):
    """Create a shipment (manufacturer only)"""
    response = requests.post(
        f"{BASE_URL}/api/shipments",
        headers={"Authorization": f"Bearer {token}", "Content-Type": "application/json"},
        json=shipment_data
    )
    result = print_response(response, "Create shipment")
    if result and "shipment_code" in result:
        CREATED_DATA["shipment_codes"].append(result["shipment_code"])
    return result

def get_recent_shipments(token):
    """Get recent shipments (manufacturer only)"""
    response = requests.get(
        f"{BASE_URL}/api/shipments/recent",
        headers={"Authorization": f"Bearer {token}"}
    )
    return print_response(response, "Get recent shipments")

def get_all_shipments(token):
    """Get all shipments (manufacturer only)"""
    response = requests.get(
        f"{BASE_URL}/api/shipments",
        headers={"Authorization": f"Bearer {token}"}
    )
    return print_response(response, "Get all shipments")

def get_shipment_details(token, shipment_code):
    """Get details for a specific shipment"""
    response = requests.get(
        f"{BASE_URL}/api/shipments/{shipment_code}",
        headers={"Authorization": f"Bearer {token}"}
    )
    return print_response(response, f"Get shipment details for {shipment_code}")

def get_orders(token):
    """Get orders (recipient only)"""
    response = requests.get(
        f"{BASE_URL}/api/orders",
        headers={"Authorization": f"Bearer {token}"}
    )
    return print_response(response, "Get all orders")

def get_orders_by_date(token, date_str):
    """Get orders by date (recipient only)"""
    response = requests.get(
        f"{BASE_URL}/api/orders/{date_str}",
        headers={"Authorization": f"Bearer {token}"}
    )
    return print_response(response, f"Get orders for date {date_str}")

def get_notifications(token):
    """Get notifications"""
    response = requests.get(
        f"{BASE_URL}/api/notifications",
        headers={"Authorization": f"Bearer {token}"}
    )
    return print_response(response, "Get notifications")

def get_temperature():
    """Get temperature data"""
    response = requests.get(f"{BASE_URL}/api/temperature")
    return print_response(response, "Get temperature data")

def run_all_tests():
    """Run a complete test sequence"""
    print("\n🚀 Starting API Tests...\n")

    # 1. Register users
    register_user(MANUFACTURER_CREDS)
    register_user(RECIPIENT_CREDS)
    
    # 2. Login and get tokens
    TOKENS["manufacturer"] = login_user(MANUFACTURER_CREDS["username"], MANUFACTURER_CREDS["password"])
    TOKENS["recipient"] = login_user(RECIPIENT_CREDS["username"], RECIPIENT_CREDS["password"])
    
    if not TOKENS["manufacturer"] or not TOKENS["recipient"]:
        print("❌ Authentication failed, cannot continue tests")
        return
    
    # 3. Create products as manufacturer
    product = create_product(TOKENS["manufacturer"], {
        "name": "Test Antibiotic",
        "description": "For testing purposes",
        "max_temperature": 30.0,
        "min_temperature": 2.0,
        "max_humidity": 60.0,
        "min_humidity": 20.0
    })
    
    # 4. Get all products
    get_products(TOKENS["manufacturer"])
    
    # Check if we have product codes for shipment creation
    if not CREATED_DATA["product_codes"]:
        print("❌ No products created, cannot test shipment creation")
        return
    
    # 5. Create a shipment
    today = date.today()
    tomorrow = today + timedelta(days=1)
    
    # IMPORTANT: Using the recipient's actual username ensures that the shipment 
    # is properly associated with the recipient user account in the database.
    # The app looks up the recipient_id by username during shipment creation.
    shipment = create_shipment(TOKENS["manufacturer"], {
        "shipping_date": str(tomorrow),
        "recipient_name": RECIPIENT_CREDS["username"],  # Using actual username instead of "Hospital A"
        "recipient_address": "123 Medical Drive",
        "recipient_phone": "123-456-7890",
        "additional_info": "Handle with care",
        "items": [
            {
                "product_code": CREATED_DATA["product_codes"][0],
                "quantity": 10
            }
        ]
    })
    
    # 6. Get recent and all shipments
    get_recent_shipments(TOKENS["manufacturer"])
    get_all_shipments(TOKENS["manufacturer"])
    
    # 7. Get specific shipment details
    if CREATED_DATA["shipment_codes"]:
        get_shipment_details(TOKENS["manufacturer"], CREATED_DATA["shipment_codes"][0])
    
    # 8. Now orders should appear for the recipient since we used their username
    get_orders(TOKENS["recipient"])
    get_orders_by_date(TOKENS["recipient"], str(tomorrow))
    
    # 9. Get notifications
    get_notifications(TOKENS["manufacturer"])
    get_notifications(TOKENS["recipient"])
    
    # 10. Get temperature data
    get_temperature()
    
    print("\n✅ Testing completed!")

if __name__ == "__main__":
    run_all_tests()