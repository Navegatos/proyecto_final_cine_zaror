import { Injectable, inject } from '@angular/core';
import { MatSnackBar } from '@angular/material/snack-bar';
import { HttpErrorResponse } from '@angular/common/http';

@Injectable({ providedIn: 'root' })
export class NotificationService {
  private readonly snackBar = inject(MatSnackBar);

  success(message: string): void {
    this.snackBar.open(message, 'Cerrar', { duration: 3000 });
  }

  error(error: unknown): void {
    let message = 'Ocurrió un error inesperado';
    if (error instanceof HttpErrorResponse) {
      message = error.error?.message ?? error.message;
    } else if (error instanceof Error) {
      message = error.message;
    }
    this.snackBar.open(message, 'Cerrar', { duration: 5000, panelClass: ['snack-error'] });
  }
}
