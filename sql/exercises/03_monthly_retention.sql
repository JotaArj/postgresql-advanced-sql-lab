/*
03 — Monthly Customer Retention

ES — Enunciado
Contexto: Producto necesita comparar la retención de las cohortes de adquisición.
Objetivo y requisitos: Cohorte = mes de primera compra válida. Una fila por cohorte y cada mes
observable desde ella hasta diciembre de 2024, incluidos meses vacíos. Cada cliente cuenta como
máximo una vez en un mes. Excluye clientes sin compras y meses futuros. month_offset empieza en 0 y
mide meses de calendario. cohort_size es el número inicial de clientes. Orden: cohort_month,
month_offset.
Columnas esperadas: cohort_month date, activity_month date, month_offset integer, cohort_size
bigint, active_customers bigint, retention_pct numeric
Reglas: README.md (Business rules) es el contrato común.
Casos límite: NULL, ausencia de actividad, empates, pagos repetidos y versiones fuera de orden
cuando apliquen.
Aceptación: columnas y tipos compatibles, valores exactos, cardinalidad correcta, orden indicado,
casos límite y explicación breve. Los tests son necesarios pero la revisión técnica también es
obligatoria.
Dificultad y tiempo estimado: alta · 50 min.

EN — Exercise statement
Context: Product needs to compare retention across customer acquisition cohorts.
A cohort is the month of a customer's first valid purchase. Return one row per
cohort and observable month from that cohort through December 2024, including
months with no activity. Count each customer at most once per activity month.
Exclude customers without valid purchases and future, unobservable months.
month_offset starts at 0 and measures calendar months, not fixed 30-day periods.
cohort_size is the initial number of customers in the cohort. retention_pct is the
percentage of that initial cohort with a valid purchase in the activity month;
months without activity have zero active customers and zero retention.
Expected columns: cohort_month date, activity_month date, month_offset integer,
cohort_size bigint, active_customers bigint, retention_pct numeric.
Output order: cohort_month, month_offset.
Business rules: README.md (Business rules) is the common contract, including valid
purchases, the exclusive observation cutoff, and percentage rounding.
Edge cases: repeated purchases in a month, inactive months, customers without
purchases, repeated successful payments, and late-year cohorts.
Acceptance: compatible columns and types, correct values and cardinality, specified
ordering, edge-case handling, and a short explanation. Passing tests also requires
technical review before the exercise is accepted.
Estimated difficulty and time: high, 50 minutes.
Write your solution below. No hints or prewritten solution are provided.

Escribe tu solución debajo. No hay pistas ni solución precargada.
*/

-- TU SOLUCIÓN:
