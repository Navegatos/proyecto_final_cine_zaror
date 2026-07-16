-- ============================================================================
-- Cine Zaror — 05_procedures.sql
-- Procedimientos almacenados del sistema.
-- Fuente: docs/04-objetos-oracle.md, docs/02-reglas-negocio.md
-- ============================================================================
-- Errores de reserva: rango -20040 a -20059 (docs/04-objetos-oracle.md)
-- ============================================================================

-- Tipo auxiliar para recibir lista de IDs de asientos desde Spring/JDBC.
-- Justificación: la API recibe un arreglo de asientoIds (docs/06-api-rest.md).
CREATE OR REPLACE TYPE T_LISTA_ID AS TABLE OF NUMBER;
/

-- ----------------------------------------------------------------------------
-- SP_CREAR_RESERVA
-- Crea una reserva PENDIENTE con sus asientos en una única transacción.
-- RN-22 a RN-35
--
-- Concurrencia:
--   1. SELECT FOR UPDATE sobre FUNCION y ASIENTO (orden ascendente por ID).
--   2. Revalidación de disponibilidad dentro de la transacción (RN-25, RN-34).
--   3. UQ_RESERVA_ASIENTO_FUNCION_ASIENTO como barrera final ante carrera (RN-33, RN-35).
--   4. Sin COMMIT interno: Spring Boot controla la transacción (docs/04-objetos-oracle.md).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_CREAR_RESERVA (
    P_ID_USUARIO IN  NUMBER,
    P_ID_FUNCION IN  NUMBER,
    P_ASIENTOS   IN  T_LISTA_ID,
    P_ID_RESERVA OUT NUMBER,
    P_CODIGO     OUT VARCHAR2,
    P_TOTAL      OUT NUMBER
)
IS
    V_ACTIVO_USUARIO   NUMBER;
    V_PRECIO_FUNCION   FUNCION.PRECIO%TYPE;
    V_ID_SALA_FUNCION  FUNCION.ID_SALA%TYPE;
    V_ID_ESTADO_PEND   ESTADO_RESERVA.ID_ESTADO%TYPE;
    V_CANTIDAD         NUMBER;
    V_DUPLICADOS       NUMBER;
    V_ID_ASIENTO       NUMBER;
    V_DISPONIBLE       NUMBER;
    V_ID_SALA_ASIENTO  ASIENTO.ID_SALA%TYPE;
    V_ACTIVO_ASIENTO   ASIENTO.ACTIVO%TYPE;
