import { Routes } from '@angular/router';

import { adminGuard } from './core/guards/admin.guard';
import { authGuard } from './core/guards/auth.guard';
import { AdminLayoutComponent } from './layout/admin-layout/admin-layout.component';
import { PublicLayoutComponent } from './layout/public-layout/public-layout.component';

export const routes: Routes = [
  {
    path: '',
    component: PublicLayoutComponent,
    children: [
      { path: '', redirectTo: 'cartelera', pathMatch: 'full' },
      {
        path: 'login',
        loadComponent: () =>
          import('./features/auth/login/login.component').then((m) => m.LoginComponent)
      },
      {
        path: 'registro',
        loadComponent: () =>
          import('./features/auth/registro/registro.component').then((m) => m.RegistroComponent)
      },
      {
        path: 'cartelera',
        loadComponent: () =>
          import('./features/cartelera/cartelera.component').then((m) => m.CarteleraComponent)
      },
      {
        path: 'funciones/:id/asientos',
        canActivate: [authGuard],
        loadComponent: () =>
          import('./features/asientos/asientos.component').then((m) => m.AsientosComponent)
      },
      {
        path: 'checkout/:reservaId',
        canActivate: [authGuard],
        loadComponent: () =>
          import('./features/reservas/checkout/checkout.component').then((m) => m.CheckoutComponent)
      },
      {
        path: 'mis-reservas',
        canActivate: [authGuard],
        loadComponent: () =>
          import('./features/reservas/mis-reservas/mis-reservas.component').then(
            (m) => m.MisReservasComponent
          )
      }
    ]
  },
  {
    path: 'admin',
    component: AdminLayoutComponent,
    canActivate: [authGuard, adminGuard],
    children: [
      { path: '', redirectTo: 'peliculas', pathMatch: 'full' },
      {
        path: 'peliculas',
        loadComponent: () =>
          import('./features/admin/peliculas/peliculas-admin.component').then(
            (m) => m.PeliculasAdminComponent
          )
      },
      {
        path: 'salas',
        loadComponent: () =>
          import('./features/admin/salas/salas-admin.component').then((m) => m.SalasAdminComponent)
      },
      {
        path: 'funciones',
        loadComponent: () =>
          import('./features/admin/funciones/funciones-admin.component').then(
            (m) => m.FuncionesAdminComponent
          )
      }
    ]
  },
  { path: '**', redirectTo: 'cartelera' }
];
