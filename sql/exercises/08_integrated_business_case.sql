/*
08 — Integrated Business Case
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
Escribe tu solución debajo. No hay pistas ni solución precargada.
*/

-- TU SOLUCIÓN:
