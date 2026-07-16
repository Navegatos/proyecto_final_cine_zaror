import { DatePipe, DecimalPipe } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { MatCardModule } from '@angular/material/card';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

import { ReservaService } from '../../../core/services/reserva.service';
import { ReservaDetalle } from '../../../shared/models/domain.model';
import { NotificationService } from '../../../shared/services/notification.service';

@Component({
  selector: 'app-mis-reservas',
  standalone: true,
  imports: [MatCardModule, MatProgressSpinnerModule, DatePipe, DecimalPipe],
  templateUrl: './mis-reservas.component.html'
})
export class MisReservasComponent implements OnInit {
  private readonly reservaService = inject(ReservaService);
  private readonly notification = inject(NotificationService);

  reservas: ReservaDetalle[] = [];
  loading = false;

  ngOnInit(): void {
    this.loading = true;
    this.reservaService.misReservas().subscribe({
      next: (r) => { this.reservas = r; this.loading = false; },
      error: (e) => { this.loading = false; this.notification.error(e); }
    });
  }
}
