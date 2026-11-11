-- Run only inside the dedicated sql_challenge database. No destructive reset.
CREATE SCHEMA IF NOT EXISTS lab;
SET search_path TO lab;
CREATE TABLE customers (
 customer_id bigint PRIMARY KEY, email text NOT NULL UNIQUE, country text,
 source_updated_at timestamp NOT NULL, source_version integer NOT NULL,
 source_event_id bigint NOT NULL
);
CREATE TABLE categories (category_id bigint PRIMARY KEY, category_name text NOT NULL UNIQUE);
CREATE TABLE products (
 product_id bigint PRIMARY KEY, category_id bigint NOT NULL REFERENCES categories,
 product_name text NOT NULL, list_price numeric(12,2) NOT NULL CHECK (list_price > 0)
);
CREATE TABLE orders (
 order_id bigint PRIMARY KEY, customer_id bigint NOT NULL REFERENCES customers,
 ordered_at timestamp NOT NULL,
 status text NOT NULL CHECK (status IN ('completed','cancelled','pending'))
);
CREATE TABLE order_items (
 order_id bigint NOT NULL REFERENCES orders, line_no integer NOT NULL,
 product_id bigint NOT NULL REFERENCES products, quantity integer NOT NULL CHECK (quantity > 0),
 unit_price numeric(12,2) NOT NULL CHECK (unit_price > 0),
 discount_amount numeric(12,2) NOT NULL DEFAULT 0,
 PRIMARY KEY (order_id,line_no),
 CHECK (discount_amount >= 0 AND discount_amount <= quantity * unit_price)
);
CREATE TABLE payments (
 payment_id bigint PRIMARY KEY, order_id bigint NOT NULL REFERENCES orders,
 paid_at timestamp, status text NOT NULL CHECK (status IN ('succeeded','failed','pending')),
 amount numeric(12,2) NOT NULL CHECK (amount >= 0)
);
-- Full snapshots, not patches; NULL country explicitly clears the attribute.
CREATE TABLE customer_updates (
 ingestion_id bigint PRIMARY KEY, batch_id integer NOT NULL, customer_id bigint NOT NULL,
 email text NOT NULL, country text, source_updated_at timestamp NOT NULL,
 source_version integer NOT NULL, source_event_id bigint NOT NULL, received_at timestamp NOT NULL
);
