# Guion de Demostración

## 1. Introducción

Duración sugerida: 3 minutos.

Explicar:

- Problema del cine Zaror.
- Objetivo.
- Stack.
- Enfoque de servidor pesado.
- Arquitectura.

## 2. Modelo relacional

Duración sugerida: 4 minutos.

Mostrar:

- Usuario.
- Película.
- Sala.
- Asiento.
- Función.
- Reserva.
- Reserva asiento.
- Pago.

Explicar especialmente:

- Por qué la disponibilidad depende de función + asiento.
- Cómo se evita vender dos veces el mismo asiento.

## 3. Flujo cliente

Duración sugerida: 10 minutos.

1. Registrar usuario.
2. Iniciar sesión.
3. Consultar cartelera.
4. Seleccionar película.
5. Seleccionar función.
6. Ver asientos.
7. Seleccionar dos.
8. Crear reserva.
9. Pagar.
10. Ver reserva.

## 4. Flujo administrador

Duración sugerida: 8 minutos.

1. Iniciar sesión como ADMIN.
2. Crear película.
3. Crear o mostrar sala.
4. Mostrar generación de asientos.
5. Crear función.
6. Mostrar nueva función en cartelera.

## 5. Objetos Oracle

Duración sugerida: 5 minutos.

Mostrar:

- Una función.
- Un procedimiento.
- Un trigger.
- Una vista.
- Una restricción.

## 6. Prueba técnica

Duración sugerida: 5 minutos.

### Prueba sugerida

Intentar comprar un asiento ya ocupado.

Mostrar:

- Error retornado por Oracle.
- Traducción del error en Spring Boot.
- Mensaje mostrado en Angular.

## 7. Preguntas posibles

- ¿Por qué no usar un booleano disponible en ASIENTO?
- ¿Cómo se evita la venta doble?
- ¿Qué lógica vive en Oracle?
- ¿Qué pasa si dos usuarios reservan al mismo tiempo?
- ¿Por qué usar JdbcTemplate?
- ¿Qué hace el trigger?
- ¿Cómo se valida superposición de funciones?
- ¿Cómo se asegura que un cliente vea solo sus reservas?
- ¿Por qué el total se calcula en Oracle?
- ¿Qué ocurre si falla el pago?

## 8. Plan de contingencia

Tener preparado:

- Video corto de respaldo.
- Capturas de pantalla.
- Scripts ejecutables.
- Colección Postman o Bruno.
- Usuario administrador.
- Usuario cliente.
- Copia local de la base de datos o scripts.
