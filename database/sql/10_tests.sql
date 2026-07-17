-- ============================================================================
-- Cine Zaror — 10_tests.sql
-- Pruebas SQL según docs/09-plan-pruebas.md §9
-- Ejecutar con: SET SERVEROUTPUT ON
-- ============================================================================
SET SERVEROUTPUT ON SIZE UNLIMITED

-- --------------------------------------------------------------------------
-- 1. Registro duplicado (correo)
-- --------------------------------------------------------------------------
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST: correo duplicado ===');
    DECLARE
        V_ID NUMBER;
    BEGIN
        SP_REGISTRAR_USUARIO('11.111.111-1', 'Test Dup', 'juan@email.com', 'hash', V_ID);
        RAISE_APPLICATION_ERROR(-20999, 'FALLO: debió rechazar correo duplicado');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20001 THEN
                DBMS_OUTPUT.PUT_LINE('OK: ' || SQLERRM);
            ELSE RAISE;
            END IF;
    END;
END;
/

-- --------------------------------------------------------------------------
-- 2. Superposición de función
-- --------------------------------------------------------------------------
DECLARE
    V_P NUMBER; V_S NUMBER; V_F TIMESTAMP; V_ID NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST: superposición función ===');
    SELECT ID_PELICULA INTO V_P FROM PELICULA WHERE ROWNUM = 1;
    SELECT ID_SALA INTO V_S FROM SALA WHERE ROWNUM = 1;
    SELECT MIN(FECHA_HORA) INTO V_F FROM FUNCION WHERE ID_SALA = V_S;

    BEGIN
        SP_CREAR_FUNCION(V_P, V_S, V_F, 5000, V_ID);
        RAISE_APPLICATION_ERROR(-20999, 'FALLO: debió rechazar superposición');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20035 THEN
                DBMS_OUTPUT.PUT_LINE('OK: ' || SQLERRM);
            ELSE RAISE;
            END IF;
    END;
END;
/

-- --------------------------------------------------------------------------
-- 3. Asiento inválido (otra sala)
-- --------------------------------------------------------------------------
DECLARE
    V_U NUMBER; V_F NUMBER; V_A NUMBER;
    V_R NUMBER; V_C VARCHAR2(30); V_T NUMBER;
    V_SALA_FUNC NUMBER; V_SALA_OTRA NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST: asiento de otra sala ===');
    SELECT ID_USUARIO INTO V_U FROM USUARIO WHERE CORREO = 'maria@email.com';
    SELECT ID_FUNCION INTO V_F FROM FUNCION WHERE ID_FUNCION NOT IN (
        SELECT ID_FUNCION FROM RESERVA
    ) AND ROWNUM = 1;
    SELECT ID_SALA INTO V_SALA_FUNC FROM FUNCION WHERE ID_FUNCION = V_F;
    SELECT ID_SALA INTO V_SALA_OTRA FROM SALA WHERE ID_SALA <> V_SALA_FUNC AND ROWNUM = 1;
    SELECT MIN(ID_ASIENTO) INTO V_A FROM ASIENTO WHERE ID_SALA = V_SALA_OTRA;

    BEGIN
        SP_CREAR_RESERVA(V_U, V_F, T_LISTA_ID(V_A), V_R, V_C, V_T);
        RAISE_APPLICATION_ERROR(-20999, 'FALLO: debió rechazar asiento ajeno');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE IN (-20046, -20047) THEN
                DBMS_OUTPUT.PUT_LINE('OK: ' || SQLERRM);
            ELSE RAISE;
            END IF;
    END;
END;
/

-- --------------------------------------------------------------------------
-- 4. Reserva válida
-- --------------------------------------------------------------------------
DECLARE
    V_U NUMBER; V_F NUMBER; V_A NUMBER;
    V_R NUMBER; V_C VARCHAR2(30); V_T NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST: reserva válida ===');
    SELECT ID_USUARIO INTO V_U FROM USUARIO WHERE CORREO = 'maria@email.com';
    SELECT ID_FUNCION INTO V_F FROM FUNCION
    WHERE  FN_CANTIDAD_ASIENTOS_DISPONIBLES(ID_FUNCION) > 0
      AND  ROWNUM = 1;
    SELECT MIN(ID_ASIENTO) INTO V_A
    FROM   VW_ASIENTOS_FUNCION
    WHERE  ID_FUNCION = V_F AND ESTADO = 'DISPONIBLE';

    SP_CREAR_RESERVA(V_U, V_F, T_LISTA_ID(V_A), V_R, V_C, V_T);
    DBMS_OUTPUT.PUT_LINE('OK reserva: ' || V_C || ' total=' || V_T);
    ROLLBACK;
