# Alcance y Requisitos

## 1. Actores

### Cliente

Usuario registrado que puede consultar la cartelera, seleccionar funciones, reservar asientos, pagar y revisar sus reservas.

### Administrador

Usuario con permisos administrativos para mantener películas, salas, asientos y funciones.

## 2. Requisitos funcionales

### RF-01 Registro de usuario

El sistema debe permitir registrar un usuario con:

- Nombre completo.
- RUT.
- Correo electrónico.
- Contraseña.

Reglas:

- No pueden existir dos usuarios con el mismo correo.
- No pueden existir dos usuarios con el mismo RUT.
- La contraseña debe almacenarse cifrada.
- El correo debe normalizarse a minúsculas.

### RF-02 Inicio de sesión

El sistema debe permitir iniciar sesión usando correo y contraseña.

El backend debe retornar un token JWT cuando las credenciales sean válidas.

### RF-03 Consulta de cartelera

El cliente debe poder consultar la cartelera por fecha.

La cartelera debe mostrar:

- Película.
- Clasificación.
- Duración.
- Sala.
- Hora.
- Precio.
- Estado de disponibilidad.

### RF-04 Consulta de funciones

El sistema debe listar las funciones disponibles para una película y fecha determinada.

### RF-05 Consulta de asientos

El sistema debe mostrar los asientos de la sala asociada a una función.

Cada asiento debe indicar uno de los siguientes estados:

- Disponible.
- Ocupado.
- Seleccionado en la interfaz.
- Inactivo.

### RF-06 Creación de reserva

El cliente debe poder seleccionar uno o más asientos disponibles y crear una reserva.

La reserva debe contener:

- Usuario.
- Función.
- Fecha de creación.
- Estado.
- Asientos seleccionados.
- Total.

### RF-07 Pago

El sistema debe permitir simular el pago de una reserva.

Datos mínimos:

- Método de pago.
- Estado del pago.
- Código de operación.
- Monto.
- Fecha.

### RF-08 Visualización de reservas

El cliente debe poder consultar sus reservas.

Debe mostrarse:

- Código de reserva.
- Película.
- Fecha y hora.
- Sala.
- Asientos.
- Total.
- Estado.

### RF-09 Administración de películas

El administrador debe poder:

- Crear películas.
- Modificar películas.
- Activar o desactivar películas.
- Consultar películas.

### RF-10 Administración de salas

El administrador debe poder:

- Crear salas.
- Modificar salas.
- Activar o desactivar salas.
- Configurar filas y columnas.
- Generar sus asientos.

### RF-11 Administración de funciones

El administrador debe poder:

- Crear funciones.
- Asignar película.
- Asignar sala.
- Definir fecha y hora.
- Definir precio.
- Activar o desactivar funciones.

## 3. Requisitos no funcionales

### RNF-01 Base de datos

El sistema debe utilizar Oracle Database.

### RNF-02 Servidor pesado

La lógica crítica debe ejecutarse en Oracle mediante PL/SQL.

### RNF-03 Seguridad

- Las contraseñas deben almacenarse cifradas.
- Los endpoints administrativos deben requerir rol ADMIN.
- Un cliente solo puede consultar sus propias reservas.

### RNF-04 Integridad

La base de datos debe impedir:

- Usuarios duplicados.
- Funciones superpuestas en una misma sala.
- Asientos duplicados en una sala.
- Venta doble del mismo asiento en una función.
- Pago duplicado de una reserva.

### RNF-05 Usabilidad

La aplicación debe ser sencilla y clara. No se prioriza una estética compleja.

### RNF-06 Trazabilidad

Debe ser posible identificar:

- Quién creó una reserva.
- Cuándo se creó.
- Cuándo cambió de estado.
- Qué usuario administrativo modificó información crítica, cuando aplique.

### RNF-07 Mantenibilidad

El proyecto debe separar:

- Frontend.
- Backend.
- Scripts de base de datos.
- Documentación.
- Datos de prueba.

## 4. Casos de uso principales

### CU-01 Registrarse

**Actor:** Cliente

**Flujo principal:**

1. El usuario abre la pantalla de registro.
2. Completa sus datos.
3. El frontend envía la solicitud.
4. Spring Boot valida el formato.
5. Oracle valida unicidad.
6. El usuario queda registrado.

### CU-02 Comprar entradas

**Actor:** Cliente

1. Inicia sesión.
2. Selecciona una fecha.
3. Selecciona una película.
4. Selecciona una función.
5. Revisa los asientos.
6. Selecciona uno o más.
7. Confirma la reserva.
8. Simula el pago.
9. El sistema confirma la compra.
10. El usuario visualiza su reserva.

### CU-03 Crear función

**Actor:** Administrador

1. Inicia sesión.
2. Abre el módulo de funciones.
3. Selecciona película y sala.
4. Define fecha, hora y precio.
5. Oracle valida que no exista superposición.
6. La función queda disponible.

## 5. Criterios de aceptación globales

- Todos los flujos obligatorios deben ser demostrables.
- Las operaciones críticas deben usar procedimientos Oracle.
- Los errores de negocio deben retornar mensajes comprensibles.
- El proyecto debe poder ejecutarse desde instrucciones documentadas.
