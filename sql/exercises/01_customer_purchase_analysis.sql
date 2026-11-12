/*
01 — Customer Purchase Analysis

ES — Enunciado

Contexto: El equipo de CRM necesita el historial y las métricas de cada cliente.

Objetivo y requisitos: Una fila por compra válida y una fila con campos de compra NULL para cada
cliente sin compras. 

    - Repite en cada fila primera/última compra, número de compras y gasto total del cliente. 
    - Numera las compras desde 1. 
    - Calcula los días desde la compra anterior; NULL en la primera.
    - Sin compras: conteo y gasto 0; fechas, posición e intervalo NULL. 

Orden de entrega: customer_id, purchase_position NULLS LAST.

Columnas esperadas: 
    - customer_id bigint, 
    - order_id bigint nullable, 
    - ordered_at timestamp nullable,
    - first_purchase_at timestamp nullable, 
    - last_purchase_at timestamp nullable, 
    - purchase_count bigint,
    - lifetime_revenue numeric, 
    - purchase_position bigint nullable, 
    - days_since_previous numeric nullable

Reglas: README.md (Business rules) es el contrato común.

Casos límite: NULL, ausencia de actividad, empates, pagos repetidos y versiones fuera de orden
cuando apliquen.

Aceptación: columnas y tipos compatibles, valores exactos, cardinalidad correcta, orden indicado,
casos límite y explicación breve. Los tests son necesarios pero la revisión técnica también es
obligatoria.

Dificultad y tiempo estimado: media-alta · 45 min.

La solución del alumno y sus decisiones técnicas aparecen debajo.


EN — Exercise statement

Context: The CRM team needs each customer's purchase history and metrics.
Goal: Return one row per valid purchase, plus one row with NULL purchase fields
for each customer without valid purchases.

- Repeat the customer's first and last purchase timestamps, valid purchase count,
  and lifetime revenue on each row.
- Number purchases starting at 1.
- Calculate decimal days since the previous purchase; NULL for the first purchase.
- For customers without purchases, return a count and revenue of 0. Purchase fields,
  timestamps, position, and interval must be NULL.

Output order: customer_id, purchase_position NULLS LAST.
Expected columns and SQL types: see the shared column list above (English names).
Business rules: README.md (Business rules) is the common contract.
Edge cases: NULLs, no activity, ties, repeated payments, and out-of-order versions
where applicable.
Acceptance: compatible columns and types, exact values, correct cardinality,
specified ordering, edge-case handling, and a short explanation. Tests are necessary;
technical review is also required.
Estimated difficulty and time: medium-high, 45 minutes.
The learner's solution and technical decisions follow below.

-- SOLUCIÓN DEL ALUMNO / LEARNER'S SOLUTION:
*/
SET search_path TO lab;

EXPLAIN (ANALYZE, BUFFERS)

WITH order_items_order_id_grouped as (
    SELECT 
        order_id,
        SUM(quantity * unit_price - discount_amount) as total_order_amount
    FROM order_items
    GROUP BY order_id
),

/*
ES: Agrupo las líneas para obtener una fila por pedido y calcular su importe neto.
El descuento se aplica por línea, según las reglas de negocio.

EN: I aggregate order lines into one row per order and calculate its net amount.
Discounts apply per line, as specified by the business rules.
*/

completed_orders as (
    SELECT 
        o.order_id, 
        o.customer_id, 
        o.ordered_at
    FROM orders as o
    WHERE status='completed'
        AND o.ordered_at < '2025-01-01 00:00:00'
        AND EXISTS (
            SELECT 1
            FROM payments as p
            WHERE status = 'succeeded'
                AND o.order_id = p.order_id
        )
),

/*
ES: Selecciono pedidos completados anteriores al corte exclusivo del 1 de enero de
2025 que tengan al menos un pago exitoso. EXISTS comprueba esta condición sin
multiplicar pedidos cuando existen varios pagos exitosos para el mismo pedido.
En la comparación documentada, el plan sustituyó la deduplicación de pagos por un
Hash Semi Join. La mediana bajó de 69,40 a 65,41 ms (aproximadamente un 5,8 %) en
12 ejecuciones calientes por versión, alternadas en una misma sesión. Hubo bastante
solapamiento entre los tiempos; no es una garantía de mejora en otros escenarios.
Evidencia local: artifacts/01_exists_20261112T082929721249.json.

EN: I select completed orders before the exclusive January 1, 2025 cutoff that have
at least one successful payment. EXISTS checks this condition without duplicating
orders when an order has multiple successful payments.
In the documented comparison, the plan replaced payment deduplication with a
Hash Semi Join. The median decreased from 69.40 to 65.41 ms (approximately 5.8%)
across 12 warm executions per version, alternated within the same session. Execution
times overlapped substantially; this does not guarantee an improvement elsewhere.
Local evidence: artifacts/01_exists_20261112T082929721249.json.
*/

customers_with_orders as (
    SELECT
        co.customer_id,
        co.order_id,
        co.ordered_at,
        oig.total_order_amount,
        MIN(co.ordered_at) OVER customer_history as first_purchase_at, 
        MAX(co.ordered_at) OVER customer_history as last_purchase_at, 
        COUNT(1) OVER customer_history as purchase_count,
        SUM(oig.total_order_amount) OVER customer_history as lifetime_revenue,
        ROW_NUMBER() OVER customer_history as purchase_position,
        co.ordered_at - LAG(co.ordered_at) OVER customer_history as days_since_previous
    FROM completed_orders as co 
        LEFT JOIN order_items_order_id_grouped as oig on oig.order_id = co.order_id
    WINDOW customer_history AS (    
        PARTITION BY co.customer_id
        ORDER BY co.ordered_at, co.order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    )
),

/*
ES: Uno los pedidos válidos con sus importes previamente agrupados. El LEFT JOIN
conserva los pedidos válidos aunque no tengan líneas asociadas. Las funciones de
ventana calculan las métricas del cliente sin perder el detalle de cada compra.
Ordeno por fecha y order_id para resolver los empates de forma determinista.
El marco completo incluye todas las compras del cliente y evita que las agregaciones
se conviertan en acumulados al añadir la ordenación.

Defino una ventana común. En el plan medido, PostgreSQL pasó de dos nodos WindowAgg
a uno. En 20 ejecuciones calientes por versión, alternadas en una misma sesión,
la mediana con EXPLAIN ANALYZE bajó de 58,43 a 54,50 ms (aproximadamente un 6,7 %).
La primera ejecución de cada versión se excluyó del resumen. Los resultados fueron
equivalentes. Esta mejora corresponde al dataset y a las condiciones de la prueba;
no garantiza el mismo resultado con otros volúmenes. Los porcentajes de experimentos
distintos no se suman para calcular una mejora total.
Evidencia local: artifacts/01_full_frame_20261112T095612092898.json.

EN: I join valid orders to their previously aggregated amounts. The LEFT JOIN retains
valid orders even when they have no associated lines. Window functions calculate
customer metrics while preserving individual purchase rows.
I order by timestamp and order_id to resolve ties deterministically.
The full-partition frame includes every purchase for the customer, preventing
aggregates from becoming running aggregates when ordering is introduced.

I define a shared window. In the measured plan, PostgreSQL reduced the number of
WindowAgg nodes from two to one. Across 20 warm executions per version, alternated
within the same session, median EXPLAIN ANALYZE execution time decreased from 58.43
to 54.50 ms (approximately 6.7%). Each version's first execution was excluded from
the summary. Results were equivalent. This improvement applies to the dataset and
test conditions; it is not guaranteed at other scales. Percentages from separate
experiments must not be added to claim an overall improvement.
Local evidence: artifacts/01_full_frame_20261112T095612092898.json.
*/

final as (
    SELECT 
        c.customer_id,
        cwo.order_id, 
        cwo.ordered_at,
        cwo.first_purchase_at, 
        cwo.last_purchase_at, 
        COALESCE(cwo.purchase_count, 0) as purchase_count,
        COALESCE(cwo.lifetime_revenue, 0) as lifetime_revenue,
        cwo.purchase_position,
        EXTRACT(EPOCH FROM cwo.days_since_previous ) / 86400.0 as days_since_previous
    FROM customers as c
        LEFT JOIN customers_with_orders as cwo on cwo.customer_id = c.customer_id
)

/*
ES: Parto de customers y uso un LEFT JOIN para conservar todos los clientes, incluidos
los que no tienen compras válidas. COALESCE devuelve 0 en purchase_count y
lifetime_revenue cuando no hay compras; los demás campos de compra permanecen en NULL.
Convierto el intervalo entre compras a días decimales, conservando las horas.

EN: I start from customers and use a LEFT JOIN to retain every customer, including
those without valid purchases. COALESCE returns 0 for purchase_count and
lifetime_revenue when there are no purchases; other purchase fields remain NULL.
I convert the interval between purchases to decimal days, preserving fractional days.
*/                                 

SELECT *
FROM final
ORDER BY customer_id, purchase_position

/*
ES: Se consideraron un índice sobre payments(order_id) y una alternativa parcial
para pagos exitosos. Los informes disponibles no documentan una comparación de sus
tiempos, por lo que no concluyo que ningún índice pueda mejorar esta consulta.
Las mejoras descritas arriba corresponden a cambios de consulta medidos.

EN: An index on payments(order_id) and a partial index for successful payments were
considered. The available reports do not document a timing comparison for these
indexes, so I do not conclude that no index could improve this query.
The improvements described above refer to measured query changes.
*/           
