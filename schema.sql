-- Table for manufacturers & recipients
CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT UNIQUE NOT NULL,
        email TEXT UNIQUE NOT NULL,
        password TEXT NOT NULL,
        role TEXT NOT NULL CHECK (role IN ('manufacturer', 'recipient')),
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        product_code TEXT UNIQUE NOT NULL,
        manufacturer_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        description TEXT,
        max_temperature REAL,
        min_temperature REAL,
        max_humidity REAL,
        min_humidity REAL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (manufacturer_id) REFERENCES users(id)
);

CREATE TABLE shipments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shipment_code TEXT UNIQUE NOT NULL,
        manufacturer_id INTEGER NOT NULL,
        recipient_id INTEGER,
        recipient_name TEXT NOT NULL,
        recipient_address TEXT NOT NULL,
        recipient_phone TEXT NOT NULL,
        shipping_date DATE NOT NULL,
        delivery_date DATE,
        additional_info TEXT,
        status TEXT NOT NULL DEFAULT 'prepared' CHECK (status IN ('prepared', 'shipped', 'delivered')),
        constraints_violated BOOLEAN DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (manufacturer_id) REFERENCES users(id),
        FOREIGN KEY (recipient_id) REFERENCES users(id)
);

CREATE TABLE shipment_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shipment_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        quantity INTEGER NOT NULL,
        constraints_violated BOOLEAN DEFAULT 0,
        FOREIGN KEY (shipment_id) REFERENCES shipments(id),
        FOREIGN KEY (product_id) REFERENCES products(id)
);

CREATE TABLE nfc_tags (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tag_id TEXT UNIQUE NOT NULL,
        product_id INTEGER NOT NULL,
        shipment_item_id INTEGER NOT NULL,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (product_id) REFERENCES products(id),
        FOREIGN KEY (shipment_item_id) REFERENCES shipment_items(id)
);

CREATE TABLE temperature_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        shipment_id INTEGER NOT NULL,
        temperature REAL NOT NULL,
        humidity REAL NOT NULL,
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (shipment_id) REFERENCES shipments(id)
);

CREATE TABLE notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        shipment_id INTEGER NOT NULL,
        message TEXT NOT NULL,
        read BOOLEAN DEFAULT 0,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (user_id) REFERENCES users(id),
        FOREIGN KEY (shipment_id) REFERENCES shipments(id)
);