BEGIN
    -- ------------------------------------------------------------------
    -- Validar parámetros de entrada
    -- ------------------------------------------------------------------
    IF P_ID_USUARIO IS NULL THEN
        RAISE_APPLICATION_ERROR(-20040, 'El usuario es obligatorio');
    END IF;

    IF P_ID_FUNCION IS NULL THEN
        RAISE_APPLICATION_ERROR(-20042, 'La función es obligatoria');
    END IF;

    IF P_ASIENTOS IS NULL OR P_ASIENTOS.COUNT = 0 THEN
        RAISE_APPLICATION_ERROR(-20044, 'Debe seleccionar al menos un asiento');
    END IF;

    -- ------------------------------------------------------------------
    -- 1. Validar usuario (RN-04, RN-05)
    -- ------------------------------------------------------------------
    BEGIN
        SELECT U.ACTIVO
        INTO   V_ACTIVO_USUARIO
        FROM   USUARIO U
        WHERE  U.ID_USUARIO = P_ID_USUARIO;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20040, 'Usuario no encontrado');
    END;

    IF V_ACTIVO_USUARIO <> 1 THEN
        RAISE_APPLICATION_ERROR(-20041, 'El usuario está inactivo');
    END IF;

    -- ------------------------------------------------------------------
    -- 2. Validar función vigente (RN-15, RN-19, RN-21)
    --    Bloqueo de fila para serializar reservas concurrentes en la función.
    -- ------------------------------------------------------------------
    BEGIN
        SELECT F.PRECIO, F.ID_SALA
        INTO   V_PRECIO_FUNCION, V_ID_SALA_FUNCION
        FROM   FUNCION F
        WHERE  F.ID_FUNCION = P_ID_FUNCION
        FOR UPDATE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20042, 'Función no encontrada');
    END;

    IF FN_FUNCION_VIGENTE(P_ID_FUNCION) = 0 THEN
        RAISE_APPLICATION_ERROR(-20043, 'La función no está vigente o ya comenzó');
    END IF;

    -- ------------------------------------------------------------------
    -- 3. Validar asientos de la solicitud (RN-23, RN-24, RN-13)
    -- ------------------------------------------------------------------
    V_CANTIDAD := P_ASIENTOS.COUNT;

    -- Detectar IDs duplicados en la lista enviada por el cliente
    SELECT COUNT(*)
    INTO   V_DUPLICADOS
    FROM   (
        SELECT COLUMN_VALUE
        FROM   TABLE(P_ASIENTOS)
        GROUP BY COLUMN_VALUE
        HAVING COUNT(*) > 1
    );

    IF V_DUPLICADOS > 0 THEN
        RAISE_APPLICATION_ERROR(-20048, 'La solicitud contiene asientos duplicados');
    END IF;

    -- Bloquear asientos en orden fijo para reducir deadlocks (RN-33, RN-34)
    FOR REC_ASIENTO IN (
        SELECT A.ID_ASIENTO
        FROM   ASIENTO A
        WHERE  A.ID_ASIENTO IN (SELECT COLUMN_VALUE FROM TABLE(P_ASIENTOS))
        ORDER BY A.ID_ASIENTO
        FOR UPDATE
    ) LOOP
        NULL;
    END LOOP;

    -- Validar existencia, sala, estado activo y disponibilidad (RN-25, RN-31, RN-32)
    FOR I IN 1 .. P_ASIENTOS.COUNT LOOP
        V_ID_ASIENTO := P_ASIENTOS(I);

        BEGIN
            SELECT A.ID_SALA, A.ACTIVO
            INTO   V_ID_SALA_ASIENTO, V_ACTIVO_ASIENTO
            FROM   ASIENTO A
            WHERE  A.ID_ASIENTO = V_ID_ASIENTO;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE_APPLICATION_ERROR(-20047, 'Asiento no encontrado: ' || V_ID_ASIENTO);
        END;

        IF V_ACTIVO_ASIENTO <> 1 THEN
            RAISE_APPLICATION_ERROR(-20047, 'El asiento ' || V_ID_ASIENTO || ' está inactivo');
        END IF;

        IF V_ID_SALA_ASIENTO <> V_ID_SALA_FUNCION THEN
            RAISE_APPLICATION_ERROR(-20046,
                'El asiento ' || V_ID_ASIENTO || ' no pertenece a la sala de la función');
        END IF;

        V_DISPONIBLE := FN_ASIENTO_DISPONIBLE(P_ID_FUNCION, V_ID_ASIENTO);

        IF V_DISPONIBLE = 0 THEN
            RAISE_APPLICATION_ERROR(-20045,
                'El asiento ' || V_ID_ASIENTO || ' ya no está disponible');
        END IF;
    END LOOP;

    -- Verificar que se bloquearon todos los asientos solicitados
    SELECT COUNT(DISTINCT A.ID_ASIENTO)
    INTO   V_DUPLICADOS
    FROM   ASIENTO A
    WHERE  A.ID_ASIENTO IN (SELECT COLUMN_VALUE FROM TABLE(P_ASIENTOS));

    IF V_DUPLICADOS <> V_CANTIDAD THEN
        RAISE_APPLICATION_ERROR(-20047, 'Uno o más asientos de la solicitud no existen');
    END IF;

    -- ------------------------------------------------------------------
    -- Obtener estado PENDIENTE (RN-28)
    -- ------------------------------------------------------------------
    BEGIN
        SELECT ER.ID_ESTADO
        INTO   V_ID_ESTADO_PEND
        FROM   ESTADO_RESERVA ER
        WHERE  ER.NOMBRE = 'PENDIENTE';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20049, 'Estado PENDIENTE no configurado en el catálogo');
    END;

    -- ------------------------------------------------------------------
    -- 4. Calcular total en Oracle (RN-26, RN-27)
    -- ------------------------------------------------------------------
    P_TOTAL := FN_CALCULAR_TOTAL_RESERVA(V_PRECIO_FUNCION, V_CANTIDAD);

    IF P_TOTAL <= 0 THEN
        RAISE_APPLICATION_ERROR(-20044, 'No fue posible calcular un total válido para la reserva');
    END IF;

    -- ------------------------------------------------------------------
    -- 5. Insertar reserva y detalle de asientos
    -- ------------------------------------------------------------------
    P_ID_RESERVA := SEQ_RESERVA.NEXTVAL;

    P_CODIGO := 'ZAR-'
        || TO_CHAR(SYSDATE, 'YYYYMMDD')
        || '-'
        || LPAD(TO_CHAR(P_ID_RESERVA), 5, '0');

    INSERT INTO RESERVA (
        ID_RESERVA,
        CODIGO,
        ID_USUARIO,
        ID_FUNCION,
        ID_ESTADO,
        CANTIDAD_ENTRADAS,
        TOTAL
    ) VALUES (
        P_ID_RESERVA,
        P_CODIGO,
        P_ID_USUARIO,
        P_ID_FUNCION,
        V_ID_ESTADO_PEND,
        V_CANTIDAD,
        P_TOTAL
    );

    FOR I IN 1 .. P_ASIENTOS.COUNT LOOP
        BEGIN
            INSERT INTO RESERVA_ASIENTO (
                ID_RESERVA_ASIENTO,
                ID_RESERVA,
                ID_FUNCION,
                ID_ASIENTO,
                PRECIO_UNITARIO
            ) VALUES (
                SEQ_RESERVA_ASIENTO.NEXTVAL,
                P_ID_RESERVA,
                P_ID_FUNCION,
                P_ASIENTOS(I),
                V_PRECIO_FUNCION
            );
        EXCEPTION
            WHEN DUP_VAL_ON_INDEX THEN
                -- Barrera final ante condición de carrera (RN-33, RN-35)
                RAISE_APPLICATION_ERROR(-20045,
                    'El asiento ' || P_ASIENTOS(I) || ' fue reservado por otra transacción');
        END;
    END LOOP;

