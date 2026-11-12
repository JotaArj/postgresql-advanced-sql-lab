/*
07 — PostgreSQL Query Optimization

ES — Enunciado
Contexto: Finanzas necesita un informe mensual de ingresos por cliente de julio a diciembre de 2024.
Objetivo y requisitos: La consulta inicial está en benchmarks/baseline.sql; es la única solución
proporcionada por exigencia de este ejercicio. Conserva exactamente sus filas y valores. Usa perf
con escala configurable; nunca modifiques lab. Registra plan EXPLAIN (ANALYZE, BUFFERS), al menos
cinco medidas antes/después, primera ejecución separada de las calientes, hardware, versión,
volumen, estadísticas y cambios realizados. No fuerces planes. Comprueba equivalencia multiconjunto.
No se exige aceleración si la medición no la demuestra. Orden: month, customer_id.
Columnas esperadas: month date, customer_id bigint, revenue numeric
Reglas: README.md (Business rules) es el contrato común.
Casos límite: NULL, ausencia de actividad, empates, pagos repetidos y versiones fuera de orden
cuando apliquen.
Aceptación: columnas y tipos compatibles, valores exactos, cardinalidad correcta, orden indicado,
casos límite y explicación breve. Los tests son necesarios pero la revisión técnica también es
obligatoria.
Dificultad y tiempo estimado: alta · 60 min.

EN — Exercise statement
Context: Finance needs monthly revenue per customer for July through December 2024.
The functional starting query is benchmarks/baseline.sql, provided specifically
for this optimization exercise. Preserve its exact rows and values.
Use the isolated perf schema with configurable scale; never modify lab.
Record EXPLAIN (ANALYZE, BUFFERS) plans, at least five before/after measurements,
the first execution separately from warm runs, hardware, PostgreSQL version,
data volume, optimizer statistics, measurement conditions, and all changes made.
Do not force execution plans. Check multiset equivalence, including duplicates.
Do not claim a speedup unless repeated measurements support it; a speedup is not
required when the evidence does not demonstrate one.
Expected columns: month date, customer_id bigint, revenue numeric.
Output order: month, customer_id.
Business rules: README.md (Business rules) is the common contract.
Edge cases: repeated payment attempts, invalid orders, interval boundaries,
zero revenue, cache effects, and different data volumes.
Acceptance: functional equivalence, compatible columns and types, correct ordering,
reproducible measurements, justified changes, and an honest technical conclusion.
Tests are necessary; technical review is also required.
Estimated difficulty and time: high, 60 minutes.
Write your candidate and explanation below. No optimized solution or index
recommendations are provided.

Escribe tu solución debajo. No hay pistas ni solución precargada.
*/

-- TU SOLUCIÓN:
