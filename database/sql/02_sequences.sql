-- ============================================================================
-- Cine Zaror — 02_sequences.sql
-- Secuencias para generación de identificadores de tablas.
-- Fuente: docs/04-objetos-oracle.md (sección 2)
-- ============================================================================
-- Nota: NOCACHE evita huecos en IDs ante reinicios; adecuado para entorno académico.
-- ============================================================================

CREATE SEQUENCE SEQ_ROL
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE SEQ_USUARIO
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE SEQ_PELICULA
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE SEQ_SALA
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE SEQ_ASIENTO
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE SEQ_FUNCION
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE SEQ_ESTADO_RESERVA
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE SEQ_RESERVA
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE SEQ_RESERVA_ASIENTO
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE SEQ_PAGO
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;

CREATE SEQUENCE SEQ_AUDITORIA_RESERVA
    START WITH 1
    INCREMENT BY 1
    NOCACHE
    NOCYCLE;
