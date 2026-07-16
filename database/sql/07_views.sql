-- ============================================================================
-- Cine Zaror — 07_views.sql
-- Vistas de consulta del sistema.
-- Fuente: docs/04-objetos-oracle.md (sección 6)
-- ============================================================================

-- ----------------------------------------------------------------------------
-- VW_CARTELERA
-- Películas y funciones vigentes con asientos disponibles.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW VW_CARTELERA AS
SELECT
    F.ID_FUNCION,
    P.ID_PELICULA,
    P.TITULO,
    P.CLASIFICACION,
    P.DURACION_MINUTOS,
    P.GENERO,
    S.ID_SALA,
    S.NOMBRE AS SALA,
    TRUNC(F.FECHA_HORA) AS FECHA,
    TO_CHAR(F.FECHA_HORA, 'HH24:MI') AS HORA,
    F.FECHA_HORA,
    F.PRECIO,
    FN_CANTIDAD_ASIENTOS_DISPONIBLES(F.ID_FUNCION) AS ASIENTOS_DISPONIBLES
FROM   FUNCION  F
JOIN   PELICULA P ON P.ID_PELICULA = F.ID_PELICULA
JOIN   SALA     S ON S.ID_SALA     = F.ID_SALA
WHERE  F.ACTIVA = 1
  AND  P.ACTIVA = 1
  AND  S.ACTIVA = 1
  AND  F.FECHA_HORA > SYSTIMESTAMP;

-- ----------------------------------------------------------------------------
-- VW_ASIENTOS_FUNCION
-- Todos los asientos de una función con su estado.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW VW_ASIENTOS_FUNCION AS
SELECT
    F.ID_FUNCION,
    S.NOMBRE AS SALA,
    A.ID_ASIENTO,
    A.FILA,
    A.NUMERO,
    CASE
        WHEN A.ACTIVO = 0 THEN 'INACTIVO'
        WHEN FN_ASIENTO_DISPONIBLE(F.ID_FUNCION, A.ID_ASIENTO) = 0 THEN 'OCUPADO'
        ELSE 'DISPONIBLE'
    END AS ESTADO
FROM   FUNCION F
JOIN   SALA    S ON S.ID_SALA = F.ID_SALA
JOIN   ASIENTO A ON A.ID_SALA = F.ID_SALA;

-- ----------------------------------------------------------------------------
-- VW_RESERVAS_USUARIO
-- Resumen de reservas por usuario.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW VW_RESERVAS_USUARIO AS
SELECT
    R.ID_RESERVA,
    R.CODIGO,
    R.ID_USUARIO,
    U.NOMBRE_COMPLETO AS USUARIO,
    P.TITULO AS PELICULA,
    F.FECHA_HORA,
    S.NOMBRE AS SALA,
    ER.NOMBRE AS ESTADO,
    R.CANTIDAD_ENTRADAS,
    R.TOTAL,
    R.FECHA_CREACION,
    (
        SELECT LISTAGG(A.FILA || A.NUMERO, ', ') WITHIN GROUP (ORDER BY A.FILA, A.NUMERO)
        FROM   RESERVA_ASIENTO RA
        JOIN   ASIENTO A ON A.ID_ASIENTO = RA.ID_ASIENTO
        WHERE  RA.ID_RESERVA = R.ID_RESERVA
    ) AS ASIENTOS
FROM   RESERVA         R
JOIN   USUARIO         U  ON U.ID_USUARIO  = R.ID_USUARIO
JOIN   FUNCION         F  ON F.ID_FUNCION  = R.ID_FUNCION
JOIN   PELICULA        P  ON P.ID_PELICULA = F.ID_PELICULA
JOIN   SALA            S  ON S.ID_SALA     = F.ID_SALA
JOIN   ESTADO_RESERVA  ER ON ER.ID_ESTADO  = R.ID_ESTADO;

-- ----------------------------------------------------------------------------
-- VW_RESERVAS_ADMIN
-- Vista administrativa con datos completos.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE VIEW VW_RESERVAS_ADMIN AS
SELECT
    R.ID_RESERVA,
    R.CODIGO,
    R.ID_USUARIO,
    U.NOMBRE_COMPLETO AS USUARIO,
    U.CORREO,
    U.RUT,
    P.TITULO AS PELICULA,
    F.ID_FUNCION,
    F.FECHA_HORA,
    S.NOMBRE AS SALA,
    ER.NOMBRE AS ESTADO,
    R.CANTIDAD_ENTRADAS,
    R.TOTAL,
    R.FECHA_CREACION,
    R.FECHA_ACTUALIZACION,
    PG.ID_PAGO,
    PG.METODO,
    PG.MONTO AS MONTO_PAGADO,
    PG.ESTADO AS ESTADO_PAGO,
    PG.CODIGO_OPERACION,
    PG.FECHA_PAGO
FROM   RESERVA         R
JOIN   USUARIO         U  ON U.ID_USUARIO  = R.ID_USUARIO
JOIN   FUNCION         F  ON F.ID_FUNCION  = R.ID_FUNCION
JOIN   PELICULA        P  ON P.ID_PELICULA = F.ID_PELICULA
JOIN   SALA            S  ON S.ID_SALA     = F.ID_SALA
JOIN   ESTADO_RESERVA  ER ON ER.ID_ESTADO  = R.ID_ESTADO
LEFT JOIN PAGO         PG ON PG.ID_RESERVA = R.ID_RESERVA;
