export interface LoginRequest {
  correo: string;
  password: string;
}

export interface RegisterRequest {
  rut: string;
  nombreCompleto: string;
  correo: string;
  password: string;
}

export interface LoginResponse {
  token: string;
  nombre: string;
  rol: 'CLIENTE' | 'ADMIN';
}

export interface AuthUser {
  nombre: string;
  rol: 'CLIENTE' | 'ADMIN';
}
