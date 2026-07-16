#!/bin/bash
set -euo pipefail

SQL_DIR="${SQL_DIR:-/opt/cinezaror/sql}"

echo "==> Cine Zaror: aplicando scripts SQL (01-08)..."

SCRIPTS=(
  "01_tables.sql"
  "02_sequences.sql"
  "03_constraints.sql"
  "04_functions.sql"
  "05_procedures.sql"
  "06_triggers.sql"
  "07_views.sql"
  "08_seed.sql"
)

for script in "${SCRIPTS[@]}"; do
  echo "    Ejecutando ${script}..."
  sqlplus -s "${APP_USER}/${APP_USER_PASSWORD}@//localhost/XEPDB1" @"${SQL_DIR}/${script}"
done

echo "==> Esquema Cine Zaror listo."
