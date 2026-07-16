# Contexto del Proyecto — Cine Zaror

## 1. Identificación

- **Asignatura:** Taller de Base de Datos
- **Proyecto:** Sistema de Compra de Entradas de Cine
- **Organización ficticia:** Cine Zaror
- **Tipo de aplicación:** Aplicación web cliente-servidor
- **Equipo:** 3 integrantes
- **Tecnologías propuestas:**
  - Frontend: Angular + Angular Material
  - Backend: Spring Boot
  - Base de datos: Oracle Database
  - Autenticación: JWT
  - Acceso a datos: Spring JDBC / JdbcTemplate
  - Lenguaje de base de datos: SQL y PL/SQL

## 2. Descripción general

El cine Zaror actualmente vende entradas de forma presencial. El proyecto busca construir un sistema web que permita a los clientes consultar la cartelera, seleccionar una función, revisar la disponibilidad de asientos, reservar uno o más asientos, simular el pago y consultar las reservas realizadas.

El sistema también debe incluir un módulo administrativo para configurar películas, salas, asientos, horarios y funciones.

## 3. Objetivo principal

Diseñar e implementar un sistema web que permita gestionar la compra de entradas del cine Zaror, considerando reservas, salas, horarios, funciones y disponibilidad de asientos.

## 4. Objetivos secundarios

1. Permitir el registro de usuarios.
2. Permitir el inicio de sesión.
3. Mostrar la cartelera disponible por fecha.
4. Mostrar las salas y horarios asociados a cada película.
5. Mostrar la disponibilidad de asientos para una función.
6. Permitir reservar uno o más asientos.
7. Simular el pago de las entradas.
8. Permitir que el usuario consulte sus reservas.
9. Permitir que un administrador configure cartelera, salas y horarios.
10. Implementar la mayor parte de las validaciones, lógica de negocio y manipulación de datos en Oracle.

## 5. Restricción principal del curso

El proyecto debe seguir un enfoque de **servidor pesado**, lo que significa que la lógica de negocio crítica debe ejecutarse en Oracle mediante:

- Restricciones.
- Funciones.
- Procedimientos almacenados.
- Triggers.
- Transacciones.
- Consultas SQL.

Spring Boot debe actuar principalmente como capa de exposición de servicios, seguridad, validación de formato y comunicación con la base de datos.

## 6. Prioridades del proyecto

Orden de prioridad:

1. Integridad del modelo relacional.
2. Correcta disponibilidad de asientos.
3. Reserva transaccional.
4. Evitar compras duplicadas.
5. Correcto uso de funciones, procedimientos y triggers.
6. Cumplimiento de los flujos obligatorios.
7. Interfaz sencilla y funcional.
8. Apariencia visual.

## 7. Fuera de alcance

Para mantener un alcance adecuado al tiempo disponible, no se implementará:

- Integración con pasarelas de pago reales.
- Envío de correos.
- Aplicación móvil.
- Sistema de descuentos complejo.
- Integración con servicios externos.
- Venta de alimentos.
- Selección avanzada de butacas para personas con movilidad reducida.
- Recomendaciones de películas.
- Gestión de múltiples sucursales.

## 8. Criterio de éxito

El sistema se considera terminado cuando es posible ejecutar el siguiente flujo:

1. Registrar un usuario.
2. Iniciar sesión.
3. Consultar la cartelera de una fecha.
4. Seleccionar una función.
5. Ver los asientos disponibles.
6. Seleccionar uno o más asientos.
7. Confirmar la reserva.
8. Simular el pago.
9. Consultar la reserva generada.
10. Ingresar como administrador y crear una nueva función.
