/*
08 — Integrated Business Case

ES — Enunciado
Contexto: Comercial quiere contactar clientes de alto valor que muestran señales de abandono.
Objetivo y requisitos: En la fecha de observación 2025-01-01, selecciona clientes con gasto
histórico >=150 EUR, al menos dos compras válidas y ninguna compra válida desde 2024-10-01
inclusive. Devuelve última compra y días desde ella, gasto histórico, número de compras y meses
activos distintos. Incluye categoría favorita por ingresos históricos; empates por category_id
menor. recent_revenue es el gasto válido en [2024-07-01, 2025-01-01); cero si no hay. No dupliques
clientes por líneas ni pagos. Añade una explicación breve de decisiones y límites. Orden:
lifetime_revenue DESC, customer_id.
Columnas esperadas: customer_id bigint, last_purchase_at timestamp, days_since_last numeric,
purchase_count bigint, lifetime_revenue numeric, active_months bigint, favorite_category_id bigint,
recent_revenue numeric
Reglas: README.md (Business rules) es el contrato común.
Casos límite: NULL, ausencia de actividad, empates, pagos repetidos y versiones fuera de orden
cuando apliquen.
Aceptación: columnas y tipos compatibles, valores exactos, cardinalidad correcta, orden indicado,
casos límite y explicación breve. Los tests son necesarios pero la revisión técnica también es
obligatoria.
Dificultad y tiempo estimado: muy alta · 55 min.

EN — Exercise statement
Context: Sales wants to contact high-value customers showing signs of churn.
At the observation timestamp 2025-01-01, select customers with lifetime revenue
of at least 150 EUR, at least two valid purchases, and no valid purchases on or
after 2024-10-01. Apply the common observation cutoff and validity rules.
Return the latest purchase timestamp, decimal days since that purchase, lifetime
revenue, purchase count, and the number of distinct active calendar months.
Include the favorite category by lifetime revenue, resolving ties by the smallest
category_id. recent_revenue is valid purchase revenue in [2024-07-01, 2025-01-01),
or zero when there is none. Avoid duplicating customers through lines or payments.
Add a short explanation of technical decisions and limitations in this file.
Expected columns: customer_id bigint, last_purchase_at timestamp,
days_since_last numeric, purchase_count bigint, lifetime_revenue numeric,
active_months bigint, favorite_category_id bigint, recent_revenue numeric.
Output order: lifetime_revenue DESC, customer_id.
Business rules: README.md (Business rules) is the common contract.
Edge cases: no recent activity, exact threshold amounts and date boundaries,
favorite-category ties, repeated successful payments, and multiple lines per order.
Acceptance: compatible columns and types, exact values, one row per qualifying
customer, deterministic ordering, edge-case handling, and a short explanation.
Tests are necessary; technical review is also required.
Estimated difficulty and time: very high, 55 minutes.
Write your solution below. No hints or prewritten solution are provided.

Escribe tu solución debajo. No hay pistas ni solución precargada.
*/

-- TU SOLUCIÓN:
