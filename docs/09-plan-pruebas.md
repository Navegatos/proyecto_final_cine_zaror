# Plan de Pruebas

## 1. Usuarios

| Caso | Resultado esperado |
|---|---|
| Registrar usuario válido | Usuario creado |
| Correo duplicado | Error controlado |
| RUT duplicado | Error controlado |
| Login correcto | JWT |
| Login incorrecto | 401 |
| Usuario inactivo | Login rechazado |

## 2. Películas

| Caso | Resultado esperado |
|---|---|
| Crear película válida | Creada |
| Duración negativa | Rechazada |
| Desactivar película | No aparece para nuevas funciones |

## 3. Salas y asientos

| Caso | Resultado esperado |
|---|---|
| Crear sala | Sala creada |
| Sala duplicada | Error |
| Generar asientos | Cantidad correcta |
| Asiento duplicado | Error |
| Asiento inactivo | No reservable |

## 4. Funciones

| Caso | Resultado esperado |
|---|---|
| Crear función futura | Creada |
| Crear función pasada | Rechazada |
| Superponer función | Rechazada |
| Sala inactiva | Rechazada |
| Película inactiva | Rechazada |
| Desactivar función | No aparece en cartelera |

## 5. Reservas

| Caso | Resultado esperado |
|---|---|
| Reservar un asiento | Reserva creada |
| Reservar varios | Reserva creada |
| Lista vacía | Rechazada |
| Asiento de otra sala | Rechazada |
| Asiento ocupado | Conflicto |
| Función iniciada | Rechazada |
| Total enviado alterado | Ignorado; Oracle calcula |

## 6. Pago

| Caso | Resultado esperado |
|---|---|
| Pago válido | Reserva PAGADA |
| Pago repetido | Rechazado |
| Monto incorrecto | Rechazado |
| Reserva inexistente | Error |

## 7. Seguridad

| Caso | Resultado esperado |
|---|---|
| Cliente en /admin | 403 |
| Sin token en reservas | 401 |
| Usuario consulta reserva ajena | 403 o 404 |
| Token expirado | 401 |

## 8. Concurrencia

### Caso crítico

1. Abrir dos sesiones.
2. Ambas consultan el mismo asiento.
3. Ambas intentan reservarlo.
4. Una operación debe completarse.
5. La otra debe retornar conflicto.
6. Debe existir un solo registro válido.

## 9. Pruebas SQL

Crear `10_tests.sql` con bloques anónimos para:

- Registro duplicado.
- Superposición.
- Asiento inválido.
- Reserva válida.
- Reserva duplicada.
- Pago repetido.
- Trigger de auditoría.

## 10. Prueba final de demo

Datos precargados:

- 1 administrador.
- 2 clientes.
- 3 películas.
- 2 salas.
- Asientos generados.
- 5 funciones futuras.
- 1 reserva pagada.
- 1 función con asientos ocupados.
