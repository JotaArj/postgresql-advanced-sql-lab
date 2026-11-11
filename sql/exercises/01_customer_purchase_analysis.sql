/*
01 — Customer Purchase Analysis
Contexto: El equipo CRM necesita el historial y las métricas de cada cliente.
Objetivo y requisitos: Una fila por compra válida y una fila con campos de compra NULL para cada
cliente sin compras. Repite en cada fila primera/última compra, número de compras y gasto total del
cliente. Numera compras desde 1; calcula días desde la anterior, NULL en la primera. Sin compras:
conteo y gasto 0; fechas, posición e intervalo NULL. Orden de entrega: customer_id,
purchase_position NULLS LAST.
Columnas esperadas: customer_id bigint, order_id bigint nullable, ordered_at timestamp nullable,
first_purchase_at timestamp nullable, last_purchase_at timestamp nullable, purchase_count bigint,
lifetime_revenue numeric, purchase_position bigint nullable, days_since_previous numeric nullable
Reglas: README.md (Business rules) es el contrato común.
Casos límite: NULL, ausencia de actividad, empates, pagos repetidos y versiones fuera de orden
cuando apliquen.
Aceptación: columnas y tipos compatibles, valores exactos, cardinalidad correcta, orden indicado,
casos límite y explicación breve. Los tests son necesarios pero la revisión técnica también es
obligatoria.
Dificultad y tiempo estimado: media-alta · 45 min.
Escribe tu solución debajo. No hay pistas ni solución precargada.
*/

-- TU SOLUCIÓN:
