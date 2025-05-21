import sqlite3
import os
from sqlite3 import Connection
import uuid
from datetime import datetime

DATABASE = "reksti.db"

def get_db() -> Connection:
        conn = sqlite3.connect(DATABASE)
        conn.row_factory = sqlite3.Row
        return conn

def init_db():
        conn = sqlite3.connect(DATABASE)
        cursor = conn.cursor()
        
        # Check if table exists
        cursor.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='users';")
        if cursor.fetchone() is None:
                with open("schema.sql", "r") as f:
                        conn.executescript(f.read())
                conn.commit()
        conn.close()