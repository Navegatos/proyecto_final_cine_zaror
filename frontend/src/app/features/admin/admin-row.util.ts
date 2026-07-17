/** Lee valores de filas Oracle (columnas en mayúsculas) o del API camelCase. */
export function rowVal(row: Record<string, unknown>, key: string): unknown {
  const upper = key.replace(/([A-Z])/g, '_$1').toUpperCase().replace(/^_/, '');
  const camel = key.charAt(0).toLowerCase() + key.slice(1);
  return row[upper] ?? row[key] ?? row[camel];
}

export function rowNum(row: Record<string, unknown>, key: string): number {
  return Number(rowVal(row, key));
}

export function rowStr(row: Record<string, unknown>, key: string): string {
  const v = rowVal(row, key);
  return v == null ? '' : String(v);
}

export function isActivo(row: Record<string, unknown>, key = 'activa'): boolean {
  const v = rowVal(row, key);
  return v === 1 || v === true || v === '1';
}
