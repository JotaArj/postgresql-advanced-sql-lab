-- Functional starting point; the learner must establish and measure improvements.
SELECT date_trunc('month', o.ordered_at)::date AS month,
       o.customer_id,
       sum((SELECT sum(i.quantity*i.unit_price-i.discount_amount)
            FROM order_items i WHERE i.order_id=o.order_id)) AS revenue
FROM orders o
WHERE o.status='completed'
  AND o.ordered_at >= timestamp '2024-07-01'
  AND o.ordered_at < timestamp '2025-01-01'
  AND EXISTS (SELECT 1 FROM payments p WHERE p.order_id=o.order_id AND p.status='succeeded')
GROUP BY date_trunc('month',o.ordered_at)::date,o.customer_id
ORDER BY month,o.customer_id;
