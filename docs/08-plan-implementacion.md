# Plan de Implementación

## Fase 0 — Preparación

### Tareas

- Crear repositorio.
- Crear carpetas backend, frontend, database y docs.
- Definir ramas.
- Configurar variables de entorno.
- Confirmar acceso a Oracle.

### Terminado cuando

Los tres integrantes pueden clonar el proyecto y conectarse al repositorio.

## Fase 1 — Modelo de datos

### Tareas

1. Crear modelo relacional.
2. Crear tablas.
3. Crear secuencias.
4. Crear PK, FK, UNIQUE y CHECK.
5. Insertar roles y estados.
6. Crear datos de prueba.

### Terminado cuando

El esquema se crea desde cero sin errores.

## Fase 2 — Objetos PL/SQL

### Tareas

1. Implementar funciones.
2. Implementar procedimientos.
3. Implementar triggers.
4. Implementar vistas.
5. Crear pruebas SQL.

### Terminado cuando

Es posible registrar un usuario, crear una función y realizar una reserva directamente desde Oracle.

## Fase 3 — Backend base

### Tareas

1. Crear Spring Boot.
2. Configurar Oracle.
3. Configurar perfiles.
4. Crear estructura.
5. Crear manejo de errores.
6. Crear respuesta estándar.

### Terminado cuando

Existe un endpoint de salud y conexión correcta con Oracle.

## Fase 4 — Autenticación

### Tareas

1. Registro.
2. Login.
3. BCrypt.
4. JWT.
5. Roles.
6. Guards de backend.

### Terminado cuando

CLIENTE y ADMIN acceden a endpoints diferentes.

## Fase 5 — Cartelera y asientos

### Tareas

1. Endpoint cartelera.
2. Endpoint funciones.
3. Endpoint asientos.
4. Pruebas con Postman o Bruno.

### Terminado cuando

La API muestra disponibilidad real por función.

## Fase 6 — Reserva y pago

### Tareas

1. Endpoint crear reserva.
2. Endpoint pagar.
3. Endpoint mis reservas.
4. Manejo de conflictos.
5. Prueba de doble reserva.

### Terminado cuando

Dos usuarios no pueden comprar el mismo asiento.

## Fase 7 — Administración

### Tareas

1. CRUD películas.
2. CRUD salas.
3. Generación de asientos.
4. CRUD funciones.
5. Validación de superposición.

### Terminado cuando

El administrador puede configurar una nueva función.

## Fase 8 — Angular

### Orden recomendado

1. Crear proyecto.
2. Configurar Material.
3. Layout.
4. Login.
5. Registro.
6. Cartelera.
7. Selección de asientos.
8. Pago.
9. Mis reservas.
10. Administración.

## Fase 9 — Integración

### Tareas

- Validar todos los flujos.
- Corregir errores de formato.
- Preparar datos de demo.
- Ejecutar pruebas de concurrencia.
- Revisar seguridad.

## Fase 10 — Entrega

### Tareas

- README.
- Scripts.
- Lista impresa.
- Diagrama relacional.
- PowerPoint.
- Guion.
- Ensayo.
- Respaldo.

## Orden recomendado para Cursor

Para cada fase:

1. Leer el documento asociado.
2. Pedir a Cursor un plan.
3. Revisar el plan.
4. Implementar una tarea a la vez.
5. Ejecutar pruebas.
6. Hacer commit.
7. Actualizar documentación.

## Regla de trabajo

No pedir a Cursor que genere el proyecto completo en una sola instrucción.
