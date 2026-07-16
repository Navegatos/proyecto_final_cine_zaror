import { DecimalPipe } from '@angular/common';
import { Component, OnInit, inject } from '@angular/core';
import { FormControl, ReactiveFormsModule } from '@angular/forms';
import { Router, RouterLink } from '@angular/router';
import { MatButtonModule } from '@angular/material/button';
import { MatCardModule } from '@angular/material/card';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatNativeDateModule } from '@angular/material/core';
import { MatProgressSpinnerModule } from '@angular/material/progress-spinner';

import { CarteleraService } from '../../core/services/cartelera.service';
import { CarteleraItem } from '../../shared/models/domain.model';
import { NotificationService } from '../../shared/services/notification.service';

@Component({
  selector: 'app-cartelera',
  standalone: true,
  imports: [
    ReactiveFormsModule, MatCardModule, MatFormFieldModule, MatInputModule,
    MatDatepickerModule, MatNativeDateModule, MatButtonModule, MatProgressSpinnerModule, RouterLink, DecimalPipe
  ],
  templateUrl: './cartelera.component.html'
})
export class CarteleraComponent implements OnInit {
  private readonly carteleraService = inject(CarteleraService);
  private readonly notification = inject(NotificationService);
  private readonly router = inject(Router);

  fechaCtrl = new FormControl(this.manana());
  items: CarteleraItem[] = [];
  loading = false;

  private manana(): Date {
    const d = new Date();
    d.setDate(d.getDate() + 1);
    return d;
  }

  ngOnInit(): void { this.cargar(); }

  cargar(): void {
    const fecha = this.fechaCtrl.value;
    if (!fecha) return;
    const iso = fecha.toISOString().slice(0, 10);
    this.loading = true;
    this.carteleraService.obtenerPorFecha(iso).subscribe({
      next: (data) => { this.items = data; this.loading = false; },
      error: (err) => { this.loading = false; this.notification.error(err); }
    });
  }

  irAsientos(funcionId: number): void {
    this.router.navigate(['/funciones', funcionId, 'asientos']);
  }
}
