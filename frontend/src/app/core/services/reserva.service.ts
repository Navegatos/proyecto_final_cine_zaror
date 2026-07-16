import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';

import { environment } from '../../../environments/environment';
import { ApiResponse } from '../../shared/models/api-response.model';
import { ReservaDetalle, ReservaResponse } from '../../shared/models/domain.model';

@Injectable({ providedIn: 'root' })
export class ReservaService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = environment.apiUrl;

  crear(funcionId: number, asientoIds: number[]): Observable<ReservaResponse> {
    return this.http
      .post<ApiResponse<ReservaResponse>>(`${this.apiUrl}/reservas`, { funcionId, asientoIds })
      .pipe(map((r) => r.data!));
  }

  pagar(reservaId: number, metodo: string): Observable<unknown> {
    return this.http
      .post<ApiResponse<unknown>>(`${this.apiUrl}/reservas/${reservaId}/pago`, { metodo })
      .pipe(map((r) => r.data));
  }

  misReservas(): Observable<ReservaDetalle[]> {
    return this.http
      .get<ApiResponse<ReservaDetalle[]>>(`${this.apiUrl}/reservas/mis-reservas`)
      .pipe(map((r) => r.data ?? []));
  }

  obtener(id: number): Observable<ReservaDetalle> {
    return this.http
      .get<ApiResponse<ReservaDetalle>>(`${this.apiUrl}/reservas/${id}`)
      .pipe(map((r) => r.data!));
  }
}
