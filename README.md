# Cine Zaror — Sistema de Compra de Entradas

Proyecto final de Taller de Base de Datos. Stack: **Angular + Spring Boot + Oracle PL/SQL**.

## Estructura

```text
proyecto_final/
├── backend/          # Spring Boot REST API
├── frontend/         # Angular + Material
├── database/         # Dockerfile Oracle + scripts SQL (01–10)
└── docker-compose.yml
```

## Requisitos

| Componente | Local | Docker |
|------------|-------|--------|
| Base de datos | Oracle 21c (XE) | Perfil `db` |
| Backend | Java 21, Maven 3.9+ | Perfil `backend` |
| Frontend | Node.js 20+, npm | Perfil `frontend` |

---

## Credenciales y usuarios demo

### Oracle

| Variable | Valor por defecto |
|----------|-------------------|
| Usuario app | `curso` |
| Password app | `curso123` |
| PDB | `XEPDB1` |

**URL JDBC según dónde corre Oracle:**

| Escenario | URL |
|-----------|-----|
| Oracle en host (puerto 1521) | `jdbc:oracle:thin:@//localhost:1521/XEPDB1` |
| Oracle en contenedor (desde host) | `jdbc:oracle:thin:@//localhost:1522/XEPDB1` |
| Oracle en contenedor (desde otro contenedor) | `jdbc:oracle:thin:@//oracle:1521/XEPDB1` |

### Usuarios de la aplicación (password: `Secreta123`)

| Rol | Correo |
|-----|--------|
| ADMIN | admin@cinezaror.cl |
| CLIENTE | juan@email.com |
| CLIENTE | maria@email.com |

---

## Guía: levantar pieza por pieza

Cada capa puede correr **local** (sin Docker) o **en contenedor**. Combina como necesites para la demo.

### 1. Base de datos

#### Opción A — Contenedor Docker (recomendado para demo autónoma)

```bash
# Solo la BD (tarda ~2–3 min la primera vez)
docker compose --profile db up -d

# Ver logs hasta que esté healthy
docker compose --profile db logs -f oracle
```

El contenedor aplica automáticamente los scripts `01`–`08` al iniciar por primera vez.  
Puerto en el host: **1522** (para no chocar con un Oracle local en 1521).

Verificar desde el host:

```bash
sqlplus curso/curso123@localhost:1522/XEPDB1
```

#### Opción B — Oracle ya instalado en el host

Si ya tienes Oracle corriendo (por ejemplo en `localhost:1521`), **no levantes el contenedor de BD**. Ejecuta los scripts manualmente:

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

Verificación opcional:

```bash
sqlplus curso/curso123@localhost/XEPDB1 @_verify_schema.sql
sqlplus curso/curso123@localhost/XEPDB1 @10_tests.sql
```

---

### 2. Backend

#### Opción A — Local (Maven)

```bash
cd backend
cp .env.example .env   # opcional

export ORACLE_URL="jdbc:oracle:thin:@//localhost:1521/XEPDB1"   # host
# export ORACLE_URL="jdbc:oracle:thin:@//localhost:1522/XEPDB1" # contenedor db
export ORACLE_USERNAME="curso"
export ORACLE_PASSWORD="curso123"
export JWT_SECRET="cambiar-este-secreto-en-produccion-minimo-32-caracteres"

mvn spring-boot:run
```

Health check:

```bash
curl -s http://localhost:8080/api/health | python3 -m json.tool
```

#### Opción B — Contenedor Docker

**Con BD en contenedor** (levantar `db` antes o junto):

```bash
docker compose --profile db --profile backend up -d
```

**Sin BD en contenedor** (Oracle en el host):

```bash
ORACLE_URL="jdbc:oracle:thin:@//host.docker.internal:1521/XEPDB1" \
  docker compose --profile backend up -d
```

**Solo backend** (BD del contenedor ya corriendo):

