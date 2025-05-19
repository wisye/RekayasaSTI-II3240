import json
from paho.mqtt.client import Client
from database import get_db

latest_temp_data = {}

def on_connect(client, userdata, flags, rc):
        print("Connected with result code = ", rc)
        client.subscribe("/REKSTI/temp")
        
def on_message(client, userdata, msg):
        global latest_temp_data
        payload = msg.payload.decode()
        try:
                data = json.loads(payload)
                latest_temp_data = data
                
                if "shipment_id" in data:
                        conn = get_db()
                        cursor = conn.cursor()
                        cursor.execute(
                                "INSERT INTO temperature_logs (shipment_id, temperature, humidity) VALUES (?, ?, ?)",
                                (data['shipment_id'], data.get('temperature', 0), data.get('humidity', 0))
                        )
                        
                        cursor.execute("""
                                UPDATE shipments s
                                SET constraints_violated = 1
                                WHERE s.id = ? AND (
                                        EXISTS (
                                                SELECT 1
                                                FROM shipment_items si
                                                JOIN products p ON si.product_id = p.id
                                                WHERE si.shipment_id = s.id
                                                AND (
                                                        ? > p.max_temperature OR ? < p.min_temperature OR
                                                        ? > p.max_humidity OR ? < p.min_humidity
                                                )
                                        )
                                )
                        """, (
                                data['shipment_id'], 
                                data.get('temperature', 0), data.get('temperature', 0),
                                data.get('humidity', 0), data.get('humidity', 0)
                        ))
                        
                        conn.commit()
                        conn.close()
        except json.JSONDecodeError:
                print("Invalid JSON received: ", payload)
                
def setup_mqtt():
        client = Client(client_id="fastapi-mqtt-client")
        client.on_connect = on_connect
        client.on_message = on_message
        client.connect("broker.emqx.io", 1883, 60)
        client.loop_start()