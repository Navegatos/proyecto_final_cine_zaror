import { Component, OnInit, inject } from '@angular/core';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatTableModule } from '@angular/material/table';

import { AdminService } from '../../../core/services/admin.service';
import { NotificationService } from '../../../shared/services/notification.service';

@Component({
  selector: 'app-salas-admin',
  standalone: true,
  imports: [MatCardModule, MatTableModule, MatButtonModule],
  template: `
    <mat-card>
      <mat-card-header><mat-card-title>Salas</mat-card-title></mat-card-header>
      <mat-card-content>
        <table mat-table [dataSource]="salas" class="full">
          <ng-container matColumnDef="nombre"><th mat-header-cell *matHeaderCellDef>Nombre</th><td mat-cell *matCellDef="let s">{{ s['NOMBRE'] || s['nombre'] }}</td></ng-container>
          <ng-container matColumnDef="filas"><th mat-header-cell *matHeaderCellDef>Filas</th><td mat-cell *matCellDef="let s">{{ s['FILAS'] || s['filas'] }}</td></ng-container>
          <ng-container matColumnDef="columnas"><th mat-header-cell *matHeaderCellDef>Cols</th><td mat-cell *matCellDef="let s">{{ s['COLUMNAS'] || s['columnas'] }}</td></ng-container>
          <ng-container matColumnDef="accion"><th mat-header-cell *matHeaderCellDef></th>
            <td mat-cell *matCellDef="let s">
              <button mat-button (click)="generar(s['ID_SALA'] || s['idSala'])">Generar asientos</button>
            </td>
          </ng-container>
          <tr mat-header-row *matHeaderRowDef="cols"></tr>
          <tr mat-row *matRowDef="let row; columns: cols"></tr>
        </table>
      </mat-card-content>
    </mat-card>
  `,
  styles: `.full { width: 100%; }`
})
export class SalasAdminComponent implements OnInit {
  private readonly admin = inject(AdminService);
  private readonly notification = inject(NotificationService);
  salas: Record<string, unknown>[] = [];
  cols = ['nombre', 'filas', 'columnas', 'accion'];

  ngOnInit(): void {
    this.admin.listarSalas().subscribe({
      next: (d) => this.salas = d,
      error: (e) => this.notification.error(e)
    });
  }

  generar(id: number): void {
    this.admin.generarAsientos(id).subscribe({
      next: () => this.notification.success('Asientos generados'),
      error: (e) => this.notification.error(e)
    });
  }
}
