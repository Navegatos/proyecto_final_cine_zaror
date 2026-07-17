import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';

import { environment } from '../../../environments/environment';
import { ApiResponse } from '../../shared/models/api-response.model';

export interface PeliculaForm {
  titulo: string;
  sinopsis?: string;
  duracionMinutos: number;
  clasificacion: string;
  genero?: string;
  urlImagen?: string;
}

export interface SalaForm {
  nombre: string;
  filas: number;
  columnas: number;
}

export interface FuncionForm {
  peliculaId: number;
  salaId: number;
  fechaHora: string;
  precio: number;
}

@Injectable({ providedIn: 'root' })
export class AdminService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/admin`;

  listarPeliculas(): Observable<Record<string, unknown>[]> {
    return this.http.get<ApiResponse<Record<string, unknown>[]>>(`${this.apiUrl}/peliculas`).pipe(map((r) => r.data ?? []));
  }

  crearPelicula(body: PeliculaForm): Observable<number> {
    return this.http.post<ApiResponse<number>>(`${this.apiUrl}/peliculas`, body).pipe(map((r) => r.data!));
  }

  actualizarPelicula(id: number, body: PeliculaForm): Observable<void> {
    return this.http.put<ApiResponse<void>>(`${this.apiUrl}/peliculas/${id}`, body).pipe(map(() => undefined));
  }

  cambiarEstadoPelicula(id: number, activo: boolean): Observable<void> {
    return this.http
      .patch<ApiResponse<void>>(`${this.apiUrl}/peliculas/${id}/estado`, { activo })
      .pipe(map(() => undefined));
  }

  listarSalas(): Observable<Record<string, unknown>[]> {
    return this.http.get<ApiResponse<Record<string, unknown>[]>>(`${this.apiUrl}/salas`).pipe(map((r) => r.data ?? []));
  }

  crearSala(body: SalaForm): Observable<number> {
    return this.http.post<ApiResponse<number>>(`${this.apiUrl}/salas`, body).pipe(map((r) => r.data!));
  }

  actualizarSala(id: number, body: SalaForm): Observable<void> {
    return this.http.put<ApiResponse<void>>(`${this.apiUrl}/salas/${id}`, body).pipe(map(() => undefined));
  }

  cambiarEstadoSala(id: number, activo: boolean): Observable<void> {
    return this.http
      .patch<ApiResponse<void>>(`${this.apiUrl}/salas/${id}/estado`, { activo })
      .pipe(map(() => undefined));
  }

  generarAsientos(salaId: number): Observable<void> {
    return this.http.post<ApiResponse<void>>(`${this.apiUrl}/salas/${salaId}/generar-asientos`, {}).pipe(map(() => undefined));
  }

  listarFunciones(): Observable<Record<string, unknown>[]> {
    return this.http.get<ApiResponse<Record<string, unknown>[]>>(`${this.apiUrl}/funciones`).pipe(map((r) => r.data ?? []));
  }

  crearFuncion(body: FuncionForm): Observable<number> {
    return this.http.post<ApiResponse<number>>(`${this.apiUrl}/funciones`, body).pipe(map((r) => r.data!));
  }

  actualizarFuncion(id: number, body: FuncionForm): Observable<void> {
    return this.http.put<ApiResponse<void>>(`${this.apiUrl}/funciones/${id}`, body).pipe(map(() => undefined));
  }

  cambiarEstadoFuncion(id: number, activo: boolean): Observable<void> {
    return this.http
      .patch<ApiResponse<void>>(`${this.apiUrl}/funciones/${id}/estado`, { activo })
      .pipe(map(() => undefined));
  }
}
