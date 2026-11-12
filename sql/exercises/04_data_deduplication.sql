/*
04 — Data Deduplication

ES — Enunciado
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

EN — Exercise statement
Context: Integration receives repeated and late snapshots with tied timestamps.
Return exactly one winning snapshot per customer_id across all batches, following
the priority rules in README.md (Business rules). Include ingestion_id to audit the
selected physical copy. Do not modify staging. Explain in comments in this file
how you distinguish physical duplicates, obsolete versions, and replays, and how
you would preserve historical information.
Expected columns: customer_id bigint, email text, country text nullable,
source_updated_at timestamp, source_version integer, source_event_id bigint,
ingestion_id bigint.
Output order: customer_id.
Edge cases: NULL country, duplicate payloads, tied source timestamps and versions,
ingestion ties, out-of-order arrivals, and customers absent from the destination.
Acceptance: compatible columns and types, the correct winner for each customer,
deterministic selection, correct cardinality and ordering, and a short explanation.
Tests are necessary; technical review is also required.
Estimated difficulty and time: high, 35 minutes.
Write your solution below. No hints or prewritten solution are provided.

Escribe tu solución debajo. No hay pistas ni solución precargada.
*/

-- TU SOLUCIÓN:
