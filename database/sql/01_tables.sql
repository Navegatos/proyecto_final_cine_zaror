-- ============================================================================
-- Cine Zaror — 01_tables.sql
-- Creación de tablas del modelo relacional.
-- Fuente: docs/03-modelo-datos.md
-- Orden de ejecución: docs/04-objetos-oracle.md
-- ============================================================================
-- Nota: Las restricciones (PK, FK, UNIQUE, CHECK) se definen en 03_constraints.sql
-- ============================================================================

-- ----------------------------------------------------------------------------
-- ROL
-- Catálogo de roles del sistema (ADMIN, CLIENTE).
-- ----------------------------------------------------------------------------
CREATE TABLE ROL (
    ID_ROL      NUMBER          NOT NULL,
    NOMBRE      VARCHAR2(30)    NOT NULL,
    DESCRIPCION VARCHAR2(200)
);

COMMENT ON TABLE ROL IS 'Roles de acceso del sistema (ADMIN, CLIENTE)';
COMMENT ON COLUMN ROL.ID_ROL IS 'Identificador único del rol';
COMMENT ON COLUMN ROL.NOMBRE IS 'Nombre del rol; debe ser único';
COMMENT ON COLUMN ROL.DESCRIPCION IS 'Descripción opcional del rol';

-- ----------------------------------------------------------------------------
-- USUARIO
-- Cuentas de clientes y administradores.
-- ----------------------------------------------------------------------------
CREATE TABLE USUARIO (
    ID_USUARIO      NUMBER          NOT NULL,
    ID_ROL          NUMBER          NOT NULL,
    RUT             VARCHAR2(12)    NOT NULL,
    NOMBRE_COMPLETO VARCHAR2(150)   NOT NULL,
    CORREO          VARCHAR2(150)   NOT NULL,
    PASSWORD_HASH   VARCHAR2(255)   NOT NULL,
    ACTIVO          NUMBER(1)       DEFAULT 1,
    FECHA_CREACION  TIMESTAMP       DEFAULT SYSTIMESTAMP
);

COMMENT ON TABLE USUARIO IS 'Usuarios registrados en el sistema';
COMMENT ON COLUMN USUARIO.ID_ROL IS 'Rol asignado al usuario (FK a ROL)';
COMMENT ON COLUMN USUARIO.RUT IS 'RUT chileno; debe ser único';
COMMENT ON COLUMN USUARIO.CORREO IS 'Correo electrónico; único. Se normaliza vía trigger';
COMMENT ON COLUMN USUARIO.ACTIVO IS '1 = activo, 0 = inactivo (no puede iniciar sesión)';

-- ----------------------------------------------------------------------------
-- PELICULA
-- Catálogo de películas en cartelera.
-- ----------------------------------------------------------------------------
CREATE TABLE PELICULA (
    ID_PELICULA      NUMBER          NOT NULL,
    TITULO           VARCHAR2(150)   NOT NULL,
    SINOPSIS         VARCHAR2(1000),
    DURACION_MINUTOS NUMBER(4)       NOT NULL,
    CLASIFICACION    VARCHAR2(20)    NOT NULL,
    GENERO           VARCHAR2(80),
    URL_IMAGEN       VARCHAR2(500),
    ACTIVA           NUMBER(1)       DEFAULT 1
);

COMMENT ON TABLE PELICULA IS 'Películas disponibles para programar funciones';
COMMENT ON COLUMN PELICULA.DURACION_MINUTOS IS 'Duración en minutos; debe ser mayor a 0';
COMMENT ON COLUMN PELICULA.ACTIVA IS '1 = activa, 0 = desactivada (eliminación lógica)';

-- ----------------------------------------------------------------------------
-- SALA
-- Salas de proyección del cine.
-- ----------------------------------------------------------------------------
CREATE TABLE SALA (
    ID_SALA  NUMBER        NOT NULL,
    NOMBRE   VARCHAR2(80)  NOT NULL,
    FILAS    NUMBER(3)     NOT NULL,
    COLUMNAS NUMBER(3)     NOT NULL,
    ACTIVA   NUMBER(1)     DEFAULT 1
);

