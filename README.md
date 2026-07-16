# Cine Zaror — Sistema de Compra de Entradas

Proyecto final de Taller de Base de Datos. Stack: **Angular + Spring Boot + Oracle PL/SQL**.

## Estructura

```text
proyecto_final/
├── backend/          # Spring Boot REST API
├── frontend/         # Angular + Material
├── database/sql/     # Scripts Oracle 01–10
└── docs/             # Documentación del proyecto
```

## Requisitos

- Java 21
- Maven 3.9+
- Node.js 20+ y npm
- Docker (Oracle XE)

## 1. Base de datos Oracle

El `docker-compose.yml` está en `/home/torao/taller_bd/`:

```bash
cd /home/torao/taller_bd
docker compose up -d
```

Credenciales por defecto:

| Variable | Valor |
|----------|-------|
| URL | `jdbc:oracle:thin:@//localhost:1521/XEPDB1` |
| Usuario | `curso` |
| Password | `curso123` |

### Scripts (orden obligatorio)

```bash
cd database/sql
sqlplus curso/curso123@localhost/XEPDB1 @01_tables.sql
sqlplus curso/curso123@localhost/XEPDB1 @02_sequences.sql
sqlplus curso/curso123@localhost/XEPDB1 @03_constraints.sql
sqlplus curso/curso123@localhost/XEPDB1 @04_functions.sql
sqlplus curso/curso123@localhost/XEPDB1 @05_procedures.sql
sqlplus curso/curso123@localhost/XEPDB1 @06_triggers.sql
sqlplus curso/curso123@localhost/XEPDB1 @07_views.sql
sqlplus curso/curso123@localhost/XEPDB1 @08_seed.sql
```

Verificación:

```bash
sqlplus curso/curso123@localhost/XEPDB1 @_verify_schema.sql
sqlplus curso/curso123@localhost/XEPDB1 @10_tests.sql
```

### Usuarios demo (password: `Secreta123`)

| Rol | Correo |
|-----|--------|
| ADMIN | admin@cinezaror.cl |
| CLIENTE | juan@email.com |
| CLIENTE | maria@email.com |

## 2. Backend

```bash
cd backend
cp .env.example .env   # opcional
export ORACLE_URL="jdbc:oracle:thin:@//localhost:1521/XEPDB1"
export ORACLE_USERNAME="curso"
export ORACLE_PASSWORD="curso123"
export JWT_SECRET="cambiar-este-secreto-en-produccion-minimo-32-caracteres"

mvn spring-boot:run
```

Health check:

```bash
curl -s http://localhost:8080/api/health | python3 -m json.tool
```

Login demo:

```bash
curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"correo":"juan@email.com","password":"Secreta123"}'
```

## 3. Frontend

```bash
cd frontend
npm install
npm start
```

Abrir http://localhost:4200 (proxy a backend en `/api`).

## 4. Flujo demo end-to-end

1. Login como `juan@email.com` / `Secreta123`
2. Cartelera → seleccionar fecha (mañana) → ver función
3. Seleccionar asientos → confirmar reserva
4. Checkout → simular pago
5. Mis reservas → verificar estado PAGADA
6. Login como `admin@cinezaror.cl` → panel admin

> **Nota:** Las funciones demo se crean con fechas futuras (`SYSTIMESTAMP + 1 día`). En cartelera, selecciona la fecha de mañana o posterior si no ves funciones al abrir la app.

## 5. Pruebas

- SQL: `database/sql/10_tests.sql`
- Consultas: `database/sql/09_queries.sql`
- Backend: `mvn test` en `backend/`

## Documentación

Ver carpeta `docs/` para modelo de datos, reglas de negocio, API REST y plan de implementación.
