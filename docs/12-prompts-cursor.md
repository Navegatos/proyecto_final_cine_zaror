# Prompts para Trabajar en Cursor

## 1. Prompt inicial

```text
Lee todos los documentos dentro de /docs antes de proponer cambios.

Este proyecto corresponde a un sistema de compra de entradas de cine desarrollado con:
- Angular + Angular Material
- Spring Boot
- Oracle
- PL/SQL
- JWT
- JdbcTemplate

La principal restricción es que la lógica de negocio crítica debe vivir en Oracle.

No generes código todavía. Primero:
1. Resume la arquitectura.
2. Detecta contradicciones.
3. Propón un plan por fases.
4. Enumera riesgos técnicos.
5. Indica qué decisiones deben cerrarse antes de programar.
```

## 2. Prompt para modelo Oracle

```text
Usando docs/03-modelo-datos.md y docs/04-objetos-oracle.md:

1. Genera primero un plan de scripts.
2. No implementes todo a la vez.
3. Comienza solo con 01_tables.sql, 02_sequences.sql y 03_constraints.sql.
4. Usa nombres en mayúsculas y tipos compatibles con Oracle.
5. Agrega comentarios.
6. No agregues objetos no documentados sin justificar.
7. Al final entrega consultas de verificación.
```

## 3. Prompt para procedimientos

```text
Implementa SP_CREAR_RESERVA siguiendo docs/02-reglas-negocio.md.

Requisitos:
- Validar usuario.
- Validar función.
- Validar asientos.
- Evitar doble venta.
- Calcular total en Oracle.
- Insertar reserva y detalles.
- Retornar ID, código y total.
- Usar RAISE_APPLICATION_ERROR.
- Garantizar atomicidad.
- Incluir bloque de prueba.
- Explicar cómo se maneja concurrencia.
```

## 4. Prompt para Spring Boot

```text
Usa docs/05-arquitectura.md y docs/06-api-rest.md.

Crea únicamente la base del backend:
- Maven.
- Spring Web.
- Spring Security.
- JDBC.
- Oracle Driver.
- Validation.
- JWT.
- Manejo global de errores.
- Perfil local mediante variables de entorno.

No implementes endpoints de negocio todavía.
Entrega:
1. Estructura.
2. Dependencias.
3. application.yml de ejemplo.
4. Health endpoint.
5. Pasos para probar conexión.
```

## 5. Prompt para Angular

```text
Usa docs/07-frontend-angular.md.

Crea la base Angular con Angular Material.
Incluye:
- Rutas.
- Layout público.
- Layout administrativo.
- AuthService.
- JWT interceptor.
- AuthGuard.
- AdminGuard.
- Tema Material estándar.

No implementes todavía las pantallas completas.
Prioriza estructura simple y mantenible.
```

## 6. Prompt de revisión

```text
Revisa la implementación actual comparándola con todos los documentos de /docs.

Entrega una tabla con:
- Requisito.
- Estado.
- Archivo relacionado.
- Problema detectado.
- Acción recomendada.

No modifiques archivos hasta que apruebe el diagnóstico.
```

## 7. Reglas para Cursor

- Implementar una fase por vez.
- No asumir reglas nuevas.
- No mover lógica crítica a Spring Boot.
- No confiar en totales enviados por frontend.
- Agregar pruebas junto con cada cambio.
- Mantener scripts Oracle ejecutables desde cero.
- Evitar abstracciones innecesarias.
