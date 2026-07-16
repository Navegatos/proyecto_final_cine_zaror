import { DecimalPipe } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

import { FuncionService } from '../../core/services/funcion.service';
import { ReservaService } from '../../core/services/reserva.service';
import { Asiento, AsientosResponse } from '../../shared/models/domain.model';
import { NotificationService } from '../../shared/services/notification.service';

@Component({
  selector: 'app-asientos',
  standalone: true,
  imports: [MatCardModule, MatButtonModule, MatProgressSpinnerModule, DecimalPipe],
  templateUrl: './asientos.component.html',
  styleUrl: './asientos.component.scss'
})
export class AsientosComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly funcionService = inject(FuncionService);
  private readonly reservaService = inject(ReservaService);
  private readonly notification = inject(NotificationService);

  funcionId = 0;
  data?: AsientosResponse;
  seleccionados = new Set<number>();
  loading = false;
  reservando = false;

  ngOnInit(): void {
    this.funcionId = Number(this.route.snapshot.paramMap.get('id'));
    this.cargar();
  }

  cargar(): void {
    this.loading = true;
    this.funcionService.obtenerAsientos(this.funcionId).subscribe({
      next: (d) => { this.data = d; this.loading = false; },
      error: (e) => { this.loading = false; this.notification.error(e); }
    });
  }

  toggle(asiento: Asiento): void {
    if (asiento.estado !== 'DISPONIBLE') return;
    if (this.seleccionados.has(asiento.id)) this.seleccionados.delete(asiento.id);
    else this.seleccionados.add(asiento.id);
  }

  estadoVisual(a: Asiento): string {
    if (this.seleccionados.has(a.id)) return 'SELECCIONADO';
    return a.estado;
  }

  confirmar(): void {
    if (this.seleccionados.size === 0) return;
    this.reservando = true;
    this.reservaService.crear(this.funcionId, [...this.seleccionados]).subscribe({
      next: (r) => {
        this.notification.success(`Reserva ${r.codigo} creada`);
        this.router.navigate(['/checkout', r.reservaId]);
      },
      error: (e) => { this.reservando = false; this.notification.error(e); },
      complete: () => { this.reservando = false; }
    });
  }

  cssClass(a: Asiento): string {
    return this.estadoVisual(a).toLowerCase();
  }

  filas(): string[] {
    if (!this.data) return [];
    return [...new Set(this.data.asientos.map((a) => a.fila))].sort();
  }

  asientosFila(fila: string): Asiento[] {
    return this.data?.asientos.filter((a) => a.fila === fila) ?? [];
  }
}
