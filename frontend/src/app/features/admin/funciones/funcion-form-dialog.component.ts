import { Component, OnInit, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';
import { MatSelectModule } from '@angular/material/select';
import { MatDatepickerModule } from '@angular/material/datepicker';
import { MatNativeDateModule } from '@angular/material/core';

import { AdminService, FuncionForm } from '../../../core/services/admin.service';
import { isActivo, rowNum, rowStr, rowVal } from '../admin-row.util';

export interface FuncionFormDialogData {
  funcion?: Record<string, unknown>;
  peliculas: Record<string, unknown>[];
  salas: Record<string, unknown>[];
}

@Component({
  selector: 'app-funcion-form-dialog',
  standalone: true,
  imports: [
    ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule,
    MatSelectModule, MatDatepickerModule, MatNativeDateModule, MatButtonModule
  ],
  template: `
    <h2 mat-dialog-title>{{ data.funcion ? 'Editar función' : 'Nueva función' }}</h2>
    <mat-dialog-content>
      <form [formGroup]="form" class="form">
        <mat-form-field appearance="outline">
          <mat-label>Película</mat-label>
          <mat-select formControlName="peliculaId">
            @for (p of peliculasActivas; track trackPelicula(p)) {
              <mat-option [value]="trackPelicula(p)">{{ rowStr(p, 'titulo') }}</mat-option>
            }
          </mat-select>
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Sala</mat-label>
          <mat-select formControlName="salaId">
            @for (s of salasActivas; track trackSala(s)) {
              <mat-option [value]="trackSala(s)">{{ rowStr(s, 'nombre') }}</mat-option>
            }
          </mat-select>
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Fecha</mat-label>
          <input matInput [matDatepicker]="picker" formControlName="fecha" />
          <mat-datepicker-toggle matIconSuffix [for]="picker"></mat-datepicker-toggle>
          <mat-datepicker #picker></mat-datepicker>
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Hora (HH:mm)</mat-label>
          <input matInput formControlName="hora" placeholder="19:30" />
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Precio</mat-label>
          <input matInput type="number" formControlName="precio" />
        </mat-form-field>
      </form>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close>Cancelar</button>
      <button mat-flat-button color="primary" [disabled]="form.invalid" (click)="guardar()">Guardar</button>
    </mat-dialog-actions>
  `,
  styles: `
    .form { display: flex; flex-direction: column; min-width: 340px; padding-top: 8px; }
    mat-form-field { width: 100%; }
  `
})
export class FuncionFormDialogComponent implements OnInit {
  readonly data = inject<FuncionFormDialogData>(MAT_DIALOG_DATA);
  private readonly fb = inject(FormBuilder);
  private readonly dialogRef = inject(MatDialogRef<FuncionFormDialogComponent, FuncionForm>);

  readonly rowStr = rowStr;
  peliculasActivas: Record<string, unknown>[] = [];
  salasActivas: Record<string, unknown>[] = [];

  form = this.fb.group({
    peliculaId: [null as number | null, Validators.required],
    salaId: [null as number | null, Validators.required],
    fecha: [null as Date | null, Validators.required],
    hora: ['19:00', [Validators.required, Validators.pattern(/^\d{2}:\d{2}$/)]],
    precio: [5000, [Validators.required, Validators.min(1)]]
  });

  ngOnInit(): void {
    this.peliculasActivas = this.data.peliculas.filter((p) => isActivo(p));
    this.salasActivas = this.data.salas.filter((s) => isActivo(s));

    const f = this.data.funcion;
    if (f) {
      const raw = rowVal(f, 'fechaHora') ?? rowVal(f, 'fecha_hora');
      const dt = raw ? new Date(String(raw)) : new Date();
      const hora = `${String(dt.getHours()).padStart(2, '0')}:${String(dt.getMinutes()).padStart(2, '0')}`;

      const peliculaId = rowNum(f, 'idPelicula') || rowNum(f, 'peliculaId');
      const salaId = rowNum(f, 'idSala') || rowNum(f, 'salaId');

      if (!this.peliculasActivas.some((p) => this.trackPelicula(p) === peliculaId)) {
        const actual = this.data.peliculas.find((p) => this.trackPelicula(p) === peliculaId);
        if (actual) this.peliculasActivas = [actual, ...this.peliculasActivas];
      }
      if (!this.salasActivas.some((s) => this.trackSala(s) === salaId)) {
        const actual = this.data.salas.find((s) => this.trackSala(s) === salaId);
        if (actual) this.salasActivas = [actual, ...this.salasActivas];
      }

      this.form.patchValue({
        peliculaId,
        salaId,
        fecha: dt,
        hora,
        precio: rowNum(f, 'precio')
      });
    }
  }

  trackPelicula(p: Record<string, unknown>): number {
    return rowNum(p, 'idPelicula');
  }

  trackSala(s: Record<string, unknown>): number {
    return rowNum(s, 'idSala');
  }

  guardar(): void {
    if (this.form.invalid) return;
    const v = this.form.getRawValue();
    const [hh, mm] = v.hora!.split(':').map(Number);
    const fecha = new Date(v.fecha!);
    fecha.setHours(hh, mm, 0, 0);

    const pad = (n: number) => String(n).padStart(2, '0');
    const fechaHora = `${fecha.getFullYear()}-${pad(fecha.getMonth() + 1)}-${pad(fecha.getDate())}T${pad(hh)}:${pad(mm)}:00`;

    this.dialogRef.close({
      peliculaId: v.peliculaId!,
      salaId: v.salaId!,
      fechaHora,
      precio: v.precio!
    });
  }
}
