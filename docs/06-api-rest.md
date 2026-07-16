# API REST

## 1. Convenciones

Base URL:

```text
/api
```

Formato:

```json
{
  "success": true,
  "message": "Operación realizada",
  "data": {}
}
```

Error:

```json
{
  "success": false,
  "message": "El asiento ya no está disponible",
  "code": "ASIENTO_OCUPADO"
}
```

## 2. Autenticación

### POST /api/auth/register

Request:

```json
{
  "rut": "12.345.678-9",
  "nombreCompleto": "Juan Pérez",
  "correo": "juan@email.com",
  "password": "Secreta123"
}
```

Oracle:

- SP_REGISTRAR_USUARIO

### POST /api/auth/login

Request:

```json
{
  "correo": "juan@email.com",
  "password": "Secreta123"
}
```

Response:

```json
{
  "token": "jwt",
  "nombre": "Juan Pérez",
  "rol": "CLIENTE"
}
```

## 3. Cartelera

### GET /api/cartelera?fecha=2026-07-13

Retorna películas y funciones del día.

Fuente:

- VW_CARTELERA

### GET /api/funciones/{id}

Retorna detalle de una función.

### GET /api/funciones/{id}/asientos

Response:

```json
{
  "funcionId": 10,
  "sala": "Sala 1",
  "asientos": [
    {
      "id": 1,
      "fila": "A",
      "numero": 1,
      "estado": "DISPONIBLE"
    }
  ]
}
```

Fuente:

- VW_ASIENTOS_FUNCION

## 4. Reservas

### POST /api/reservas

Request:

```json
{
  "funcionId": 10,
  "asientoIds": [1, 2, 3]
}
```

Oracle:

- SP_CREAR_RESERVA

Response:

```json
{
  "reservaId": 55,
  "codigo": "ZAR-20260713-00055",
  "cantidad": 3,
  "total": 18000,
  "estado": "PENDIENTE"
}
```

### POST /api/reservas/{id}/pago

Request:

```json
{
  "metodo": "DEBITO"
}
```

Oracle:

- SP_CONFIRMAR_PAGO

### GET /api/reservas/mis-reservas

Retorna reservas del usuario autenticado.

### GET /api/reservas/{id}

Valida que la reserva pertenezca al usuario o que sea ADMIN.

## 5. Administración

## Películas

- GET `/api/admin/peliculas`
- POST `/api/admin/peliculas`
- PUT `/api/admin/peliculas/{id}`
- PATCH `/api/admin/peliculas/{id}/estado`

## Salas

- GET `/api/admin/salas`
- POST `/api/admin/salas`
- PUT `/api/admin/salas/{id}`
- POST `/api/admin/salas/{id}/generar-asientos`
- PATCH `/api/admin/salas/{id}/estado`

## Funciones

- GET `/api/admin/funciones`
- POST `/api/admin/funciones`
- PUT `/api/admin/funciones/{id}`
- PATCH `/api/admin/funciones/{id}/estado`

## 6. Matriz endpoint-procedimiento

| Endpoint | Objeto Oracle |
|---|---|
| Registro | SP_REGISTRAR_USUARIO |
| Cartelera | VW_CARTELERA |
| Asientos | VW_ASIENTOS_FUNCION |
| Crear reserva | SP_CREAR_RESERVA |
| Pagar | SP_CONFIRMAR_PAGO |
| Mis reservas | VW_RESERVAS_USUARIO |
| Crear sala | SP_CREAR_SALA |
| Generar asientos | SP_GENERAR_ASIENTOS_SALA |
| Crear función | SP_CREAR_FUNCION |
