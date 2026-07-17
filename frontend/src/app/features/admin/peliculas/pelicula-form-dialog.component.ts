import { Component, inject } from '@angular/core';
import { FormBuilder, ReactiveFormsModule, Validators } from '@angular/forms';
import { MAT_DIALOG_DATA, MatDialogModule, MatDialogRef } from '@angular/material/dialog';
import { MatButtonModule } from '@angular/material/button';
import { MatFormFieldModule } from '@angular/material/form-field';
import { MatInputModule } from '@angular/material/input';

import { PeliculaForm } from '../../../core/services/admin.service';
import { rowStr, rowNum } from '../admin-row.util';

export interface PeliculaFormDialogData {
  pelicula?: Record<string, unknown>;
}

@Component({
  selector: 'app-pelicula-form-dialog',
  standalone: true,
  imports: [ReactiveFormsModule, MatDialogModule, MatFormFieldModule, MatInputModule, MatButtonModule],
  template: `
    <h2 mat-dialog-title>{{ data.pelicula ? 'Editar película' : 'Nueva película' }}</h2>
    <mat-dialog-content>
      <form [formGroup]="form" class="form">
        <mat-form-field appearance="outline">
          <mat-label>Título</mat-label>
          <input matInput formControlName="titulo" />
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Sinopsis</mat-label>
          <textarea matInput rows="3" formControlName="sinopsis"></textarea>
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Duración (min)</mat-label>
          <input matInput type="number" formControlName="duracionMinutos" />
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Clasificación</mat-label>
          <input matInput formControlName="clasificacion" placeholder="TE, 14, R..." />
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>Género</mat-label>
          <input matInput formControlName="genero" />
        </mat-form-field>
        <mat-form-field appearance="outline">
          <mat-label>URL imagen</mat-label>
          <input matInput formControlName="urlImagen" />
        </mat-form-field>
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
  `
})
export class PeliculaFormDialogComponent {
  readonly data = inject<PeliculaFormDialogData>(MAT_DIALOG_DATA);
  private readonly fb = inject(FormBuilder);
  private readonly dialogRef = inject(MatDialogRef<PeliculaFormDialogComponent, PeliculaForm>);

  form = this.fb.group({
    titulo: ['', Validators.required],
    sinopsis: [''],
    duracionMinutos: [90, [Validators.required, Validators.min(1)]],
    clasificacion: ['', Validators.required],
    genero: [''],
    urlImagen: ['']
  });

  constructor() {
    const p = this.data.pelicula;
    if (p) {
      this.form.patchValue({
        titulo: rowStr(p, 'titulo'),
        sinopsis: rowStr(p, 'sinopsis'),
        duracionMinutos: rowNum(p, 'duracionMinutos') || rowNum(p, 'duracion_minutos'),
        clasificacion: rowStr(p, 'clasificacion'),
        genero: rowStr(p, 'genero'),
        urlImagen: rowStr(p, 'urlImagen') || rowStr(p, 'url_imagen')
      });
    }
  }

  guardar(): void {
    if (this.form.invalid) return;
    this.dialogRef.close(this.form.getRawValue() as PeliculaForm);
  }
}
