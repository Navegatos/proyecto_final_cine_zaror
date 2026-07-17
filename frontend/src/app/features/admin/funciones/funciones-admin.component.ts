import { DatePipe, DecimalPipe } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';
import { forkJoin } from 'rxjs';

import { AdminService, FuncionForm } from '../../../core/services/admin.service';
import { NotificationService } from '../../../shared/services/notification.service';
import { isActivo, rowNum, rowStr, rowVal } from '../admin-row.util';
import { FuncionFormDialogComponent } from './funcion-form-dialog.component';

@Component({
  selector: 'app-funciones-admin',
  standalone: true,
  imports: [MatCardModule, MatTableModule, MatButtonModule, MatIconModule, MatDialogModule, DatePipe, DecimalPipe],
  template: `
    <mat-card>
      <mat-card-header class="header">
        <mat-card-title>Funciones</mat-card-title>
        <button mat-flat-button color="primary" (click)="nueva()">
          <mat-icon>add</mat-icon> Nueva función
        </button>
      </mat-card-header>
      <mat-card-content>
        <table mat-table [dataSource]="funciones" class="full">
          <ng-container matColumnDef="pelicula">
            <th mat-header-cell *matHeaderCellDef>Película</th>
            <td mat-cell *matCellDef="let f">{{ rowStr(f, 'pelicula') }}</td>
          </ng-container>
          <ng-container matColumnDef="sala">
            <th mat-header-cell *matHeaderCellDef>Sala</th>
            <td mat-cell *matCellDef="let f">{{ rowStr(f, 'sala') }}</td>
          </ng-container>
          <ng-container matColumnDef="fecha">
            <th mat-header-cell *matHeaderCellDef>Fecha</th>
            <td mat-cell *matCellDef="let f">{{ fechaDisplay(f) | date:'short' }}</td>
          </ng-container>
          <ng-container matColumnDef="precio">
            <th mat-header-cell *matHeaderCellDef>Precio</th>
            <td mat-cell *matCellDef="let f">{{ rowNum(f, 'precio') | number }}</td>
          </ng-container>
          <ng-container matColumnDef="activa">
            <th mat-header-cell *matHeaderCellDef>Estado</th>
            <td mat-cell *matCellDef="let f">{{ isActivo(f) ? 'Activa' : 'Inactiva' }}</td>
          </ng-container>
          <ng-container matColumnDef="acciones">
            <th mat-header-cell *matHeaderCellDef>Acciones</th>
            <td mat-cell *matCellDef="let f">
              @if (esFutura(f)) {
                <button mat-icon-button (click)="editar(f)" aria-label="Editar"><mat-icon>edit</mat-icon></button>
              }
              <button mat-icon-button (click)="toggleEstado(f)" [attr.aria-label]="isActivo(f) ? 'Desactivar' : 'Activar'">
                <mat-icon>{{ isActivo(f) ? 'visibility_off' : 'visibility' }}</mat-icon>
              </button>
            </td>
          </ng-container>
          <tr mat-header-row *matHeaderRowDef="cols"></tr>
          <tr mat-row *matRowDef="let row; columns: cols"></tr>
        </table>
      </mat-card-content>
    </mat-card>
  `,
  styles: `
    .full { width: 100%; }
    .header { display: flex; align-items: center; justify-content: space-between; width: 100%; padding-bottom: 8px; }
  `
})
export class FuncionesAdminComponent implements OnInit {
  private readonly admin = inject(AdminService);
  private readonly notification = inject(NotificationService);
  private readonly dialog = inject(MatDialog);

  readonly rowStr = rowStr;
  readonly rowNum = rowNum;
  readonly rowVal = rowVal;
  readonly isActivo = isActivo;

  funciones: Record<string, unknown>[] = [];
  peliculas: Record<string, unknown>[] = [];
  salas: Record<string, unknown>[] = [];
  cols = ['pelicula', 'sala', 'fecha', 'precio', 'activa', 'acciones'];

  ngOnInit(): void {
    this.cargar();
  }

  cargar(): void {
    forkJoin({
      funciones: this.admin.listarFunciones(),
      peliculas: this.admin.listarPeliculas(),
      salas: this.admin.listarSalas()
    }).subscribe({
      next: ({ funciones, peliculas, salas }) => {
        this.funciones = funciones;
        this.peliculas = peliculas;
        this.salas = salas;
      },
      error: (e) => this.notification.error(e)
    });
  }

  esFutura(f: Record<string, unknown>): boolean {
    const raw = rowVal(f, 'fechaHora');
    if (!raw) return false;
    return new Date(String(raw)).getTime() > Date.now();
  }

  fechaDisplay(f: Record<string, unknown>): Date | null {
    const raw = rowVal(f, 'fechaHora');
    return raw ? new Date(String(raw)) : null;
  }

  nueva(): void {
    this.abrirDialog(undefined);
  }

  editar(f: Record<string, unknown>): void {
    if (!this.esFutura(f)) {
      this.notification.error(new Error('Solo se pueden editar funciones futuras'));
      return;
    }
    this.abrirDialog(f);
  }

  private abrirDialog(funcion?: Record<string, unknown>): void {
    const ref = this.dialog.open(FuncionFormDialogComponent, {
      width: '440px',
      data: { funcion, peliculas: this.peliculas, salas: this.salas }
    });
    ref.afterClosed().subscribe((body: FuncionForm | undefined) => {
      if (!body) return;
      const id = rowNum(funcion ?? {}, 'idFuncion');
      if (funcion) {
        this.admin.actualizarFuncion(id, body).subscribe({
          next: () => {
            this.notification.success('Función actualizada');
            this.cargar();
          },
          error: (e: unknown) => this.notification.error(e)
        });
      } else {
        this.admin.crearFuncion(body).subscribe({
          next: () => {
            this.notification.success('Función creada');
            this.cargar();
          },
          error: (e: unknown) => this.notification.error(e)
        });
      }
    });
  }

  toggleEstado(f: Record<string, unknown>): void {
    const id = rowNum(f, 'idFuncion');
    const activo = !isActivo(f);
    this.admin.cambiarEstadoFuncion(id, activo).subscribe({
      next: () => {
        this.notification.success(activo ? 'Función activada' : 'Función desactivada');
        this.cargar();
      },
      error: (e) => this.notification.error(e)
    });
  }
}
