import { Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';

import { SalaForm } from '../../../core/services/admin.service';
import { rowNum, rowStr } from '../admin-row.util';

export interface SalaFormDialogData {
  sala?: Record<string, unknown>;
}

@Component({
  selector: 'app-sala-form-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule, MatButtonModule],
  template: `
    <h2 mat-dialog-title>{{ data.sala ? 'Editar sala' : 'Nueva sala' }}</h2>
    <mat-dialog-content>
      <form [formGroup]="form" class="form">
        <mat-form-field appearance="outline">
          <mat-label>Nombre</mat-label>
          <input matInput formControlName="nombre" />
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Filas</mat-label>
          <input matInput type="number" formControlName="filas" />
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Columnas</mat-label>
          <input matInput type="number" formControlName="columnas" />
        </mat-form-field>
        @if (bloquearDimensiones) {
          <p class="hint">Filas y columnas no se pueden modificar porque la sala ya tiene asientos.</p>
        }
      </form>
    </mat-dialog-content>
    <mat-dialog-actions align="end">
      <button mat-button mat-dialog-close>Cancelar</button>
      <button mat-flat-button color="primary" [disabled]="form.invalid" (click)="guardar()">Guardar</button>
    </mat-dialog-actions>
  `,
  styles: `
    .form { display: flex; flex-direction: column; min-width: 320px; padding-top: 8px; }
    mat-form-field { width: 100%; }
    .hint { font-size: 0.85rem; color: #666; margin: 0; }
  `
})
export class SalaFormDialogComponent {
  readonly data = inject<SalaFormDialogData>(MAT_DIALOG_DATA);
  private readonly fb = inject(FormBuilder);
  private readonly dialogRef = inject(MatDialogRef<SalaFormDialogComponent, SalaForm>);

  bloquearDimensiones = false;

  form = this.fb.group({
    nombre: ['', Validators.required],
    filas: [5, [Validators.required, Validators.min(1)]],
    columnas: [10, [Validators.required, Validators.min(1)]]
  });

  constructor() {
    const s = this.data.sala;
    if (s) {
      const asientos = rowNum(s, 'cantidadAsientos') || rowNum(s, 'cantidad_asientos');
      this.bloquearDimensiones = asientos > 0;
      this.form.patchValue({
        nombre: rowStr(s, 'nombre'),
        filas: rowNum(s, 'filas'),
        columnas: rowNum(s, 'columnas')
      });
      if (this.bloquearDimensiones) {
        this.form.controls.filas.disable();
        this.form.controls.columnas.disable();
      }
    }
  }

  guardar(): void {
    if (this.form.invalid) return;
    this.dialogRef.close(this.form.getRawValue() as SalaForm);
  }
}
