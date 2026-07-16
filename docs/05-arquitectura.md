# Arquitectura del Sistema

## 1. Vista general

```text
Angular + Angular Material
          |
          | HTTP / JSON
          v
Spring Boot REST API
          |
          | JDBC / CallableStatement
          v
Oracle Database
```

## 2. Responsabilidades

## Angular

- Mostrar pantallas.
- Validar formato básico.
- Administrar navegación.
- Guardar temporalmente selección de asientos.
- Enviar solicitudes HTTP.
- Mostrar mensajes de error.

Angular no decide si un asiento está realmente disponible.

## Spring Boot

- Exponer endpoints REST.
- Autenticar usuarios.
- Generar y validar JWT.
- Aplicar autorización por rol.
- Convertir requests en llamadas a Oracle.
- Convertir respuestas Oracle en DTO.
- Manejar errores HTTP.

## Oracle

- Aplicar reglas de negocio.
- Validar disponibilidad.
- Calcular totales.
- Crear reservas.
- Confirmar pagos.
- Evitar duplicidad.
- Gestionar transacciones.
- Mantener integridad.

## 3. Capas del backend

```text
controller
application/service
repository
database/procedure gateway
security
dto
exception
config
```

### Controller

Recibe y responde HTTP.

### Service

Coordina casos de uso, sin duplicar lógica crítica de Oracle.

### Repository

Ejecuta consultas simples y llamadas a procedimientos.

### Security

Configura Spring Security, JWT y roles.

### Exception

Traduce errores Oracle a respuestas HTTP.

## 4. Estructura sugerida

```text
backend/src/main/java/cl/ucm/cinezaror/
├── auth/
├── usuario/
├── cartelera/
├── funcion/
├── reserva/
├── admin/
├── security/
├── database/
├── common/
└── config/
```

## 5. Flujo de reserva

```text
1. Angular solicita asientos.
2. Spring consulta VW_ASIENTOS_FUNCION.
3. Oracle retorna disponibilidad.
4. Usuario selecciona asientos.
5. Angular envía IDs.
6. Spring llama SP_CREAR_RESERVA.
7. Oracle revalida disponibilidad.
8. Oracle crea reserva y detalles.
9. Spring retorna código y total.
10. Angular solicita pago.
11. Spring llama SP_CONFIRMAR_PAGO.
12. Oracle registra pago y confirma reserva.
```

## 6. Seguridad

### Autenticación

JWT firmado por Spring Boot.

### Autorización

Rutas:

- `/api/auth/**`: públicas.
- `/api/cartelera/**`: públicas o autenticadas según decisión.
- `/api/reservas/**`: CLIENTE o ADMIN.
- `/api/admin/**`: ADMIN.

### Contraseñas

Spring Security debe usar BCrypt.

## 7. Manejo de concurrencia

La interfaz puede mostrar un asiento disponible, pero otro usuario podría reservarlo antes.

La protección definitiva debe estar en Oracle mediante:

- Restricción única.
- Transacción.
- Manejo de excepción.
- Revalidación al confirmar.

## 8. Respuestas HTTP

- 200: consulta correcta.
- 201: recurso creado.
- 400: formato inválido.
- 401: no autenticado.
- 403: sin permisos.
- 404: recurso inexistente.
- 409: conflicto de negocio.
- 422: validación de negocio.
- 500: error interno.
