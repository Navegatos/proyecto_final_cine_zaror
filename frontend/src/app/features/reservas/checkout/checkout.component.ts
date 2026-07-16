import { DecimalPipe } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { ActivatedRoute, Router } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatSelectModule } from '@angular/material/select';

import { ReservaService } from '../../../core/services/reserva.service';
import { ReservaDetalle } from '../../../shared/models/domain.model';
import { NotificationService } from '../../../shared/services/notification.service';

@Component({
  selector: 'app-checkout',
  standalone: true,
  imports: [MatCardModule, MatButtonModule, MatFormFieldModule, MatSelectModule, DecimalPipe],
  templateUrl: './checkout.component.html'
})
export class CheckoutComponent implements OnInit {
  private readonly route = inject(ActivatedRoute);
  private readonly router = inject(Router);
  private readonly reservaService = inject(ReservaService);
  private readonly notification = inject(NotificationService);

  reserva?: ReservaDetalle;
  metodo = 'DEBITO';

  ngOnInit(): void {
    const id = Number(this.route.snapshot.paramMap.get('reservaId'));
    this.reservaService.obtener(id).subscribe({
      next: (r) => this.reserva = r,
      error: (e) => this.notification.error(e)
    });
  }

  pagar(): void {
    if (!this.reserva) return;
    this.reservaService.pagar(this.reserva.reservaId, this.metodo).subscribe({
      next: () => {
        this.notification.success('Pago confirmado');
        this.router.navigate(['/mis-reservas']);
      },
      error: (e) => this.notification.error(e)
    });
  }
}
