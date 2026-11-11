/*
07 — PostgreSQL Query Optimization
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
Escribe tu solución debajo. No hay pistas ni solución precargada.
*/

-- TU SOLUCIÓN:
