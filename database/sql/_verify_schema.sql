SET PAGESIZE 100
SET LINESIZE 200
SET FEEDBACK OFF
SET VERIFY OFF
SET HEADING ON

PROMPT === 1. TABLAS (esperado: 11) ===
SELECT table_name
FROM   user_tables
WHERE  table_name IN (
    'ROL', 'USUARIO', 'PELICULA', 'SALA', 'ASIENTO', 'FUNCION',
    'ESTADO_RESERVA', 'RESERVA', 'RESERVA_ASIENTO', 'PAGO', 'AUDITORIA_RESERVA'
)
ORDER BY table_name;

PROMPT
PROMPT === 2. SECUENCIAS (esperado: 11) ===
SELECT sequence_name, min_value, increment_by, cache_size, cycle_flag
FROM   user_sequences
WHERE  sequence_name LIKE 'SEQ_%'
ORDER BY sequence_name;

PROMPT
PROMPT === 3. CLAVES PRIMARIAS (esperado: 11) ===
SELECT constraint_name, table_name, status
FROM   user_constraints
WHERE  constraint_type = 'P'
  AND  table_name IN (
    'ROL', 'USUARIO', 'PELICULA', 'SALA', 'ASIENTO', 'FUNCION',
    'ESTADO_RESERVA', 'RESERVA', 'RESERVA_ASIENTO', 'PAGO', 'AUDITORIA_RESERVA'
)
ORDER BY table_name;

PROMPT
PROMPT === 4. CLAVES FORANEAS (esperado: 12) ===
SELECT constraint_name, table_name, r_constraint_name AS referencia_pk
FROM   user_constraints
WHERE  constraint_type = 'R'
ORDER BY table_name, constraint_name;

PROMPT
PROMPT === 5. UNIQUE (esperado: 10) ===
SELECT constraint_name, table_name
FROM   user_constraints
WHERE  constraint_type = 'U'
ORDER BY table_name;

PROMPT
PROMPT === 6. CHECK nombrados (esperado: 11) ===
SELECT constraint_name, table_name, search_condition_vc
FROM   user_constraints
WHERE  constraint_type = 'C'
  AND  constraint_name LIKE 'CK_%'
ORDER BY table_name;

PROMPT
PROMPT === 7. INDICES RECOMENDADOS (esperado: 7) ===
SELECT index_name, table_name, uniqueness
FROM   user_indexes
WHERE  index_name IN (
    'IDX_FUNCION_FECHA', 'IDX_FUNCION_PELICULA', 'IDX_FUNCION_SALA',
    'IDX_RESERVA_USUARIO', 'IDX_RESERVA_FUNCION',
    'IDX_RESERVA_ASIENTO_FUNCION', 'IDX_ASIENTO_SALA'
)
ORDER BY index_name;

PROMPT
PROMPT === 8. COMENTARIOS EN TABLAS (esperado: 11) ===
SELECT table_name, comments
FROM   user_tab_comments
WHERE  table_name IN (
    'ROL', 'USUARIO', 'PELICULA', 'SALA', 'ASIENTO', 'FUNCION',
    'ESTADO_RESERVA', 'RESERVA', 'RESERVA_ASIENTO', 'PAGO', 'AUDITORIA_RESERVA'
)
  AND  comments IS NOT NULL
ORDER BY table_name;

PROMPT
PROMPT === 9. PRUEBA SECUENCIAS (ROLLBACK) ===
INSERT INTO ROL (ID_ROL, NOMBRE) VALUES (SEQ_ROL.NEXTVAL, 'TEST_ROL');
INSERT INTO ESTADO_RESERVA (ID_ESTADO, NOMBRE) VALUES (SEQ_ESTADO_RESERVA.NEXTVAL, 'TEST_ESTADO');
ROLLBACK;
PROMPT Insercion y rollback OK

PROMPT
PROMPT === RESUMEN CONTEOS ===
SELECT 'TABLAS' AS objeto, COUNT(*) AS cantidad
FROM   user_tables
WHERE  table_name IN (
    'ROL', 'USUARIO', 'PELICULA', 'SALA', 'ASIENTO', 'FUNCION',
    'ESTADO_RESERVA', 'RESERVA', 'RESERVA_ASIENTO', 'PAGO', 'AUDITORIA_RESERVA'
)
UNION ALL
SELECT 'SECUENCIAS', COUNT(*) FROM user_sequences WHERE sequence_name LIKE 'SEQ_%'
UNION ALL
SELECT 'PK', COUNT(*) FROM user_constraints
WHERE constraint_type = 'P' AND table_name IN (
    'ROL', 'USUARIO', 'PELICULA', 'SALA', 'ASIENTO', 'FUNCION',
    'ESTADO_RESERVA', 'RESERVA', 'RESERVA_ASIENTO', 'PAGO', 'AUDITORIA_RESERVA')
UNION ALL
SELECT 'FK', COUNT(*) FROM user_constraints WHERE constraint_type = 'R'
UNION ALL
SELECT 'UNIQUE', COUNT(*) FROM user_constraints WHERE constraint_type = 'U'
UNION ALL
SELECT 'CHECK', COUNT(*) FROM user_constraints WHERE constraint_type = 'C' AND constraint_name LIKE 'CK_%'
UNION ALL
SELECT 'INDICES', COUNT(*) FROM user_indexes WHERE index_name IN (
    'IDX_FUNCION_FECHA', 'IDX_FUNCION_PELICULA', 'IDX_FUNCION_SALA',
    'IDX_RESERVA_USUARIO', 'IDX_RESERVA_FUNCION',
    'IDX_RESERVA_ASIENTO_FUNCION', 'IDX_ASIENTO_SALA');

EXIT;
