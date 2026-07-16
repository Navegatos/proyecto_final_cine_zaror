import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';

import { environment } from '../../../environments/environment';
import { ApiResponse } from '../../shared/models/api-response.model';

@Injectable({ providedIn: 'root' })
export class AdminService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = `${environment.apiUrl}/admin`;

  listarPeliculas(): Observable<Record<string, unknown>[]> {
    return this.http.get<ApiResponse<Record<string, unknown>[]>>(`${this.apiUrl}/peliculas`).pipe(map((r) => r.data ?? []));
  }

  crearPelicula(body: Record<string, unknown>): Observable<number> {
    return this.http.post<ApiResponse<number>>(`${this.apiUrl}/peliculas`, body).pipe(map((r) => r.data!));
  }

  listarSalas(): Observable<Record<string, unknown>[]> {
    return this.http.get<ApiResponse<Record<string, unknown>[]>>(`${this.apiUrl}/salas`).pipe(map((r) => r.data ?? []));
  }

  crearSala(body: Record<string, unknown>): Observable<number> {
    return this.http.post<ApiResponse<number>>(`${this.apiUrl}/salas`, body).pipe(map((r) => r.data!));
  }

  generarAsientos(salaId: number): Observable<void> {
    return this.http.post<ApiResponse<void>>(`${this.apiUrl}/salas/${salaId}/generar-asientos`, {}).pipe(map(() => undefined));
  }

  listarFunciones(): Observable<Record<string, unknown>[]> {
    return this.http.get<ApiResponse<Record<string, unknown>[]>>(`${this.apiUrl}/funciones`).pipe(map((r) => r.data ?? []));
  }

  crearFuncion(body: Record<string, unknown>): Observable<number> {
    return this.http.post<ApiResponse<number>>(`${this.apiUrl}/funciones`, body).pipe(map((r) => r.data!));
  }
}