EXCEPTION
    WHEN OTHERS THEN
        -- Propagar errores de aplicación; envolver errores inesperados
        IF SQLCODE BETWEEN -20059 AND -20040 THEN
            RAISE;
        END IF;
        RAISE_APPLICATION_ERROR(-20059, 'Error inesperado al crear reserva: ' || SQLERRM);
END SP_CREAR_RESERVA;
/

-- ----------------------------------------------------------------------------
-- SP_REGISTRAR_USUARIO
-- RN-01, RN-02, RN-03, RN-05
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_REGISTRAR_USUARIO (
    P_RUT             IN  VARCHAR2,
    P_NOMBRE_COMPLETO IN  VARCHAR2,
    P_CORREO          IN  VARCHAR2,
    P_PASSWORD_HASH   IN  VARCHAR2,
    P_ID_USUARIO      OUT NUMBER
)
IS
    V_ID_ROL_CLIENTE NUMBER;
    V_CORREO_NORM    VARCHAR2(150) := LOWER(TRIM(P_CORREO));
    V_EXISTE         NUMBER;
BEGIN
    IF P_RUT IS NULL OR P_NOMBRE_COMPLETO IS NULL OR P_CORREO IS NULL OR P_PASSWORD_HASH IS NULL THEN
        RAISE_APPLICATION_ERROR(-20001, 'Todos los campos son obligatorios');
    END IF;

    SELECT COUNT(*) INTO V_EXISTE FROM USUARIO WHERE RUT = P_RUT;
    IF V_EXISTE > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'El RUT ya está registrado');
    END IF;

    SELECT COUNT(*) INTO V_EXISTE FROM USUARIO WHERE CORREO = V_CORREO_NORM;
    IF V_EXISTE > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'El correo ya está registrado');
    END IF;

    BEGIN
        SELECT ID_ROL INTO V_ID_ROL_CLIENTE FROM ROL WHERE NOMBRE = 'CLIENTE';
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20009, 'Rol CLIENTE no configurado');
    END;

    P_ID_USUARIO := SEQ_USUARIO.NEXTVAL;

    INSERT INTO USUARIO (ID_USUARIO, ID_ROL, RUT, NOMBRE_COMPLETO, CORREO, PASSWORD_HASH, ACTIVO)
    VALUES (P_ID_USUARIO, V_ID_ROL_CLIENTE, P_RUT, P_NOMBRE_COMPLETO, V_CORREO_NORM, P_PASSWORD_HASH, 1);
