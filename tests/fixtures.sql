INSERT INTO customers VALUES
(1,'a@example.test','ES','2024-01-01',1,1),
(2,'b@example.test','FR','2024-01-01',1,2),
(3,'c@example.test',NULL,'2024-01-01',1,3);
INSERT INTO categories VALUES (1,'Books'),(2,'Other');
INSERT INTO products VALUES (1,1,'A',100),(2,1,'B',50),(3,2,'C',100),(4,2,'D',100);
INSERT INTO orders VALUES
(1,1,'2024-01-10','completed'),(2,1,'2024-03-10','completed'),
(3,2,'2024-01-10','completed'),(4,2,'2024-02-10','cancelled'),
(5,3,'2024-02-10','pending'),(6,3,'2024-02-10','completed'),
(7,1,'2024-03-10','completed'),(8,2,'2024-07-10','completed'),
(9,3,'2025-01-01','completed');
INSERT INTO order_items VALUES
(1,1,1,2,30,10),(1,2,1,1,50,0),(2,1,2,1,50,0),(3,1,1,1,100,0),
(4,1,3,1,100,0),(5,1,3,1,100,0),(6,1,3,1,100,0),
(7,1,2,1,50,0),(8,1,4,1,100,100),(9,1,3,1,100,0);
INSERT INTO payments VALUES
(1,1,'2024-01-10','succeeded',100),(2,2,'2024-03-10','succeeded',50),
(3,3,'2024-01-10','succeeded',100),(4,4,'2024-02-10','succeeded',100),
(5,5,NULL,'pending',100),(6,6,'2024-02-10','failed',100),
(7,7,'2024-03-10','succeeded',50),(8,8,'2024-07-10','succeeded',0),
(9,1,'2024-01-11','succeeded',0),(10,9,'2025-01-01','succeeded',100);
INSERT INTO customer_updates VALUES
(1,1,1,'a@example.test',NULL,'2024-01-02',2,10,'2025-01-01'),
(2,1,1,'a@example.test',NULL,'2024-01-02',2,10,'2025-01-02'),
(3,1,2,'b@example.test','DE','2023-12-31',9,11,'2025-01-03'),
(4,1,4,'d@example.test','ES','2024-01-03',1,12,'2025-01-01'),
(5,2,1,'a@example.test','PT','2024-01-02',2,13,'2025-01-01'),
(6,1,4,'d@example.test','ES','2024-01-03',1,12,'2025-01-02'),
(7,1,4,'d@example.test','ES','2024-01-03',1,12,'2025-01-02');

-- FIXTURE: ranking
-- Additional independently specified ranking case: ties, three distinct places,
-- denominator before filtering, and a fourth distinct place excluded from output.
INSERT INTO customers VALUES (1,'rank@example.test',NULL,'2024-01-01',1,1);
INSERT INTO categories VALUES (1,'Category');
INSERT INTO products VALUES (1,1,'A',100),(2,1,'B',100),(3,1,'C',50),(4,1,'D',25),(5,1,'E',10);
INSERT INTO orders VALUES (1,1,'2024-01-01','completed');
INSERT INTO order_items VALUES (1,1,1,1,100,0),(1,2,2,1,100,0),(1,3,3,1,50,0),(1,4,4,1,25,0),(1,5,5,1,10,0);
INSERT INTO payments VALUES (1,1,'2024-01-01','succeeded',285);
