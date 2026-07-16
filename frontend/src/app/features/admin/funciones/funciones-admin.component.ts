import { Component, OnInit, inject } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatTableModule } from '@angular/material/table';
import { DatePipe } from '@angular/common';

import { AdminService } from '../../../core/services/admin.service';
import { NotificationService } from '../../../shared/services/notification.service';

@Component({
  selector: 'app-funciones-admin',
  standalone: true,
  imports: [MatCardModule, MatTableModule, DatePipe],
  template: `
    <mat-card>
      <mat-card-header><mat-card-title>Funciones</mat-card-title></mat-card-header>
      <mat-card-content>
        <table mat-table [dataSource]="funciones" class="full">
          <ng-container matColumnDef="pelicula"><th mat-header-cell *matHeaderCellDef>Película</th><td mat-cell *matCellDef="let f">{{ f['PELICULA'] || f['pelicula'] }}</td></ng-container>
          <ng-container matColumnDef="sala"><th mat-header-cell *matHeaderCellDef>Sala</th><td mat-cell *matCellDef="let f">{{ f['SALA'] || f['sala'] }}</td></ng-container>
          <ng-container matColumnDef="fecha"><th mat-header-cell *matHeaderCellDef>Fecha</th><td mat-cell *matCellDef="let f">{{ f['FECHA_HORA'] || f['fechaHora'] | date:'short' }}</td></ng-container>
          <ng-container matColumnDef="precio"><th mat-header-cell *matHeaderCellDef>Precio</th><td mat-cell *matCellDef="let f">{{ f['PRECIO'] || f['precio'] }}</td></ng-container>
          <tr mat-header-row *matHeaderRowDef="cols"></tr>
          <tr mat-row *matRowDef="let row; columns: cols"></tr>
        </table>
      </mat-card-content>
    </mat-card>
  `,
  styles: `.full { width: 100%; }`
})
export class FuncionesAdminComponent implements OnInit {
  private readonly admin = inject(AdminService);
  private readonly notification = inject(NotificationService);
  funciones: Record<string, unknown>[] = [];
  cols = ['pelicula', 'sala', 'fecha', 'precio'];

  ngOnInit(): void {
    this.admin.listarFunciones().subscribe({
      next: (d) => this.funciones = d,
      error: (e) => this.notification.error(e)
    });
  }
}