END SP_REGISTRAR_USUARIO;
/

-- ----------------------------------------------------------------------------
-- SP_CREAR_PELICULA
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_CREAR_PELICULA (
    P_TITULO           IN  VARCHAR2,
    P_SINOPSIS         IN  VARCHAR2,
    P_DURACION_MINUTOS IN  NUMBER,
    P_CLASIFICACION    IN  VARCHAR2,
    P_GENERO           IN  VARCHAR2,
    P_URL_IMAGEN       IN  VARCHAR2,
    P_ID_PELICULA      OUT NUMBER
)
IS
BEGIN
    IF P_TITULO IS NULL OR P_DURACION_MINUTOS IS NULL OR P_CLASIFICACION IS NULL THEN
        RAISE_APPLICATION_ERROR(-20010, 'Título, duración y clasificación son obligatorios');
    END IF;

    IF P_DURACION_MINUTOS <= 0 THEN
        RAISE_APPLICATION_ERROR(-20011, 'La duración debe ser mayor a 0');
    END IF;

    P_ID_PELICULA := SEQ_PELICULA.NEXTVAL;

    INSERT INTO PELICULA (ID_PELICULA, TITULO, SINOPSIS, DURACION_MINUTOS, CLASIFICACION, GENERO, URL_IMAGEN, ACTIVA)
    VALUES (P_ID_PELICULA, P_TITULO, P_SINOPSIS, P_DURACION_MINUTOS, P_CLASIFICACION, P_GENERO, P_URL_IMAGEN, 1);
END SP_CREAR_PELICULA;
/

-- ----------------------------------------------------------------------------
-- SP_CREAR_SALA
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_CREAR_SALA (
    P_NOMBRE   IN  VARCHAR2,
    P_FILAS    IN  NUMBER,
    P_COLUMNAS IN  NUMBER,
    P_ID_SALA  OUT NUMBER
)
IS
BEGIN
    IF P_NOMBRE IS NULL OR P_FILAS IS NULL OR P_COLUMNAS IS NULL THEN
        RAISE_APPLICATION_ERROR(-20020, 'Nombre, filas y columnas son obligatorios');
    END IF;

    IF P_FILAS <= 0 OR P_COLUMNAS <= 0 THEN
        RAISE_APPLICATION_ERROR(-20021, 'Filas y columnas deben ser mayores a 0');
    END IF;

    P_ID_SALA := SEQ_SALA.NEXTVAL;

    INSERT INTO SALA (ID_SALA, NOMBRE, FILAS, COLUMNAS, ACTIVA)
    VALUES (P_ID_SALA, P_NOMBRE, P_FILAS, P_COLUMNAS, 1);
END SP_CREAR_SALA;
/

-- ----------------------------------------------------------------------------
-- SP_GENERAR_ASIENTOS_SALA
-- Genera asientos: Fila A.., números 1..columnas.
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_GENERAR_ASIENTOS_SALA (
    P_ID_SALA IN NUMBER
)
IS
    V_FILAS    NUMBER;
    V_COLUMNAS NUMBER;
    V_FILA     VARCHAR2(5);
    V_EXISTE   NUMBER;
BEGIN
    SELECT FILAS, COLUMNAS INTO V_FILAS, V_COLUMNAS
    FROM   SALA WHERE ID_SALA = P_ID_SALA;

    IF V_FILAS IS NULL THEN
        RAISE_APPLICATION_ERROR(-20022, 'Sala no encontrada');
    END IF;

    SELECT COUNT(*) INTO V_EXISTE FROM ASIENTO WHERE ID_SALA = P_ID_SALA;
    IF V_EXISTE > 0 THEN
        RAISE_APPLICATION_ERROR(-20023, 'La sala ya tiene asientos generados');
    END IF;

    FOR F IN 1 .. V_FILAS LOOP
        V_FILA := CHR(64 + F);
        FOR C IN 1 .. V_COLUMNAS LOOP
            INSERT INTO ASIENTO (ID_ASIENTO, ID_SALA, FILA, NUMERO, ACTIVO)
            VALUES (SEQ_ASIENTO.NEXTVAL, P_ID_SALA, V_FILA, C, 1);
        END LOOP;
    END LOOP;
