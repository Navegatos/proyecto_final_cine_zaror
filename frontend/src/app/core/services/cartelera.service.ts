import { HttpClient, HttpParams } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Observable, map } from 'rxjs';

import { environment } from '../../../environments/environment';
import { ApiResponse } from '../../shared/models/api-response.model';
import { CarteleraItem } from '../../shared/models/domain.model';

@Injectable({ providedIn: 'root' })
export class CarteleraService {
  private readonly http = inject(HttpClient);
  private readonly apiUrl = environment.apiUrl;

  obtenerPorFecha(fecha: string): Observable<CarteleraItem[]> {
    const params = new HttpParams().set('fecha', fecha);
    return this.http
      .get<ApiResponse<CarteleraItem[]>>(`${this.apiUrl}/cartelera`, { params })
      .pipe(map((r) => r.data ?? []));
  }
}