COMMENT ON TABLE SALA IS 'Salas de proyección con dimensiones de grilla';
COMMENT ON COLUMN SALA.FILAS IS 'Cantidad de filas de asientos; debe ser > 0';
COMMENT ON COLUMN SALA.COLUMNAS IS 'Cantidad de columnas por fila; debe ser > 0';
COMMENT ON COLUMN SALA.ACTIVA IS '1 = activa, 0 = desactivada (eliminación lógica)';

-- ----------------------------------------------------------------------------
-- ASIENTO
-- Asientos individuales generados por sala.
-- La disponibilidad por función se resuelve en RESERVA_ASIENTO, no aquí.
-- ----------------------------------------------------------------------------
CREATE TABLE ASIENTO (
    ID_ASIENTO NUMBER       NOT NULL,
    ID_SALA    NUMBER       NOT NULL,
    FILA       VARCHAR2(5)  NOT NULL,
    NUMERO     NUMBER(3)    NOT NULL,
    ACTIVO     NUMBER(1)    DEFAULT 1
);

COMMENT ON TABLE ASIENTO IS 'Asientos de cada sala; identificados por fila y número';
COMMENT ON COLUMN ASIENTO.FILA IS 'Etiqueta de fila (ej. A, B, C)';
COMMENT ON COLUMN ASIENTO.NUMERO IS 'Número de asiento dentro de la fila';
COMMENT ON COLUMN ASIENTO.ACTIVO IS '1 = activo, 0 = inactivo (no reservable)';

-- ----------------------------------------------------------------------------
-- FUNCION
-- Proyección programada: película + sala + horario + precio.
-- ----------------------------------------------------------------------------
CREATE TABLE FUNCION (
    ID_FUNCION     NUMBER          NOT NULL,
    ID_PELICULA    NUMBER          NOT NULL,
    ID_SALA        NUMBER          NOT NULL,
    FECHA_HORA     TIMESTAMP       NOT NULL,
    PRECIO         NUMBER(10, 2)   NOT NULL,
    ACTIVA         NUMBER(1)       DEFAULT 1,
    FECHA_CREACION TIMESTAMP       DEFAULT SYSTIMESTAMP
);

COMMENT ON TABLE FUNCION IS 'Funciones de cartelera asociadas a película y sala';
COMMENT ON COLUMN FUNCION.FECHA_HORA IS 'Fecha y hora de inicio de la proyección';
COMMENT ON COLUMN FUNCION.PRECIO IS 'Precio unitario por entrada; debe ser > 0';
COMMENT ON COLUMN FUNCION.ACTIVA IS '1 = activa, 0 = desactivada (eliminación lógica)';

-- ----------------------------------------------------------------------------
-- ESTADO_RESERVA
-- Catálogo de estados: PENDIENTE, PAGADA, ANULADA, VENCIDA.
-- ----------------------------------------------------------------------------
CREATE TABLE ESTADO_RESERVA (
    ID_ESTADO NUMBER        NOT NULL,
    NOMBRE    VARCHAR2(30)  NOT NULL
);

COMMENT ON TABLE ESTADO_RESERVA IS 'Estados posibles de una reserva';
COMMENT ON COLUMN ESTADO_RESERVA.NOMBRE IS 'Nombre del estado; debe ser único';

-- ----------------------------------------------------------------------------
-- RESERVA
-- Reserva de entradas para una función por un usuario.
-- El TOTAL se persiste para conservar el valor histórico de la compra.
-- ----------------------------------------------------------------------------
CREATE TABLE RESERVA (
    ID_RESERVA          NUMBER          NOT NULL,
    CODIGO              VARCHAR2(30)    NOT NULL,
    ID_USUARIO          NUMBER          NOT NULL,
    ID_FUNCION          NUMBER          NOT NULL,
    ID_ESTADO           NUMBER          NOT NULL,
    CANTIDAD_ENTRADAS   NUMBER(3)       NOT NULL,
    TOTAL               NUMBER(12, 2)   NOT NULL,
    FECHA_CREACION      TIMESTAMP       DEFAULT SYSTIMESTAMP,
    FECHA_ACTUALIZACION TIMESTAMP
);