END SP_GENERAR_ASIENTOS_SALA;
/

-- ----------------------------------------------------------------------------
-- SP_CREAR_FUNCION
-- RN-14 a RN-18
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_CREAR_FUNCION (
    P_ID_PELICULA IN  NUMBER,
    P_ID_SALA     IN  NUMBER,
    P_FECHA_HORA  IN  TIMESTAMP,
    P_PRECIO      IN  NUMBER,
    P_ID_FUNCION  OUT NUMBER
)
IS
    V_ACTIVA_PEL NUMBER;
    V_ACTIVA_SAL NUMBER;
BEGIN
    IF P_ID_PELICULA IS NULL OR P_ID_SALA IS NULL OR P_FECHA_HORA IS NULL OR P_PRECIO IS NULL THEN
        RAISE_APPLICATION_ERROR(-20030, 'Todos los campos son obligatorios');
    END IF;

    IF P_PRECIO <= 0 THEN
        RAISE_APPLICATION_ERROR(-20031, 'El precio debe ser mayor a 0');
    END IF;

    IF P_FECHA_HORA <= SYSTIMESTAMP THEN
        RAISE_APPLICATION_ERROR(-20032, 'La fecha y hora deben ser futuras');
    END IF;

    SELECT ACTIVA INTO V_ACTIVA_PEL FROM PELICULA WHERE ID_PELICULA = P_ID_PELICULA;
    IF V_ACTIVA_PEL <> 1 THEN
        RAISE_APPLICATION_ERROR(-20033, 'La película no está activa');
    END IF;

    SELECT ACTIVA INTO V_ACTIVA_SAL FROM SALA WHERE ID_SALA = P_ID_SALA;
    IF V_ACTIVA_SAL <> 1 THEN
        RAISE_APPLICATION_ERROR(-20034, 'La sala no está activa');
    END IF;

    IF FN_EXISTE_SUPERPOSICION_FUNCION(P_ID_SALA, P_ID_PELICULA, P_FECHA_HORA) = 1 THEN
        RAISE_APPLICATION_ERROR(-20035, 'Existe superposición de horario en la sala');
    END IF;

    P_ID_FUNCION := SEQ_FUNCION.NEXTVAL;

    INSERT INTO FUNCION (ID_FUNCION, ID_PELICULA, ID_SALA, FECHA_HORA, PRECIO, ACTIVA)
    VALUES (P_ID_FUNCION, P_ID_PELICULA, P_ID_SALA, P_FECHA_HORA, P_PRECIO, 1);
END SP_CREAR_FUNCION;
/

-- ----------------------------------------------------------------------------
-- SP_CONFIRMAR_PAGO
-- RN-36 a RN-39
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_CONFIRMAR_PAGO (
    P_ID_RESERVA       IN  NUMBER,
    P_METODO           IN  VARCHAR2,
    P_ID_PAGO          OUT NUMBER,
    P_CODIGO_OPERACION OUT VARCHAR2
)
IS
    V_TOTAL           RESERVA.TOTAL%TYPE;
    V_ID_ESTADO       RESERVA.ID_ESTADO%TYPE;
    V_NOMBRE_ESTADO   ESTADO_RESERVA.NOMBRE%TYPE;
    V_ID_ESTADO_PAG   ESTADO_RESERVA.ID_ESTADO%TYPE;
    V_PAGO_EXISTE     NUMBER;