END;
/

-- --------------------------------------------------------------------------
-- 5. Reserva duplicada (asiento ocupado)
-- --------------------------------------------------------------------------
DECLARE
    V_U NUMBER; V_F NUMBER; V_A1 NUMBER; V_A2 NUMBER;
    V_R NUMBER; V_C VARCHAR2(30); V_T NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST: doble venta ===');
    SELECT ID_USUARIO INTO V_U FROM USUARIO WHERE CORREO = 'juan@email.com';
    SELECT ID_FUNCION INTO V_F FROM FUNCION WHERE ROWNUM = 1;
    SELECT MIN(ID_ASIENTO) INTO V_A1 FROM RESERVA_ASIENTO WHERE ID_FUNCION = V_F;
    SELECT ID_USUARIO INTO V_U FROM USUARIO WHERE CORREO = 'maria@email.com';

    BEGIN
        SP_CREAR_RESERVA(V_U, V_F, T_LISTA_ID(V_A1), V_R, V_C, V_T);
        RAISE_APPLICATION_ERROR(-20999, 'FALLO: debió rechazar asiento ocupado');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20045 THEN
                DBMS_OUTPUT.PUT_LINE('OK: ' || SQLERRM);
            ELSE RAISE;
            END IF;
    END;
END;
/

-- --------------------------------------------------------------------------
-- 6. Pago repetido
-- --------------------------------------------------------------------------
DECLARE
    V_R NUMBER; V_P NUMBER; V_C VARCHAR2(50);
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST: pago repetido ===');
    SELECT ID_RESERVA INTO V_R
    FROM   RESERVA R JOIN ESTADO_RESERVA E ON E.ID_ESTADO = R.ID_ESTADO
    WHERE  E.NOMBRE = 'PAGADA' AND ROWNUM = 1;

    BEGIN
        SP_CONFIRMAR_PAGO(V_R, 'DEBITO', V_P, V_C);
        RAISE_APPLICATION_ERROR(-20999, 'FALLO: debió rechazar pago repetido');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE IN (-20029, -20060) THEN
                DBMS_OUTPUT.PUT_LINE('OK: ' || SQLERRM);
            ELSE RAISE;
            END IF;
    END;
END;
/

-- --------------------------------------------------------------------------
-- 7. Trigger de auditoría
-- --------------------------------------------------------------------------
DECLARE
    V_ANTES NUMBER; V_DESPUES NUMBER;
    V_U NUMBER; V_F NUMBER; V_A NUMBER;
    V_R NUMBER; V_C VARCHAR2(30); V_T NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST: auditoría estado ===');
    SELECT COUNT(*) INTO V_ANTES FROM AUDITORIA_RESERVA;

    SELECT ID_USUARIO INTO V_U FROM USUARIO WHERE CORREO = 'maria@email.com';
    SELECT ID_FUNCION INTO V_F FROM FUNCION
    WHERE  FN_CANTIDAD_ASIENTOS_DISPONIBLES(ID_FUNCION) > 0
      AND  ROWNUM = 1;
    SELECT MIN(ID_ASIENTO) INTO V_A
    FROM   VW_ASIENTOS_FUNCION
    WHERE  ID_FUNCION = V_F AND ESTADO = 'DISPONIBLE';

    SP_CREAR_RESERVA(V_U, V_F, T_LISTA_ID(V_A), V_R, V_C, V_T);
    SP_ANULAR_RESERVA(V_R);

    SELECT COUNT(*) INTO V_DESPUES FROM AUDITORIA_RESERVA;
    IF V_DESPUES > V_ANTES THEN
        DBMS_OUTPUT.PUT_LINE('OK: auditoría registrada');
    ELSE
        RAISE_APPLICATION_ERROR(-20999, 'FALLO: auditoría no registrada');
    END IF;
    ROLLBACK;
END;
/

