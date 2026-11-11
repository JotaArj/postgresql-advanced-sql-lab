/*
04 — Data Deduplication
Contexto: Integración recibe snapshots repetidos, tardíos y con timestamps empatados.
Objetivo y requisitos: Devuelve exactamente el snapshot ganador por customer_id entre todos los
lotes según README.md (Business rules). Incluye ingestion_id para auditar la copia seleccionada. No
modifiques staging. Añade en comentarios de este archivo cómo distinguirías duplicados físicos, versiones
obsoletas y replays, y cómo conservarías el histórico. Orden: customer_id.
Columnas esperadas: customer_id bigint, email text, country text nullable, source_updated_at
timestamp, source_version integer, source_event_id bigint, ingestion_id bigint
Reglas: README.md (Business rules) es el contrato común.
Casos límite: NULL, ausencia de actividad, empates, pagos repetidos y versiones fuera de orden
cuando apliquen.
Aceptación: columnas y tipos compatibles, valores exactos, cardinalidad correcta, orden indicado,
casos límite y explicación breve. Los tests son necesarios pero la revisión técnica también es
obligatoria.
Dificultad y tiempo estimado: alta · 35 min.
Escribe tu solución debajo. No hay pistas ni solución precargada.
*/

-- TU SOLUCIÓN:
