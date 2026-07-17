import { Component, OnInit, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';

import { AdminService, SalaForm } from '../../../core/services/admin.service';
import { NotificationService } from '../../../shared/services/notification.service';
import { isActivo, rowNum, rowStr } from '../admin-row.util';
import { SalaFormDialogComponent } from './sala-form-dialog.component';

@Component({
  selector: 'app-salas-admin',
  standalone: true,
  imports: [MatCardModule, MatTableModule, MatButtonModule, MatIconModule, MatDialogModule],
  template: `
    <mat-card>
      <mat-card-header class="header">
        <mat-card-title>Salas</mat-card-title>
        <button mat-flat-button color="primary" (click)="nueva()">
          <mat-icon>add</mat-icon> Nueva sala
        </button>
      </mat-card-header>
      <mat-card-content>
        <table mat-table [dataSource]="salas" class="full">
          <ng-container matColumnDef="nombre">
            <th mat-header-cell *matHeaderCellDef>Nombre</th>
            <td mat-cell *matCellDef="let s">{{ rowStr(s, 'nombre') }}</td>
          </ng-container>
          <ng-container matColumnDef="filas">
            <th mat-header-cell *matHeaderCellDef>Filas</th>
            <td mat-cell *matCellDef="let s">{{ rowNum(s, 'filas') }}</td>
          </ng-container>
          <ng-container matColumnDef="columnas">
            <th mat-header-cell *matHeaderCellDef>Cols</th>
            <td mat-cell *matCellDef="let s">{{ rowNum(s, 'columnas') }}</td>
          </ng-container>
          <ng-container matColumnDef="asientos">
            <th mat-header-cell *matHeaderCellDef>Asientos</th>
            <td mat-cell *matCellDef="let s">{{ rowNum(s, 'cantidadAsientos') }}</td>
          </ng-container>
          <ng-container matColumnDef="activa">
            <th mat-header-cell *matHeaderCellDef>Estado</th>
            <td mat-cell *matCellDef="let s">{{ isActivo(s) ? 'Activa' : 'Inactiva' }}</td>
          </ng-container>
          <ng-container matColumnDef="acciones">
            <th mat-header-cell *matHeaderCellDef>Acciones</th>
            <td mat-cell *matCellDef="let s">
              <button mat-icon-button (click)="editar(s)" aria-label="Editar"><mat-icon>edit</mat-icon></button>
              <button mat-icon-button (click)="toggleEstado(s)" [attr.aria-label]="isActivo(s) ? 'Desactivar' : 'Activar'">
                <mat-icon>{{ isActivo(s) ? 'visibility_off' : 'visibility' }}</mat-icon>
              </button>
              @if (rowNum(s, 'cantidadAsientos') === 0) {
                <button mat-stroked-button (click)="generar(s)">Generar asientos</button>
              }
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
export class SalasAdminComponent implements OnInit {
  private readonly admin = inject(AdminService);
  private readonly notification = inject(NotificationService);
  private readonly dialog = inject(MatDialog);

  readonly rowStr = rowStr;
  readonly rowNum = rowNum;
  readonly isActivo = isActivo;

  salas: Record<string, unknown>[] = [];
  cols = ['nombre', 'filas', 'columnas', 'asientos', 'activa', 'acciones'];

  ngOnInit(): void {
    this.cargar();
  }

  cargar(): void {
    this.admin.listarSalas().subscribe({
      next: (d) => (this.salas = d),
      error: (e) => this.notification.error(e)
    });
  }

  nueva(): void {
    this.abrirDialog(undefined);
  }

  editar(s: Record<string, unknown>): void {
    this.abrirDialog(s);
  }

  private abrirDialog(sala?: Record<string, unknown>): void {
    const ref = this.dialog.open(SalaFormDialogComponent, {
      width: '420px',
      data: { sala }
    });
    ref.afterClosed().subscribe((body: SalaForm | undefined) => {
      if (!body) return;
      const id = rowNum(sala ?? {}, 'idSala');
      if (sala) {
        this.admin.actualizarSala(id, body).subscribe({
          next: () => {
            this.notification.success('Sala actualizada');
            this.cargar();
          },
          error: (e: unknown) => this.notification.error(e)
        });
      } else {
        this.admin.crearSala(body).subscribe({
          next: () => {
            this.notification.success('Sala creada');
            this.cargar();
          },
          error: (e: unknown) => this.notification.error(e)
        });
      }
    });
  }

  toggleEstado(s: Record<string, unknown>): void {
    const id = rowNum(s, 'idSala');
    const activo = !isActivo(s);
    this.admin.cambiarEstadoSala(id, activo).subscribe({
      next: () => {
        this.notification.success(activo ? 'Sala activada' : 'Sala desactivada');
        this.cargar();
      },
      error: (e) => this.notification.error(e)
    });
  }

  generar(s: Record<string, unknown>): void {
    const id = rowNum(s, 'idSala');
    this.admin.generarAsientos(id).subscribe({
      next: () => {
        this.notification.success('Asientos generados');
        this.cargar();
      },
      error: (e) => this.notification.error(e)
    });
  }
}
