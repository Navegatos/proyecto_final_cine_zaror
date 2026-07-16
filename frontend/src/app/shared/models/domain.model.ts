export interface CarteleraItem {
  funcionId: number;
  peliculaId: number;
  titulo: string;
  clasificacion: string;
  duracionMinutos: number;
  genero: string;
  salaId: number;
  sala: string;
  fecha: string;
  hora: string;
  fechaHora: string;
  precio: number;
  asientosDisponibles: number;
}

export interface FuncionDetalle {
  funcionId: number;
  peliculaId: number;
  titulo: string;
  sinopsis: string;
  duracionMinutos: number;
  clasificacion: string;
  salaId: number;
  sala: string;
  fechaHora: string;
  precio: number;
  asientosDisponibles: number;
}

export interface Asiento {
  id: number;
  fila: string;
  numero: number;
  estado: 'DISPONIBLE' | 'OCUPADO' | 'INACTIVO' | 'SELECCIONADO';
}

export interface AsientosResponse {
  funcionId: number;
  sala: string;
  asientos: Asiento[];
}

export interface ReservaResponse {
  reservaId: number;
  codigo: string;
  cantidad: number;
  total: number;
  estado: string;
}

export interface ReservaDetalle {
  reservaId: number;
  codigo: string;
  pelicula: string;
  fechaHora: string;
  sala: string;
  asientos: string;
  total: number;
  estado: string;
}
