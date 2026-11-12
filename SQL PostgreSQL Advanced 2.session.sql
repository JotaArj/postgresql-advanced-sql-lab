SELECT
    tablename,
    indexname,
    indexdef
FROM pg_indexes
WHERE schemaname = 'lab'
ORDER BY tablename, indexname;