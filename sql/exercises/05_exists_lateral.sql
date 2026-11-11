/*
05 — EXISTS, NOT EXISTS and LATERAL
Contexto: CRM y catálogo necesitan tres extracciones sin duplicaciones.
Objetivo y requisitos: A: clientes con al menos dos compras válidas y al menos una compra con
ingresos >=100 EUR. B: productos nunca incluidos en una compra válida, incluso si solo aparecen en
pedidos no válidos. C: última compra válida de TODOS los clientes; NULL en compra, fecha e ingresos
para quien no compra. Entrega tres consultas separadas bajo los marcadores PART A, PART B y PART C de este archivo.
Estrategia SQL libre. Orden A/C: customer_id; B: product_id.
Columnas esperadas: A: customer_id bigint; B: product_id bigint; C: customer_id bigint, order_id
bigint nullable, ordered_at timestamp nullable, revenue numeric nullable
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

-- PART A


-- PART B


-- PART C