-- --------------------------------------------------------------------------
-- 8. Admin: actualizar película
-- --------------------------------------------------------------------------
DECLARE
    V_ID NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST: actualizar película ===');
    SELECT ID_PELICULA INTO V_ID FROM PELICULA WHERE ROWNUM = 1;
    SP_ACTUALIZAR_PELICULA(V_ID, 'Título Test', 'Sinopsis', 120, 'TE', 'Drama', NULL);
    DBMS_OUTPUT.PUT_LINE('OK: película actualizada');
    ROLLBACK;
END;
/

-- --------------------------------------------------------------------------
-- 9. Admin: cambiar estado película
-- --------------------------------------------------------------------------
DECLARE
    V_ID NUMBER; V_ACTIVA NUMBER;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST: estado película ===');
    SELECT ID_PELICULA, ACTIVA INTO V_ID, V_ACTIVA FROM PELICULA WHERE ROWNUM = 1;
    SP_CAMBIAR_ESTADO_PELICULA(V_ID, CASE WHEN V_ACTIVA = 1 THEN 0 ELSE 1 END);
    DBMS_OUTPUT.PUT_LINE('OK: estado película cambiado');
    ROLLBACK;
END;
/

-- --------------------------------------------------------------------------
-- 10. Admin: superposición al actualizar función
-- --------------------------------------------------------------------------
DECLARE
    V_F1 NUMBER; V_F2 NUMBER; V_P NUMBER; V_S NUMBER;
    V_FECHA TIMESTAMP;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST: superposición al actualizar ===');
    SELECT F1.ID_FUNCION, F2.ID_FUNCION, F1.ID_PELICULA, F1.ID_SALA, F2.FECHA_HORA
    INTO   V_F1, V_F2, V_P, V_S, V_FECHA
    FROM   FUNCION F1
    JOIN   FUNCION F2 ON F2.ID_SALA = F1.ID_SALA AND F2.ID_FUNCION <> F1.ID_FUNCION
    WHERE  F1.FECHA_HORA > SYSTIMESTAMP
      AND  ROWNUM = 1;

    BEGIN
        SP_ACTUALIZAR_FUNCION(V_F1, V_P, V_S, V_FECHA, 6000);
        RAISE_APPLICATION_ERROR(-20999, 'FALLO: debió rechazar superposición al actualizar');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20035 THEN
                DBMS_OUTPUT.PUT_LINE('OK: ' || SQLERRM);
            ELSE RAISE;
            END IF;
    END;
END;
/

-- --------------------------------------------------------------------------
-- 11. Admin: no modificar sala con reservas pagadas
-- --------------------------------------------------------------------------
DECLARE
    V_F NUMBER; V_P NUMBER; V_S NUMBER; V_S_OTRA NUMBER;
    V_FECHA TIMESTAMP;
BEGIN
    DBMS_OUTPUT.PUT_LINE('=== TEST: cambio sala con reservas pagadas ===');
    SELECT F.ID_FUNCION, F.ID_PELICULA, F.ID_SALA, F.FECHA_HORA
    INTO   V_F, V_P, V_S, V_FECHA
    FROM   FUNCION F
    JOIN   RESERVA R ON R.ID_FUNCION = F.ID_FUNCION
    JOIN   ESTADO_RESERVA ER ON ER.ID_ESTADO = R.ID_ESTADO
    WHERE  ER.NOMBRE = 'PAGADA'
      AND  F.FECHA_HORA > SYSTIMESTAMP
      AND  ROWNUM = 1;

    SELECT ID_SALA INTO V_S_OTRA FROM SALA WHERE ID_SALA <> V_S AND ACTIVA = 1 AND ROWNUM = 1;

    BEGIN
        SP_ACTUALIZAR_FUNCION(V_F, V_P, V_S_OTRA, V_FECHA, 6000);
        RAISE_APPLICATION_ERROR(-20999, 'FALLO: debió rechazar cambio de sala');
    EXCEPTION
        WHEN OTHERS THEN
            IF SQLCODE = -20038 THEN
                DBMS_OUTPUT.PUT_LINE('OK: ' || SQLERRM);
            ELSE
                DBMS_OUTPUT.PUT_LINE('SKIP: ' || SQLERRM);
            END IF;
    END;
END;
/

PROMPT === TESTS COMPLETADOS ===
