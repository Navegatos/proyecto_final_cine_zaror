# Reglas de Negocio

## 1. Usuarios

### RN-01

El correo electrónico debe ser único.

### RN-02

El RUT debe ser único.

### RN-03

El correo debe almacenarse en minúsculas y sin espacios laterales.

### RN-04

Los usuarios inactivos no pueden iniciar sesión.

### RN-05

Todo usuario debe tener un rol válido.

## 2. Películas

### RN-06

Una película debe tener título, duración, clasificación y estado.

### RN-07

Una película inactiva no puede asignarse a nuevas funciones.

### RN-08

Una película con funciones existentes no debe eliminarse físicamente. Debe desactivarse.

## 3. Salas y asientos

### RN-09

Una sala debe tener un nombre único.

### RN-10

La capacidad de una sala corresponde a la cantidad de asientos activos.

### RN-11

Un asiento se identifica por sala, fila y número.

### RN-12

No pueden existir dos asientos con igual fila y número dentro de una misma sala.

### RN-13

Un asiento inactivo no puede reservarse.

## 4. Funciones

### RN-14

Toda función debe estar asociada a una película y una sala.

### RN-15

La película y la sala deben estar activas.

### RN-16

La fecha y hora deben ser posteriores al momento de creación.

### RN-17

No se permiten funciones superpuestas en una misma sala.

### RN-18

Para calcular superposición se debe considerar:

- Hora inicial.
- Duración de la película.
- Margen de limpieza configurable, inicialmente 20 minutos.

### RN-19

Una función iniciada no puede recibir nuevas reservas.

### RN-20

Una función con reservas pagadas no puede cambiar de sala.

### RN-21

Una función desactivada no aparece en la cartelera.

## 5. Reservas

### RN-22

Una reserva pertenece a un único usuario y a una única función.

### RN-23

Una reserva debe contener al menos un asiento.

### RN-24

Todos los asientos de una reserva deben pertenecer a la sala de la función.

### RN-25

El sistema debe validar nuevamente la disponibilidad al confirmar la reserva.

### RN-26

El total de la reserva se calcula en Oracle:

`total = cantidad de asientos x precio de la función`

### RN-27

El frontend no puede enviar el total como valor definitivo.

### RN-28

Una reserva puede tener los estados:

- PENDIENTE
- PAGADA
- ANULADA
- VENCIDA

### RN-29

Una reserva pagada no puede volver a pagarse.

### RN-30

Una reserva anulada no puede reactivarse directamente.

## 6. Disponibilidad de asientos

### RN-31

La disponibilidad se determina por la combinación función-asiento.

### RN-32

Un asiento está ocupado cuando existe en una reserva PAGADA o PENDIENTE vigente.

### RN-33

La base de datos debe impedir que dos transacciones confirmen el mismo asiento.

### RN-34

La validación debe realizarse dentro de una transacción.

### RN-35

Se recomienda una restricción única sobre:

`funcion_id + asiento_id`

en una tabla de ocupación o detalle que represente los asientos reservados.

## 7. Pago

### RN-36

El pago será simulado.

### RN-37

No se deben almacenar datos reales de tarjetas.

### RN-38

El monto pagado debe coincidir con el total calculado por Oracle.

### RN-39

Un pago aprobado cambia la reserva a PAGADA.

### RN-40

Un pago rechazado no debe confirmar definitivamente la compra.

## 8. Permisos

### RN-41

Solo ADMIN puede crear o modificar películas, salas y funciones.

### RN-42

Un CLIENTE solo puede consultar sus propias reservas.

### RN-43

La autorización se valida en Spring Security y, cuando corresponda, también en Oracle.

## 9. Errores de negocio esperados

- Usuario duplicado.
- Sala duplicada.
- Asiento duplicado.
- Función superpuesta.
- Función no vigente.
- Asiento ocupado.
- Asiento no perteneciente a la sala.
- Reserva inexistente.
- Reserva ya pagada.
- Usuario sin permisos.
