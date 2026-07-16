# Modelo de Datos

## 1. Entidades

## ROL

| Campo | Tipo sugerido | Restricción |
|---|---|---|
| ID_ROL | NUMBER | PK |
| NOMBRE | VARCHAR2(30) | UNIQUE, NOT NULL |
| DESCRIPCION | VARCHAR2(200) | NULL |

Valores iniciales:

- ADMIN
- CLIENTE

## USUARIO

| Campo | Tipo sugerido | Restricción |
|---|---|---|
| ID_USUARIO | NUMBER | PK |
| ID_ROL | NUMBER | FK |
| RUT | VARCHAR2(12) | UNIQUE, NOT NULL |
| NOMBRE_COMPLETO | VARCHAR2(150) | NOT NULL |
| CORREO | VARCHAR2(150) | UNIQUE, NOT NULL |
| PASSWORD_HASH | VARCHAR2(255) | NOT NULL |
| ACTIVO | NUMBER(1) | DEFAULT 1 |
| FECHA_CREACION | TIMESTAMP | DEFAULT SYSTIMESTAMP |

## PELICULA

| Campo | Tipo sugerido | Restricción |
|---|---|---|
| ID_PELICULA | NUMBER | PK |
| TITULO | VARCHAR2(150) | NOT NULL |
| SINOPSIS | VARCHAR2(1000) | NULL |
| DURACION_MINUTOS | NUMBER(4) | CHECK > 0 |
| CLASIFICACION | VARCHAR2(20) | NOT NULL |
| GENERO | VARCHAR2(80) | NULL |
| URL_IMAGEN | VARCHAR2(500) | NULL |
| ACTIVA | NUMBER(1) | DEFAULT 1 |

## SALA

| Campo | Tipo sugerido | Restricción |
|---|---|---|
| ID_SALA | NUMBER | PK |
| NOMBRE | VARCHAR2(80) | UNIQUE, NOT NULL |
| FILAS | NUMBER(3) | CHECK > 0 |
| COLUMNAS | NUMBER(3) | CHECK > 0 |
| ACTIVA | NUMBER(1) | DEFAULT 1 |

## ASIENTO

| Campo | Tipo sugerido | Restricción |
|---|---|---|
| ID_ASIENTO | NUMBER | PK |
| ID_SALA | NUMBER | FK |
| FILA | VARCHAR2(5) | NOT NULL |
| NUMERO | NUMBER(3) | NOT NULL |
| ACTIVO | NUMBER(1) | DEFAULT 1 |

Restricción única:

```sql
UNIQUE (ID_SALA, FILA, NUMERO)
```

## FUNCION

| Campo | Tipo sugerido | Restricción |
|---|---|---|
| ID_FUNCION | NUMBER | PK |
| ID_PELICULA | NUMBER | FK |
| ID_SALA | NUMBER | FK |
| FECHA_HORA | TIMESTAMP | NOT NULL |
| PRECIO | NUMBER(10,2) | CHECK > 0 |
| ACTIVA | NUMBER(1) | DEFAULT 1 |
| FECHA_CREACION | TIMESTAMP | DEFAULT SYSTIMESTAMP |

## ESTADO_RESERVA

| Campo | Tipo sugerido | Restricción |
|---|---|---|
| ID_ESTADO | NUMBER | PK |
| NOMBRE | VARCHAR2(30) | UNIQUE |

Valores:

- PENDIENTE
- PAGADA
- ANULADA
- VENCIDA

## RESERVA

| Campo | Tipo sugerido | Restricción |
|---|---|---|
| ID_RESERVA | NUMBER | PK |
| CODIGO | VARCHAR2(30) | UNIQUE |
| ID_USUARIO | NUMBER | FK |
| ID_FUNCION | NUMBER | FK |
| ID_ESTADO | NUMBER | FK |
| CANTIDAD_ENTRADAS | NUMBER(3) | CHECK > 0 |
| TOTAL | NUMBER(12,2) | CHECK >= 0 |
| FECHA_CREACION | TIMESTAMP | DEFAULT SYSTIMESTAMP |
| FECHA_ACTUALIZACION | TIMESTAMP | NULL |

## RESERVA_ASIENTO

| Campo | Tipo sugerido | Restricción |
|---|---|---|
| ID_RESERVA_ASIENTO | NUMBER | PK |
| ID_RESERVA | NUMBER | FK |
| ID_FUNCION | NUMBER | FK |
| ID_ASIENTO | NUMBER | FK |
| PRECIO_UNITARIO | NUMBER(10,2) | NOT NULL |

Restricción única recomendada:

```sql
UNIQUE (ID_FUNCION, ID_ASIENTO)
```

Esta restricción es la principal protección contra la venta doble de un asiento.

## PAGO

| Campo | Tipo sugerido | Restricción |
|---|---|---|
| ID_PAGO | NUMBER | PK |
| ID_RESERVA | NUMBER | FK, UNIQUE |
| METODO | VARCHAR2(30) | NOT NULL |
| MONTO | NUMBER(12,2) | NOT NULL |
| ESTADO | VARCHAR2(30) | NOT NULL |
| CODIGO_OPERACION | VARCHAR2(50) | UNIQUE |
| FECHA_PAGO | TIMESTAMP | DEFAULT SYSTIMESTAMP |

## AUDITORIA_RESERVA

| Campo | Tipo sugerido | Restricción |
|---|---|---|
| ID_AUDITORIA | NUMBER | PK |
| ID_RESERVA | NUMBER | FK |
| ESTADO_ANTERIOR | VARCHAR2(30) | NULL |
| ESTADO_NUEVO | VARCHAR2(30) | NOT NULL |
| FECHA_CAMBIO | TIMESTAMP | DEFAULT SYSTIMESTAMP |
| OBSERVACION | VARCHAR2(500) | NULL |

## 2. Relaciones

```text
ROL 1 ─── N USUARIO

PELICULA 1 ─── N FUNCION

SALA 1 ─── N FUNCION
SALA 1 ─── N ASIENTO

USUARIO 1 ─── N RESERVA
FUNCION 1 ─── N RESERVA

ESTADO_RESERVA 1 ─── N RESERVA

RESERVA 1 ─── N RESERVA_ASIENTO
ASIENTO 1 ─── N RESERVA_ASIENTO

RESERVA 1 ─── 0..1 PAGO
RESERVA 1 ─── N AUDITORIA_RESERVA
```

## 3. Índices recomendados

```sql
IDX_FUNCION_FECHA
IDX_FUNCION_PELICULA
IDX_FUNCION_SALA
IDX_RESERVA_USUARIO
IDX_RESERVA_FUNCION
IDX_RESERVA_ASIENTO_FUNCION
IDX_ASIENTO_SALA
```

## 4. Decisiones de diseño

### Disponibilidad

No se almacena un campo `DISPONIBLE` en ASIENTO porque la disponibilidad depende de una función específica.

### Eliminación lógica

Películas, salas y funciones se desactivan en lugar de eliminarse cuando tienen información asociada.

### Total de reserva

El total se calcula en Oracle y se guarda en RESERVA para mantener el valor histórico de la compra.
