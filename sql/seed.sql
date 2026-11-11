SET search_path TO lab;
-- Seed 20261111: integer arithmetic only, no random(), wall clock or locale dependencies.
INSERT INTO customers
SELECT i, 'customer' || i || '@example.test', CASE WHEN i%9=0 THEN NULL WHEN i%2=0 THEN 'ES' ELSE 'FR' END,
 timestamp '2024-01-01', 1, i FROM generate_series(1,2000) AS g(i);
INSERT INTO categories SELECT i, 'Category ' || i FROM generate_series(1,10) AS g(i);
INSERT INTO products SELECT i, 1+(i-1)%10, 'Product ' || i, (10+i%90)::numeric
FROM generate_series(1,500) AS g(i);
INSERT INTO orders
SELECT i, 1+(i*37)%1800,
 timestamp '2024-01-01' + ((i*17)%366)*interval '1 day' + (i%4)*interval '1 hour',
 CASE WHEN i%11=0 THEN 'cancelled' WHEN i%13=0 THEN 'pending' ELSE 'completed' END
FROM generate_series(1,15000) AS g(i);
INSERT INTO order_items
SELECT i, j, 1+(i*31+j*7)%480, 1+(i+j)%3, (10+(i*31+j*7)%90)::numeric,
 CASE WHEN (i+j)%5=0 THEN 5 ELSE 0 END
FROM generate_series(1,15000) AS g(i)
CROSS JOIN LATERAL generate_series(1,2+i%2) AS l(j);
INSERT INTO payments
SELECT i, i, CASE WHEN i%17=0 THEN NULL ELSE o.ordered_at+interval '1 hour' END,
 CASE WHEN i%17=0 THEN 'pending' WHEN i%7=0 THEN 'failed' ELSE 'succeeded' END,
 s.total
FROM generate_series(1,15000) AS g(i) JOIN orders o ON o.order_id=i
JOIN (SELECT order_id,sum(quantity*unit_price-discount_amount) total FROM order_items GROUP BY order_id) s ON s.order_id=i;
-- A second successful payment is intentional: qualification must not multiply revenue.
INSERT INTO payments SELECT 15000+order_id,order_id,ordered_at+interval '2 hours','succeeded',0
FROM orders WHERE order_id%19=0;
INSERT INTO customer_updates
SELECT i, 1+(i-1)/1000, 1+(i*37)%2200,
 'customer'||(1+(i*37)%2200)||'@example.test', CASE WHEN i%7=0 THEN NULL ELSE 'PT' END,
 timestamp '2024-01-01'+((i*17)%43)*interval '1 day',1+i%4,i,
 timestamp '2025-01-01'+i*interval '1 second'
FROM generate_series(1,3000) AS g(i);
INSERT INTO customer_updates
SELECT ingestion_id+3000,batch_id,customer_id,email,country,source_updated_at,source_version,source_event_id,
 received_at+interval '1 day' FROM customer_updates WHERE ingestion_id<=100;
ANALYZE;
