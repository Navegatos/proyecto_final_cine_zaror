FROM gvenzl/oracle-xe:21-slim

COPY sql/ /opt/cinezaror/sql/
COPY --chmod=755 init/ /container-entrypoint-initdb.d/