```bash
docker compose --profile backend up -d
```

---

### 3. Frontend

#### Opción A — Local (Angular dev server)

```bash
cd frontend
npm install
npm start
```

Abrir http://localhost:4200 — el proxy redirige `/api` al backend en `localhost:8080`.

#### Opción B — Contenedor Docker

**Con backend en contenedor:**

```bash
docker compose --profile frontend up -d
# o junto con backend:
docker compose --profile backend --profile frontend up -d
```

**Con backend local en el host** (sin contenedor backend):

```bash
BACKEND_UPSTREAM="host.docker.internal:8080" \
  docker compose --profile frontend up -d
```

Abrir http://localhost:4200

---

## Docker Compose — referencia rápida

Los servicios usan **perfiles**. Sin perfil, no se levanta nada.

| Perfil | Servicio | Puerto host |
|--------|----------|-------------|
| `db` | Oracle XE + scripts automáticos | 1522 |
| `backend` | Spring Boot API | 8080 |
| `frontend` | Angular (nginx) | 4200 |
| `stack` | Los tres juntos | 1522, 8080, 4200 |

```bash
# Variables opcionales (copiar ejemplo)
cp .env.docker.example .env

# Escenarios frecuentes
docker compose --profile stack up -d          # todo en Docker
docker compose --profile db up -d             # solo BD
docker compose --profile backend up -d        # solo API
docker compose --profile frontend up -d       # solo UI

# Detener
docker compose --profile stack down
docker compose --profile db down              # conserva volumen oracle_data
docker compose --profile db down -v           # borra datos de Oracle
```

### Combinaciones útiles para demo

| Qué quieres mostrar | Comando |
|---------------------|---------|
| Stack completo en Docker | `docker compose --profile stack up -d` |
| BD en Docker, resto local | `docker compose --profile db up -d` → backend y frontend con Maven/npm |
| Sin BD Docker (Oracle del host) | No usar perfil `db`; backend/frontend local o con `ORACLE_URL` / `BACKEND_UPSTREAM` apuntando al host |
| Solo UI (backend ya corriendo) | `BACKEND_UPSTREAM=host.docker.internal:8080 docker compose --profile frontend up -d` |

---

## Flujo demo end-to-end (cliente)

1. Login como `juan@email.com` / `Secreta123`
2. Cartelera → seleccionar fecha (mañana) → ver función
3. Seleccionar asientos → confirmar reserva
4. Checkout → simular pago
5. Mis reservas → verificar estado PAGADA

> Las funciones demo se crean con fechas futuras (`SYSTIMESTAMP + 1 día`). En cartelera, selecciona la fecha de mañana o posterior.

## Flujo demo administrativo

Login como `admin@cinezaror.cl` / `Secreta123` → menú **Administración**.

1. **Películas** → **Nueva película**
2. **Salas** → **Nueva sala** → **Generar asientos**
3. **Funciones** → **Nueva función** (fecha/hora futura)
4. Cerrar sesión admin → **Cartelera** → verificar la función creada

| Entidad | Listar | Crear | Editar | Activar/Desactivar | Extra |
|---------|--------|-------|--------|--------------------|-------|
| Películas | Sí | Sí | Sí | Sí | — |
| Salas | Sí | Sí | Sí* | Sí | Generar asientos |
| Funciones | Sí | Sí | Sí** | Sí | — |

\* Editar filas/columnas solo si la sala no tiene asientos generados.  
\** Editar solo funciones futuras; no se puede cambiar sala si hay reservas pagadas.

---

## Pruebas

```bash
# SQL
sqlplus curso/curso123@localhost/XEPDB1 @database/sql/10_tests.sql

# Backend
cd backend && mvn test && mvn package

# Frontend
cd frontend && npm run build
```

## Login rápido (curl)

```bash
curl -s -X POST http://localhost:8080/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"correo":"juan@email.com","password":"Secreta123"}'
```