COMMENT ON TABLE RESERVA IS 'Reservas de entradas realizadas por usuarios';
COMMENT ON COLUMN RESERVA.CODIGO IS 'Código legible de la reserva; único';
COMMENT ON COLUMN RESERVA.CANTIDAD_ENTRADAS IS 'Cantidad de entradas; debe ser > 0';
COMMENT ON COLUMN RESERVA.TOTAL IS 'Monto total histórico; calculado en Oracle';

-- ----------------------------------------------------------------------------
-- RESERVA_ASIENTO
-- Detalle de asientos asignados a una reserva.
-- UNIQUE (ID_FUNCION, ID_ASIENTO) evita la venta doble de un asiento.
-- ----------------------------------------------------------------------------
CREATE TABLE RESERVA_ASIENTO (
    ID_RESERVA_ASIENTO NUMBER         NOT NULL,
    ID_RESERVA         NUMBER         NOT NULL,
    ID_FUNCION         NUMBER         NOT NULL,
    ID_ASIENTO         NUMBER         NOT NULL,
    PRECIO_UNITARIO    NUMBER(10, 2)  NOT NULL
);

COMMENT ON TABLE RESERVA_ASIENTO IS 'Asientos reservados por función; protege contra doble venta';
COMMENT ON COLUMN RESERVA_ASIENTO.ID_FUNCION IS 'Función asociada; redundante para validación y unicidad';
COMMENT ON COLUMN RESERVA_ASIENTO.PRECIO_UNITARIO IS 'Precio aplicado al asiento al momento de la reserva';

-- ----------------------------------------------------------------------------
-- PAGO
-- Registro de pago simulado; relación 1:1 con RESERVA.
-- ----------------------------------------------------------------------------
CREATE TABLE PAGO (
    ID_PAGO          NUMBER          NOT NULL,
    ID_RESERVA       NUMBER          NOT NULL,
    METODO           VARCHAR2(30)    NOT NULL,
    MONTO            NUMBER(12, 2)   NOT NULL,
    ESTADO           VARCHAR2(30)    NOT NULL,
    CODIGO_OPERACION VARCHAR2(50)    NOT NULL,
    FECHA_PAGO       TIMESTAMP       DEFAULT SYSTIMESTAMP
);

COMMENT ON TABLE PAGO IS 'Pagos simulados asociados a reservas confirmadas';
COMMENT ON COLUMN PAGO.ID_RESERVA IS 'Reserva pagada; relación 1:1';
COMMENT ON COLUMN PAGO.CODIGO_OPERACION IS 'Código de operación simulada; único';

-- ----------------------------------------------------------------------------
-- AUDITORIA_RESERVA
-- Historial de cambios de estado de reservas.
-- ----------------------------------------------------------------------------
CREATE TABLE AUDITORIA_RESERVA (
    ID_AUDITORIA    NUMBER          NOT NULL,
    ID_RESERVA      NUMBER          NOT NULL,
    ESTADO_ANTERIOR VARCHAR2(30),
    ESTADO_NUEVO    VARCHAR2(30)    NOT NULL,
    FECHA_CAMBIO    TIMESTAMP       DEFAULT SYSTIMESTAMP,
    OBSERVACION     VARCHAR2(500)
);

COMMENT ON TABLE AUDITORIA_RESERVA IS 'Registro de auditoría de cambios de estado en reservas';
COMMENT ON COLUMN AUDITORIA_RESERVA.ESTADO_ANTERIOR IS 'Estado previo al cambio; NULL en creación';
COMMENT ON COLUMN AUDITORIA_RESERVA.ESTADO_NUEVO IS 'Estado resultante del cambio';
