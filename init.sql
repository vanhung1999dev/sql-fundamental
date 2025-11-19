-- USERS TABLE
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT UNIQUE NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- PRODUCTS
CREATE TABLE products (
    id SERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    price NUMERIC(10,2) NOT NULL,
    category TEXT,
    created_at TIMESTAMP DEFAULT NOW()
);

-- ORDERS
CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    total NUMERIC(10,2),
    created_at TIMESTAMP DEFAULT NOW()
);

-- ORDER ITEMS (Many-to-many)
CREATE TABLE order_items (
    id SERIAL PRIMARY KEY,
    order_id INT REFERENCES orders(id),
    product_id INT REFERENCES products(id),
    quantity INT NOT NULL
);

-- USER ROLES (Many-to-Many)
CREATE TABLE roles (
    id SERIAL PRIMARY KEY,
    name TEXT UNIQUE NOT NULL
);

CREATE TABLE user_roles (
    user_id INT REFERENCES users(id),
    role_id INT REFERENCES roles(id),
    PRIMARY KEY (user_id, role_id)
);

-- JSONB EVENTS (for advanced queries)
CREATE TABLE events (
    id SERIAL PRIMARY KEY,
    user_id INT REFERENCES users(id),
    event_data JSONB NOT NULL,
    created_at TIMESTAMP DEFAULT NOW()
);

-- PARTITIONED LOG TABLE (for Data Eng)
CREATE TABLE logs (
    id SERIAL NOT NULL,
    ts TIMESTAMP NOT NULL,
    level TEXT,
    message TEXT,
    PRIMARY KEY (id, ts)
) PARTITION BY RANGE (ts);

-- PARTITIONS
CREATE TABLE logs_2024 PARTITION OF logs
FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- INDEXES
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_orders_user_id ON orders(user_id);
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_products_category ON products(category);
CREATE INDEX idx_events_json ON events USING GIN (event_data);
CREATE INDEX idx_logs_ts ON logs(ts);

-- SAMPLE DATA
INSERT INTO users (name, email) VALUES
('Alice', 'alice@mail.com'),
('Bob', 'bob@mail.com'),
('Charlie', 'charlie@mail.com');

INSERT INTO roles (name) VALUES ('admin'), ('manager'), ('user');

INSERT INTO user_roles VALUES
(1, 1),
(2, 3),
(3, 3);

INSERT INTO products (name, price, category) VALUES
('Laptop', 1200, 'electronics'),
('Keyboard', 50, 'electronics'),
('Coffee', 5, 'grocery');

INSERT INTO orders (user_id, total) VALUES
(1, 1300),
(2, 55);

INSERT INTO order_items (order_id, product_id, quantity) VALUES
(1, 1, 1),
(1, 2, 2),
(2, 2, 1),
(2, 3, 5);

INSERT INTO events (user_id, event_data) VALUES
(1, '{"action": "login", "device": "mobile"}'),
(2, '{"action": "purchase", "value": 55}');
