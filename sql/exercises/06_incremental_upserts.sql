/*
06 — Incremental Loading and Upserts

ES — Enunciado
Contexto: Una integración debe aplicar snapshots sin retroceder versiones ni duplicar clientes.
Objetivo y requisitos: Escribe una operación transaccional sobre incremental.customers leyendo
customer_updates del search_path. Filtra el lote con current_setting('lab.batch_id')::integer. No
hagas COMMIT/ROLLBACK: el runner controla la transacción. Destino tiene las mismas columnas y
restricciones que customers. Copia los seis atributos del snapshot ganador, sin ingestion_id. Aplica
solo prioridades de negocio estrictamente mayores; inserta clientes nuevos. En los fixtures se
validan los lotes 1, 1, 2, 1, 2; en lab se procesan los lotes disponibles con repeticiones y una
repetición tardía de un lote antiguo. Los replays no deben generar escrituras físicas.
Documenta atomicidad, NULL, duplicados y
fuera de orden. Puedes usar varias sentencias; no alteres esquemas ni tablas base.
Columnas esperadas: Estado final de incremental.customers: customer_id bigint, email text, country
text nullable, source_updated_at timestamp, source_version integer, source_event_id bigint
Reglas: README.md (Business rules) es el contrato común.
Casos límite: NULL, ausencia de actividad, empates, pagos repetidos y versiones fuera de orden
cuando apliquen.
Aceptación: columnas y tipos compatibles, valores exactos, cardinalidad correcta, orden indicado,
casos límite y explicación breve. Los tests son necesarios pero la revisión técnica también es
obligatoria.
Dificultad y tiempo estimado: alta · 50 min.

EN — Exercise statement
Context: An integration must apply customer snapshots without reverting versions
or creating duplicate customers.
Write a transactional operation against incremental.customers, reading
customer_updates from the active search_path. Select the batch using
current_setting('lab.batch_id')::integer. Do not issue COMMIT or ROLLBACK; the runner
controls the transaction. The destination has the same columns and constraints
as customers. Copy all six destination fields from the winning snapshot, excluding
ingestion_id. Insert new customers and update existing ones only when the incoming
business priority is strictly greater, as defined in README.md (Business rules).
Check idempotence and physical no-op behavior on replays, including a late replay
of an older batch. The fixture sequence is 1, 1, 2, 1, 2; base validation processes
the available batches with repeated loads and an older-batch replay.
Document atomicity, NULLs, duplicates, and out-of-order updates. Multiple statements
are allowed; do not alter schemas or base tables.
Expected destination state: customer_id bigint, email text, country text nullable,
source_updated_at timestamp, source_version integer, source_event_id bigint.
Edge cases: duplicate snapshots, tied priorities, late events, explicit NULL country,
new customers, replays, and unique-email conflicts under the common business rules.
Acceptance: correct complete destination state, preserved integrity, deterministic
priority handling, atomicity, and idempotence. Tests also require technical review.
Estimated difficulty and time: high, 50 minutes.
Write your solution below. No hints or prewritten solution are provided.

Escribe tu solución debajo. No hay pistas ni solución precargada.
*/

-- TU SOLUCIÓN:
