-- ============================================================================
-- Cine Zaror — 04_functions.sql
-- Funciones PL/SQL de apoyo para reservas y funciones.
-- Fuente: docs/04-objetos-oracle.md
-- ============================================================================

-- ----------------------------------------------------------------------------
-- FN_FUNCION_VIGENTE
-- Valida que la función esté activa, con película/sala activas y no iniciada.
-- RN-15, RN-19, RN-21
-- Retorna: 1 = vigente, 0 = no vigente.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION FN_FUNCION_VIGENTE (
    P_ID_FUNCION IN NUMBER
) RETURN NUMBER
IS
    V_VIGENTE NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO   V_VIGENTE
    FROM   FUNCION  F
    JOIN   PELICULA P ON P.ID_PELICULA = F.ID_PELICULA
    JOIN   SALA     S ON S.ID_SALA     = F.ID_SALA
    WHERE  F.ID_FUNCION = P_ID_FUNCION
      AND  F.ACTIVA     = 1
      AND  P.ACTIVA     = 1
      AND  S.ACTIVA     = 1
      AND  F.FECHA_HORA > SYSTIMESTAMP;

    RETURN CASE WHEN V_VIGENTE > 0 THEN 1 ELSE 0 END;
END FN_FUNCION_VIGENTE;
/

-- ----------------------------------------------------------------------------
-- FN_ASIENTO_DISPONIBLE
-- Determina si un asiento está disponible para una función.
-- RN-31, RN-32: ocupado si existe en reserva PENDIENTE o PAGADA.
-- Retorna: 1 = disponible, 0 = ocupado o inválido.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION FN_ASIENTO_DISPONIBLE (
    P_ID_FUNCION IN NUMBER,
    P_ID_ASIENTO IN NUMBER
) RETURN NUMBER
IS
    V_OCUPADO NUMBER;
BEGIN
    -- El asiento debe existir, estar activo y pertenecer a la sala de la función
    SELECT COUNT(*)
    INTO   V_OCUPADO
    FROM   ASIENTO A
    JOIN   FUNCION F ON F.ID_SALA = A.ID_SALA
    WHERE  A.ID_ASIENTO = P_ID_ASIENTO
      AND  F.ID_FUNCION = P_ID_FUNCION
      AND  A.ACTIVO     = 1;

    IF V_OCUPADO = 0 THEN
        RETURN 0;
    END IF;

    -- Verificar ocupación por reservas vigentes (PENDIENTE o PAGADA)
    SELECT COUNT(*)
    INTO   V_OCUPADO
    FROM   RESERVA_ASIENTO RA
    JOIN   RESERVA         R  ON R.ID_RESERVA  = RA.ID_RESERVA
    JOIN   ESTADO_RESERVA  ER ON ER.ID_ESTADO  = R.ID_ESTADO
    WHERE  RA.ID_FUNCION = P_ID_FUNCION
      AND  RA.ID_ASIENTO = P_ID_ASIENTO
      AND  ER.NOMBRE    IN ('PENDIENTE', 'PAGADA');

    RETURN CASE WHEN V_OCUPADO = 0 THEN 1 ELSE 0 END;
END FN_ASIENTO_DISPONIBLE;
/

-- ----------------------------------------------------------------------------
-- FN_CALCULAR_TOTAL_RESERVA
-- Calcula el total: cantidad de asientos × precio unitario de la función.
-- RN-26
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION FN_CALCULAR_TOTAL_RESERVA (
    P_PRECIO_UNITARIO   IN NUMBER,
    P_CANTIDAD_ASIENTOS IN NUMBER
) RETURN NUMBER
IS
BEGIN
    IF P_CANTIDAD_ASIENTOS IS NULL OR P_CANTIDAD_ASIENTOS <= 0 THEN
        RETURN 0;
    END IF;

    IF P_PRECIO_UNITARIO IS NULL OR P_PRECIO_UNITARIO <= 0 THEN
        RETURN 0;
    END IF;

    RETURN P_PRECIO_UNITARIO * P_CANTIDAD_ASIENTOS;
END FN_CALCULAR_TOTAL_RESERVA;
/

-- ----------------------------------------------------------------------------
-- FN_CANTIDAD_ASIENTOS_DISPONIBLES
-- Retorna la cantidad de asientos disponibles para una función.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION FN_CANTIDAD_ASIENTOS_DISPONIBLES (
    P_ID_FUNCION IN NUMBER
) RETURN NUMBER
IS
    V_DISPONIBLES NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO   V_DISPONIBLES
    FROM   ASIENTO A
    JOIN   FUNCION F ON F.ID_SALA = A.ID_SALA
    WHERE  F.ID_FUNCION = P_ID_FUNCION
      AND  A.ACTIVO = 1
      AND  FN_ASIENTO_DISPONIBLE(P_ID_FUNCION, A.ID_ASIENTO) = 1;

    RETURN NVL(V_DISPONIBLES, 0);
END FN_CANTIDAD_ASIENTOS_DISPONIBLES;
/

-- ----------------------------------------------------------------------------
-- FN_EXISTE_SUPERPOSICION_FUNCION
-- Valida superposición de horario en una sala (RN-17, RN-18).
-- Margen de limpieza: 20 minutos.
-- Retorna: 1 = existe superposición, 0 = no hay conflicto.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE FUNCTION FN_EXISTE_SUPERPOSICION_FUNCION (
    P_ID_SALA           IN NUMBER,
    P_ID_PELICULA       IN NUMBER,
    P_FECHA_HORA        IN TIMESTAMP,
    P_ID_FUNCION_EXCLUIR IN NUMBER DEFAULT NULL
) RETURN NUMBER
IS
    V_DURACION    PELICULA.DURACION_MINUTOS%TYPE;
    V_MARGEN_MIN  NUMBER := 20;
    V_INICIO_NUEVA TIMESTAMP;
    V_FIN_NUEVA    TIMESTAMP;
    V_CONFLICTOS   NUMBER;
BEGIN
    SELECT P.DURACION_MINUTOS
    INTO   V_DURACION
    FROM   PELICULA P
    WHERE  P.ID_PELICULA = P_ID_PELICULA;

    V_INICIO_NUEVA := P_FECHA_HORA;
    V_FIN_NUEVA    := P_FECHA_HORA + NUMTODSINTERVAL(V_DURACION + V_MARGEN_MIN, 'MINUTE');

    SELECT COUNT(*)
    INTO   V_CONFLICTOS
    FROM   FUNCION F
    JOIN   PELICULA P ON P.ID_PELICULA = F.ID_PELICULA
    WHERE  F.ID_SALA = P_ID_SALA
      AND  F.ACTIVA = 1
      AND  (P_ID_FUNCION_EXCLUIR IS NULL OR F.ID_FUNCION <> P_ID_FUNCION_EXCLUIR)
      AND  F.FECHA_HORA < V_FIN_NUEVA
      AND  (F.FECHA_HORA + NUMTODSINTERVAL(P.DURACION_MINUTOS + V_MARGEN_MIN, 'MINUTE')) > V_INICIO_NUEVA;

    RETURN CASE WHEN V_CONFLICTOS > 0 THEN 1 ELSE 0 END;
END FN_EXISTE_SUPERPOSICION_FUNCION;
/
