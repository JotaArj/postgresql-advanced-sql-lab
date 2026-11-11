/*
03 — Monthly Customer Retention
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
Escribe tu solución debajo. No hay pistas ni solución precargada.
*/

-- TU SOLUCIÓN:
