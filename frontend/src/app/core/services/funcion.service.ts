import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';

import { environment } from '../../../environments/environment';
import { ApiResponse } from '../../shared/models/api-response.model';
import { AsientosResponse, FuncionDetalle } from '../../shared/models/domain.model';

@Injectable({ providedIn: 'root' })
export class FuncionService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = environment.apiUrl;

  obtenerDetalle(id: number): Observable<FuncionDetalle> {
    return this.http
      .get<ApiResponse<FuncionDetalle>>(`${this.apiUrl}/funciones/${id}`)
      .pipe(map((r) => r.data!));
  }

  obtenerAsientos(id: number): Observable<AsientosResponse> {
    return this.http.get<AsientosResponse>(`${this.apiUrl}/funciones/${id}/asientos`);
  }
}
