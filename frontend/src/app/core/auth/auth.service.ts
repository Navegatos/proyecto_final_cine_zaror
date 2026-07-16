import { HttpClient } from '@angular/common/http';
import { Injectable, inject } from '@angular/core';
import { Router } from '@angular/router';
import { Observable, map, tap } from 'rxjs';

import { environment } from '../../../environments/environment';
import {
  AuthUser,
  LoginRequest,
  LoginResponse,
  RegisterRequest
} from '../../shared/models/auth.model';
import { ApiResponse } from '../../shared/models/api-response.model';

const TOKEN_KEY = 'cz_token';
const USER_KEY = 'cz_user';

@Injectable({ providedIn: 'root' })
export class AuthService {
  private readonly http = inject(HttpClient);
  private readonly router = inject(Router);
  private readonly apiUrl = environment.apiUrl;

  login(request: LoginRequest): Observable<LoginResponse> {
    return this.http
      .post<LoginResponse | ApiResponse<LoginResponse>>(`${this.apiUrl}/auth/login`, request)
      .pipe(
        map((response) => this.unwrapData(response)),
        tap((data) => this.persistSession(data))
      );
  }

  register(request: RegisterRequest): Observable<void> {
    return this.http
      .post<ApiResponse<void>>(`${this.apiUrl}/auth/register`, request)
      .pipe(
        map((response) => {
          if (!response.success) {
            throw new Error(response.message);
          }
        })
      );
  }

  logout(): void {
    localStorage.removeItem(TOKEN_KEY);
    localStorage.removeItem(USER_KEY);
    this.router.navigate(['/login']);
  }

  getToken(): string | null {
    return localStorage.getItem(TOKEN_KEY);
  }

  getCurrentUser(): AuthUser | null {
    const raw = localStorage.getItem(USER_KEY);
    return raw ? (JSON.parse(raw) as AuthUser) : null;
  }

  isAuthenticated(): boolean {
    return !!this.getToken();
  }

  isAdmin(): boolean {
    return this.getCurrentUser()?.rol === 'ADMIN';
  }

  private persistSession(data: LoginResponse): void {
    localStorage.setItem(TOKEN_KEY, data.token);
    localStorage.setItem(
      USER_KEY,
      JSON.stringify({ nombre: data.nombre, rol: data.rol } satisfies AuthUser)
    );
  }

  private unwrapData(response: LoginResponse | ApiResponse<LoginResponse>): LoginResponse {
    if ('token' in response) {
      return response;
    }

    if (!response.success || !response.data) {
      throw new Error(response.message);
    }

    return response.data;
  }
}
