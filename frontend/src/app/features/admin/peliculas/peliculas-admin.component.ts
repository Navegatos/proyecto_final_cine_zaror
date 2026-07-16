import { Component, OnInit, inject } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatTableModule } from '@angular/material/table';

import { AdminService } from '../../../core/services/admin.service';
import { NotificationService } from '../../../shared/services/notification.service';

@Component({
  selector: 'app-peliculas-admin',
  standalone: true,
  imports: [MatCardModule, MatTableModule],
  template: `
    <mat-card>
      <mat-card-header><mat-card-title>Películas</mat-card-title></mat-card-header>
      <mat-card-content>
        <table mat-table [dataSource]="peliculas" class="full">
          <ng-container matColumnDef="titulo"><th mat-header-cell *matHeaderCellDef>Título</th><td mat-cell *matCellDef="let p">{{ p['TITULO'] || p['titulo'] }}</td></ng-container>
          <ng-container matColumnDef="clasificacion"><th mat-header-cell *matHeaderCellDef>Clasif.</th><td mat-cell *matCellDef="let p">{{ p['CLASIFICACION'] || p['clasificacion'] }}</td></ng-container>
          <ng-container matColumnDef="activa"><th mat-header-cell *matHeaderCellDef>Activa</th><td mat-cell *matCellDef="let p">{{ p['ACTIVA'] ?? p['activa'] }}</td></ng-container>
          <tr mat-header-row *matHeaderRowDef="cols"></tr>
          <tr mat-row *matRowDef="let row; columns: cols"></tr>
        </table>
      </mat-card-content>
    </mat-card>
  `,
  styles: `.full { width: 100%; }`
})
export class PeliculasAdminComponent implements OnInit {
  private readonly admin = inject(AdminService);
  private readonly notification = inject(NotificationService);
  peliculas: Record<string, unknown>[] = [];
  cols = ['titulo', 'clasificacion', 'activa'];

  ngOnInit(): void {
    this.admin.listarPeliculas().subscribe({
      next: (d) => this.peliculas = d,
      error: (e) => this.notification.error(e)
    });
  }
}
