/*
02 — Product Revenue Ranking
Contexto: Comercial compara los productos que lideran cada categoría en cada mes.
Objetivo y requisitos: Una fila por producto con actividad válida, categoría y mes si ocupa uno de
los tres primeros puestos de ingresos distintos. Los empates comparten puesto y no dejan huecos;
pueden salir más de tres productos. Participación sobre TODOS los productos de esa categoría y mes,
antes del filtro de puestos. Si el denominador es cero, porcentaje NULL. Orden: month, category_id,
revenue_rank, product_id.
Columnas esperadas: month date, category_id bigint, product_id bigint, revenue numeric, revenue_rank
bigint, category_share_pct numeric nullable
Reglas: README.md (Business rules) es el contrato común.
Casos límite: NULL, ausencia de actividad, empates, pagos repetidos y versiones fuera de orden
cuando apliquen.
Aceptación: columnas y tipos compatibles, valores exactos, cardinalidad correcta, orden indicado,
casos límite y explicación breve. Los tests son necesarios pero la revisión técnica también es
obligatoria.
Dificultad y tiempo estimado: alta · 40 min.
Escribe tu solución debajo. No hay pistas ni solución precargada.
*/

-- TU SOLUCIÓN:
