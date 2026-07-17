import { Component, OnInit, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatDialog, MatDialogModule } from '@angular/material/dialog';
import { MatIconModule } from '@angular/material/icon';
import { MatTableModule } from '@angular/material/table';

import { AdminService, PeliculaForm } from '../../../core/services/admin.service';
import { NotificationService } from '../../../shared/services/notification.service';
import { isActivo, rowNum, rowStr } from '../admin-row.util';
import { PeliculaFormDialogComponent } from './pelicula-form-dialog.component';

@Component({
  selector: 'app-peliculas-admin',
  standalone: true,
  imports: [MatCardModule, MatTableModule, MatButtonModule, MatIconModule, MatDialogModule],
  template: `
    <mat-card>
      <mat-card-header class="header">
        <mat-card-title>Películas</mat-card-title>
        <button mat-flat-button color="primary" (click)="nueva()">
          <mat-icon>add</mat-icon> Nueva película
        </button>
      </mat-card-header>
      <mat-card-content>
        <table mat-table [dataSource]="peliculas" class="full">
          <ng-container matColumnDef="titulo">
            <th mat-header-cell *matHeaderCellDef>Título</th>
            <td mat-cell *matCellDef="let p">{{ rowStr(p, 'titulo') }}</td>
          </ng-container>
          <ng-container matColumnDef="clasificacion">
            <th mat-header-cell *matHeaderCellDef>Clasif.</th>
            <td mat-cell *matCellDef="let p">{{ rowStr(p, 'clasificacion') }}</td>
          </ng-container>
          <ng-container matColumnDef="duracion">
            <th mat-header-cell *matHeaderCellDef>Duración</th>
            <td mat-cell *matCellDef="let p">{{ rowNum(p, 'duracionMinutos') }} min</td>
          </ng-container>
          <ng-container matColumnDef="activa">
            <th mat-header-cell *matHeaderCellDef>Estado</th>
            <td mat-cell *matCellDef="let p">{{ isActivo(p) ? 'Activa' : 'Inactiva' }}</td>
          </ng-container>
          <ng-container matColumnDef="acciones">
            <th mat-header-cell *matHeaderCellDef>Acciones</th>
            <td mat-cell *matCellDef="let p">
              <button mat-icon-button (click)="editar(p)" aria-label="Editar"><mat-icon>edit</mat-icon></button>
              <button mat-icon-button (click)="toggleEstado(p)" [attr.aria-label]="isActivo(p) ? 'Desactivar' : 'Activar'">
                <mat-icon>{{ isActivo(p) ? 'visibility_off' : 'visibility' }}</mat-icon>
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
export class PeliculasAdminComponent implements OnInit {
  private readonly admin = inject(AdminService);
  private readonly notification = inject(NotificationService);
  private readonly dialog = inject(MatDialog);

  readonly rowStr = rowStr;
  readonly rowNum = rowNum;
  readonly isActivo = isActivo;

  peliculas: Record<string, unknown>[] = [];
  cols = ['titulo', 'clasificacion', 'duracion', 'activa', 'acciones'];

  ngOnInit(): void {
    this.cargar();
  }

  cargar(): void {
    this.admin.listarPeliculas().subscribe({
      next: (d) => (this.peliculas = d),
      error: (e) => this.notification.error(e)
    });
  }

  nueva(): void {
    this.abrirDialog(undefined);
  }

  editar(p: Record<string, unknown>): void {
    this.abrirDialog(p);
  }

  private abrirDialog(pelicula?: Record<string, unknown>): void {
    const ref = this.dialog.open(PeliculaFormDialogComponent, {
      width: '480px',
      data: { pelicula }
    });
    ref.afterClosed().subscribe((body: PeliculaForm | undefined) => {
      if (!body) return;
      const id = rowNum(pelicula ?? {}, 'idPelicula');
      if (pelicula) {
        this.admin.actualizarPelicula(id, body).subscribe({
          next: () => {
            this.notification.success('Película actualizada');
            this.cargar();
          },
          error: (e: unknown) => this.notification.error(e)
        });
      } else {
        this.admin.crearPelicula(body).subscribe({
          next: () => {
            this.notification.success('Película creada');
            this.cargar();
          },
          error: (e: unknown) => this.notification.error(e)
        });
      }
    });
  }

  toggleEstado(p: Record<string, unknown>): void {
    const id = rowNum(p, 'idPelicula');
    const activo = !isActivo(p);
    this.admin.cambiarEstadoPelicula(id, activo).subscribe({
      next: () => {
        this.notification.success(activo ? 'Película activada' : 'Película desactivada');
        this.cargar();
      },
      error: (e) => this.notification.error(e)
    });
  }
}
