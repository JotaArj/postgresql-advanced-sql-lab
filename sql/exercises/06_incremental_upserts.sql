/*
06 — Incremental Loading and Upserts
Contexto: Una integración debe aplicar snapshots sin retroceder versiones ni duplicar clientes.
Objetivo y requisitos: Escribe una operación transaccional sobre incremental.customers leyendo
customer_updates del search_path. Filtra el lote con current_setting('lab.batch_id')::integer. No
hagas COMMIT/ROLLBACK: el runner controla la transacción. Destino tiene las mismas columnas y
restricciones que customers. Copia los seis atributos del snapshot ganador, sin ingestion_id. Aplica
solo prioridades de negocio estrictamente mayores; inserta clientes nuevos. Validaremos lotes 1, 1,
2, 1, 2 y que los replays no generen escrituras físicas. Documenta atomicidad, NULL, duplicados y
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
Escribe tu solución debajo. No hay pistas ni solución precargada.
*/

-- TU SOLUCIÓN:
