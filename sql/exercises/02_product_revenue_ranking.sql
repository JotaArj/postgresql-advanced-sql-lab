/*
02 — Product Revenue Ranking

ES — Enunciado
Contexto: Comercial compara los productos que lideran cada categoría en cada mes.

Objetivo y requisitos: 
    - Una fila por producto con actividad válida, categoría y mes si ocupa uno de
    los tres primeros puestos de ingresos distintos. 
    - Los empates comparten puesto y no dejan huecos;
    pueden salir más de tres productos. 
    - Participación sobre TODOS los productos de esa categoría y mes,
    antes del filtro de puestos. 
    - Si el denominador es cero, el porcentaje es NULL.

Orden: month, category_id, revenue_rank, product_id.

Columnas esperadas: 
    - month date, 
    - category_id bigint, 
    - product_id bigint, 
    - revenue numeric, 
    - revenue_rank bigint, 
    - category_share_pct numeric nullable

Reglas: README.md (Business rules) es el contrato común.

Casos límite: NULL, ausencia de actividad, empates, pagos repetidos y versiones fuera de orden
cuando apliquen.

Aceptación: columnas y tipos compatibles, valores exactos, cardinalidad correcta, orden indicado,
casos límite y explicación breve. Los tests son necesarios pero la revisión técnica también es
obligatoria.

Dificultad y tiempo estimado: alta · 40 min.

EN — Exercise statement
Business context: Sales needs the leading products in each category and month.
Return one row per product, category, and month for the first three distinct revenue
levels. Ties share a rank without gaps, so more than three products may qualify.
Calculate each product's percentage of ALL revenue in its category and month before
filtering ranks. Return NULL when the denominator is zero. Round percentages to two
decimal places. Apply the common business rules in README.md.
Expected columns and types: see the English-named column list above.
Output order: month, category_id, revenue_rank, product_id.
Acceptance requires correct columns, compatible types, exact values, cardinality,
deterministic output, edge-case handling, and a short technical explanation.
Relevant edge cases include ties, repeated payments, zero category revenue, NULLs,
and products without valid sales. Tests must be followed by technical review.
Estimated difficulty and time: high, 40 minutes.

*/

-- TU SOLUCIÓN:

/*
ES — Análisis del origen y del nivel de detalle:
    - month: mes de la fecha del pedido en orders.
    - category_id: categoría del producto en products.
    - product_id: producto de la línea en order_items.
    - revenue: suma de los ingresos netos de las líneas por mes, categoría y producto.
    - revenue_rank: puesto calculado sobre esos ingresos agregados.
    - category_share_pct: porcentaje de los ingresos de la categoría y mes.

EN — Source and granularity analysis:
    - month: month of the order timestamp in orders.
    - category_id: product category from products.
    - product_id: product referenced by the order_items line.
    - revenue: net line revenue aggregated by month, category, and product.
    - revenue_rank: rank calculated from these aggregated revenues.
    - category_share_pct: percentage of category revenue in the same month.
*/


--SET search_path TO lab;

EXPLAIN (ANALYZE, BUFFERS)

WITH completed_orders as (
    SELECT 
        o.order_id, 
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
Las comparaciones de rendimiento se resumen al final del archivo.

EN: I select completed orders before the exclusive January 1, 2025 cutoff that have
at least one successful payment. EXISTS checks this condition without duplicating
orders when an order has multiple successful payments.
Performance comparisons are summarized at the end of this file.
*/

items_validated as (
    SELECT 
        DATE_TRUNC('month', co.ordered_at)::date as month,
        p.category_id,
        oi.product_id,
        oi.quantity * oi.unit_price - oi.discount_amount as product_revenue,
        oi.quantity
    FROM completed_orders as co
        JOIN order_items as oi on oi.order_id = co.order_id
        JOIN products as p on oi.product_id = p.product_id
),

/*
ES: Parto de los pedidos válidos, incorporo sus líneas y obtengo category_id desde
products. Convierto la fecha al primer día de su mes y calculo el ingreso neto de
cada línea, aplicando el descuento por línea. Todavía no es el ingreso mensual
del producto. Uso INNER JOIN porque el informe requiere líneas de productos vendidos.
Los pedidos sin líneas no aportan productos que clasificar. Las claves foráneas y
NOT NULL garantizan que cada línea referencia un producto existente con categoría.
No uno categories: category_id ya está en products. Un atributo nulo y una relación
ausente son situaciones distintas; si el modelo cambiara, revisaría estas decisiones.

EN: I start from valid orders, join their lines, and retrieve category_id from
products. I convert each timestamp to the first day of its month and calculate net
line revenue, applying the discount per line. This is not yet monthly product revenue.
I use INNER JOIN because the report requires lines for products sold. Orders without
lines contribute no products to rank. Foreign keys and NOT NULL constraints guarantee
that each line references an existing product with a category. No join to categories
is needed: category_id is available in products. A NULL attribute and a missing
relationship are different cases; these decisions must be reviewed if the model changes.
*/

date_category_items_grouped as (
    SELECT
        month,
        category_id,
        product_id,
        SUM(product_revenue) as revenue
    FROM items_validated
    GROUP BY month, category_id, product_id
),

/*
ES: Agrupo por mes, categoría y producto para obtener una fila por combinación,
sumando los ingresos netos de las líneas. Elimino la suma de cantidades porque
no es necesaria para las métricas solicitadas.

EN: I group by month, category, and product to produce one row per combination,
summing net line revenue. I removed the quantity aggregation because the requested
metrics do not require it.
*/

items_category_monthly_ranked as (
    SELECT
        month,     
        category_id,
        product_id,
        revenue,
        DENSE_RANK() OVER (PARTITION BY month, category_id ORDER BY revenue DESC) as revenue_rank,
        (100 * revenue / 
            NULLIF(SUM(revenue) 
                    OVER (PARTITION BY month, category_id),0)
            ) as category_share_pct
    FROM date_category_items_grouped
),

/*
ES: DENSE_RANK asigna los puestos de ingresos dentro de cada categoría y mes;
los empates comparten puesto y no dejan huecos. Calculo la participación sobre los
ingresos de todos los productos de esa misma categoría y mes, antes de filtrar puestos.
NULLIF convierte el denominador cero en NULL para evitar la división por cero.
El numerador usa directamente revenue, ya calculado al nivel requerido, sin otra ventana.

EN: DENSE_RANK assigns revenue ranks within each category and month; ties share a
rank without gaps. I calculate each product's share of all revenue in the same
category and month before filtering ranks. NULLIF turns a zero denominator into
NULL to prevent division by zero. The numerator uses revenue directly, already
calculated at the required granularity, without an additional window.
*/

final as (
    SELECT         
        month,     
        category_id,
        product_id,
        revenue,
        revenue_rank,
        ROUND(category_share_pct, 2) as category_share_pct
    FROM items_category_monthly_ranked
    WHERE revenue_rank <= 3
)
/*
ES: Conservo los tres primeros puestos de ingresos distintos. Puede haber más de
tres productos por categoría y mes debido a los empates. Redondeo el porcentaje a
dos decimales después de calcularlo sobre todos los productos.

EN: I retain the first three distinct revenue ranks. Ties can produce more than three
products per category and month. I round percentages to two decimal places after
calculating them across all products.
*/

SELECT * 
FROM final
ORDER BY month, category_id, revenue_rank, product_id

/*
ES: Ordeno el resultado por mes, categoría, puesto y product_id. El identificador
del producto determina el orden de salida entre empates sin modificar sus puestos.

EN: I order the result by month, category, rank, and product_id. The product ID makes
the output deterministic for tied products without changing their ranks.
*/

/*
ES — Rendimiento y conclusión:
En 16 ejecuciones calientes alternadas por versión, la mediana fue de 48,37 ms
con LEFT JOIN y de 50,06 ms con INNER JOIN. Los rangos se solaparon; no se demostró
una mejora de velocidad. Conservo INNER JOIN por su significado en este informe.
Un índice experimental en order_items(product_id) no se utilizó y no mostró una
mejora: medianas de 45,84 ms sin él y 45,88 ms con él, en 12 ejecuciones calientes
por configuración. El índice se creó temporalmente y se deshizo al terminar.
Los tiempos incluyen instrumentación de EXPLAIN ANALYZE y corresponden al dataset
base; no son garantías para otros volúmenes ni deben compararse entre tandas distintas.
Evidencia local: artifacts/02_inner_join_20261112T115643690512.json y
artifacts/02_product_index_20261112T115326525569.json.

EN — Performance and conclusion:
Across 16 alternating warm executions per version, median execution time was
48.37 ms with LEFT JOIN and 50.06 ms with INNER JOIN. Ranges overlapped; no speed
improvement was demonstrated. I retain INNER JOIN for its meaning in this report.
A temporary index on order_items(product_id) was unused and showed no improvement:
medians were 45.84 ms without it and 45.88 ms with it across 12 warm executions per
configuration. The experimental index was rolled back after testing.
Times include EXPLAIN ANALYZE instrumentation and apply to the base dataset;
they are not guarantees at other scales and should not be compared across separate runs.
Local evidence: artifacts/02_inner_join_20261112T115643690512.json and
artifacts/02_product_index_20261112T115326525569.json.
*/
