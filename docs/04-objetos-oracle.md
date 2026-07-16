# Objetos Oracle

## 1. Orden de ejecución de scripts

```text
01_tables.sql
02_sequences.sql
03_constraints.sql
04_functions.sql
05_procedures.sql
06_triggers.sql
07_views.sql
08_seed.sql
09_queries.sql
10_tests.sql
```

## 2. Secuencias

- SEQ_ROL
- SEQ_USUARIO
- SEQ_PELICULA
- SEQ_SALA
- SEQ_ASIENTO
- SEQ_FUNCION
- SEQ_ESTADO_RESERVA
- SEQ_RESERVA
- SEQ_RESERVA_ASIENTO
- SEQ_PAGO
- SEQ_AUDITORIA_RESERVA

## 3. Funciones

### FN_ASIENTO_DISPONIBLE

Determina si un asiento está disponible para una función.

```sql
FN_ASIENTO_DISPONIBLE(
    P_ID_FUNCION NUMBER,
    P_ID_ASIENTO NUMBER
) RETURN NUMBER
```

Retorna:

- 1: disponible.
- 0: ocupado o inválido.

### FN_CALCULAR_TOTAL_RESERVA

Calcula el total según cantidad de asientos y precio de la función.

### FN_FUNCION_VIGENTE

Valida que la función esté activa y no haya comenzado.

### FN_CANTIDAD_ASIENTOS_DISPONIBLES

Retorna la cantidad disponible para una función.

### FN_EXISTE_SUPERPOSICION_FUNCION

Valida superposición de horario en una sala.

## 4. Procedimientos

### SP_REGISTRAR_USUARIO

Responsabilidades:

- Normalizar correo.
- Validar duplicados.
- Insertar usuario.
- Asignar rol CLIENTE.

### SP_CREAR_PELICULA

Valida e inserta una película.

### SP_CREAR_SALA

Crea la sala.

### SP_GENERAR_ASIENTOS_SALA

Genera los asientos según filas y columnas.

Ejemplo:

- Fila A, asientos 1 a 10.
- Fila B, asientos 1 a 10.

### SP_CREAR_FUNCION

Responsabilidades:

- Validar película activa.
- Validar sala activa.
- Validar fecha futura.
- Validar superposición.
- Insertar la función.

### SP_CREAR_RESERVA

Responsabilidades:

1. Validar usuario.
2. Validar función.
3. Validar asientos.
4. Crear reserva.
5. Insertar asientos.
6. Calcular total.
7. Retornar ID y código.

Debe ejecutarse en una única transacción.

### SP_CONFIRMAR_PAGO

Responsabilidades:

- Validar reserva.
- Validar que no esté pagada.
- Validar monto.
- Crear pago.
- Cambiar estado a PAGADA.

### SP_ANULAR_RESERVA

Cambia el estado y libera los asientos según la estrategia implementada.

### SP_DESACTIVAR_FUNCION

Desactiva una función cuando las reglas lo permitan.

## 5. Triggers

### TRG_USUARIO_NORMALIZAR_EMAIL

Convierte el correo a minúsculas y elimina espacios.

### TRG_RESERVA_FECHA_CREACION

Completa fechas automáticas si no fueron informadas.

### TRG_VALIDAR_RESERVA_ASIENTO

Valida que el asiento pertenezca a la sala de la función.

### TRG_AUDITAR_ESTADO_RESERVA

Registra cambios de estado.

### TRG_EVITAR_CAMBIO_FUNCION_RESERVADA

Impide modificar sala o película cuando la función tenga reservas pagadas.

## 6. Vistas

### VW_CARTELERA

Contiene:

- Película.
- Fecha.
- Hora.
- Sala.
- Precio.
- Asientos disponibles.

### VW_ASIENTOS_FUNCION

Muestra todos los asientos de una función y su estado.

### VW_RESERVAS_USUARIO

Muestra el resumen de reservas por usuario.

### VW_RESERVAS_ADMIN

Vista administrativa con datos completos.

## 7. Manejo de errores

Los procedimientos deben usar errores de aplicación:

```sql
RAISE_APPLICATION_ERROR(-20001, 'El correo ya está registrado');
```

Rango sugerido:

- -20001 a -20009: usuarios.
- -20010 a -20019: películas.
- -20020 a -20029: salas y asientos.
- -20030 a -20039: funciones.
- -20040 a -20059: reservas.
- -20060 a -20069: pagos.

## 8. Transacciones

No se debe ejecutar `COMMIT` dentro de funciones.

Para procedimientos críticos se debe definir claramente si:

- El procedimiento controla COMMIT/ROLLBACK.
- O Spring Boot controla la transacción.

Recomendación para el proyecto:

- Procedimiento ejecuta la lógica completa.
- Spring Boot abre la llamada.
- Oracle garantiza atomicidad.
- Ante error, la llamada se revierte.
