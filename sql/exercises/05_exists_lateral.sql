/*
05 — EXISTS, NOT EXISTS and LATERAL

ES — Enunciado
Contexto: CRM y catálogo necesitan tres extracciones sin duplicaciones.
Objetivo y requisitos: A: clientes con al menos dos compras válidas y al menos una compra con
ingresos >=100 EUR. B: productos nunca incluidos en una compra válida, incluso si solo aparecen en
pedidos no válidos. C: última compra válida de TODOS los clientes; NULL en compra, fecha e ingresos
para quien no compra. Entrega tres consultas separadas bajo los marcadores PART A, PART B y PART C de este archivo.
Estrategia SQL libre. Orden A/C: customer_id; B: product_id.
Columnas esperadas: A: customer_id bigint; B: product_id bigint; C: customer_id bigint, order_id
bigint nullable, ordered_at timestamp nullable, revenue numeric nullable
Reglas: README.md (Business rules) es el contrato común.
Casos límite: NULL, ausencia de actividad, empates, pagos repetidos y versiones fuera de orden
cuando apliquen.
Aceptación: columnas y tipos compatibles, valores exactos, cardinalidad correcta, orden indicado,
casos límite y explicación breve. Los tests son necesarios pero la revisión técnica también es
obligatoria.
Dificultad y tiempo estimado: alta · 35 min.

EN — Exercise statement
Context: CRM and Catalog need three extracts without unintended duplicates.
A: Customers with at least two valid purchases and at least one valid purchase
with revenue of 100 EUR or more. Expected column: customer_id bigint.
B: Products never included in a valid purchase, including products appearing only
in invalid orders. Expected column: product_id bigint.
C: The latest valid purchase for EVERY customer. For customers without purchases,
return NULL for order, timestamp, and revenue. Expected columns: customer_id bigint,
order_id bigint nullable, ordered_at timestamp nullable, revenue numeric nullable.
Write three separate queries under -- PART A, -- PART B, and -- PART C in this file.
Choose an appropriate SQL strategy; no specific construct is mandatory.
Output order: customer_id for A and C; product_id for B.
Business rules: README.md (Business rules) defines valid purchases, the observation
cutoff, net revenue, and deterministic ordering of purchases.
Edge cases: no activity, tied purchase timestamps, repeated successful payments,
and products sold only through invalid orders.
Acceptance: compatible columns and types, exact values, no unintended duplicates,
correct cardinality and ordering, NULL handling, and a short technical explanation.
Tests are necessary; technical review is also required.
Estimated difficulty and time: high, 35 minutes.
Write your solutions below. No hints or prewritten solutions are provided.

Escribe tu solución debajo. No hay pistas ni solución precargada.
*/

-- TU SOLUCIÓN:

-- PART A


-- PART B


-- PART C