BEGIN
    BEGIN
        SELECT R.TOTAL, R.ID_ESTADO, ER.NOMBRE
        INTO   V_TOTAL, V_ID_ESTADO, V_NOMBRE_ESTADO
        FROM   RESERVA R
        JOIN   ESTADO_RESERVA ER ON ER.ID_ESTADO = R.ID_ESTADO
        WHERE  R.ID_RESERVA = P_ID_RESERVA
        FOR UPDATE;
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20040, 'Reserva no encontrada');
    END;

    IF V_NOMBRE_ESTADO = 'PAGADA' THEN
        RAISE_APPLICATION_ERROR(-20029, 'La reserva ya está pagada');
    END IF;

    IF V_NOMBRE_ESTADO <> 'PENDIENTE' THEN
        RAISE_APPLICATION_ERROR(-20028, 'La reserva no está pendiente de pago');
    END IF;

    SELECT COUNT(*) INTO V_PAGO_EXISTE FROM PAGO WHERE ID_RESERVA = P_ID_RESERVA;
    IF V_PAGO_EXISTE > 0 THEN
        RAISE_APPLICATION_ERROR(-20060, 'La reserva ya tiene un pago registrado');
    END IF;

    SELECT ID_ESTADO INTO V_ID_ESTADO_PAG FROM ESTADO_RESERVA WHERE NOMBRE = 'PAGADA';

    P_ID_PAGO := SEQ_PAGO.NEXTVAL;
    P_CODIGO_OPERACION := 'PAG-' || TO_CHAR(SYSDATE, 'YYYYMMDD') || '-' || LPAD(TO_CHAR(P_ID_PAGO), 5, '0');

    INSERT INTO PAGO (ID_PAGO, ID_RESERVA, METODO, MONTO, ESTADO, CODIGO_OPERACION)
    VALUES (P_ID_PAGO, P_ID_RESERVA, P_METODO, V_TOTAL, 'APROBADO', P_CODIGO_OPERACION);

    UPDATE RESERVA
    SET    ID_ESTADO = V_ID_ESTADO_PAG,
           FECHA_ACTUALIZACION = SYSTIMESTAMP
    WHERE  ID_RESERVA = P_ID_RESERVA;
END SP_CONFIRMAR_PAGO;
/

-- ----------------------------------------------------------------------------
-- SP_ANULAR_RESERVA
-- Cambia estado a ANULADA; libera asientos (RN-30).
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_ANULAR_RESERVA (
    P_ID_RESERVA IN NUMBER
)
IS
    V_NOMBRE_ESTADO ESTADO_RESERVA.NOMBRE%TYPE;
    V_ID_ESTADO_ANU ESTADO_RESERVA.ID_ESTADO%TYPE;
BEGIN
    SELECT ER.NOMBRE
    INTO   V_NOMBRE_ESTADO
    FROM   RESERVA R
    JOIN   ESTADO_RESERVA ER ON ER.ID_ESTADO = R.ID_ESTADO
    WHERE  R.ID_RESERVA = P_ID_RESERVA;

    IF V_NOMBRE_ESTADO = 'ANULADA' THEN
        RAISE_APPLICATION_ERROR(-20027, 'La reserva ya está anulada');
    END IF;

    IF V_NOMBRE_ESTADO = 'PAGADA' THEN
        RAISE_APPLICATION_ERROR(-20026, 'No se puede anular una reserva pagada');
    END IF;

    SELECT ID_ESTADO INTO V_ID_ESTADO_ANU FROM ESTADO_RESERVA WHERE NOMBRE = 'ANULADA';

    UPDATE RESERVA
    SET    ID_ESTADO = V_ID_ESTADO_ANU,
           FECHA_ACTUALIZACION = SYSTIMESTAMP
    WHERE  ID_RESERVA = P_ID_RESERVA;
END SP_ANULAR_RESERVA;
/

-- ----------------------------------------------------------------------------
-- SP_DESACTIVAR_FUNCION
-- ----------------------------------------------------------------------------
CREATE OR REPLACE PROCEDURE SP_DESACTIVAR_FUNCION (
    P_ID_FUNCION IN NUMBER
)
IS
    V_ACTIVA NUMBER;
BEGIN
    SELECT ACTIVA INTO V_ACTIVA FROM FUNCION WHERE ID_FUNCION = P_ID_FUNCION;

    IF V_ACTIVA = 0 THEN
        RAISE_APPLICATION_ERROR(-20036, 'La función ya está desactivada');
    END IF;

    UPDATE FUNCION SET ACTIVA = 0 WHERE ID_FUNCION = P_ID_FUNCION;
END SP_DESACTIVAR_FUNCION;
/
