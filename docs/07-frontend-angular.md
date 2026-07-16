# Frontend Angular

## 1. Tecnologías

- Angular.
- Angular Material.
- Reactive Forms.
- HttpClient.
- Router.
- Route Guards.
- Interceptors.

## 2. Estructura sugerida

```text
src/app/
├── core/
│   ├── auth/
│   ├── guards/
│   ├── interceptors/
│   └── services/
├── shared/
│   ├── components/
│   ├── models/
│   └── utils/
├── features/
│   ├── auth/
│   ├── cartelera/
│   ├── asientos/
│   ├── reservas/
│   └── admin/
└── layout/
```

## 3. Rutas

```text
/login
/registro
/cartelera
/funciones/:id/asientos
/checkout/:reservaId
/mis-reservas

/admin
/admin/peliculas
/admin/salas
/admin/funciones
```

## 4. Componentes principales

### Auth

- LoginComponent
- RegistroComponent

### Cliente

- CarteleraComponent
- PeliculaCardComponent
- FuncionSelectorComponent
- AsientosComponent
- ResumenCompraComponent
- PagoComponent
- MisReservasComponent
- ReservaDetalleComponent

### Administración

- AdminLayoutComponent
- PeliculasListComponent
- PeliculaFormComponent
- SalasListComponent
- SalaFormComponent
- FuncionesListComponent
- FuncionFormComponent

## 5. Angular Material

Componentes recomendados:

- MatToolbar
- MatSidenav
- MatCard
- MatTable
- MatFormField
- MatInput
- MatSelect
- MatDatepicker
- MatDialog
- MatSnackBar
- MatButton
- MatIcon
- MatProgressSpinner
- MatStepper

## 6. Mapa de asientos

Representación sugerida:

```text
[PANTALLA]

A1 A2 A3 A4 A5
B1 B2 B3 B4 B5
C1 C2 C3 C4 C5
```

Estados:

- Disponible: botón normal.
- Seleccionado: botón resaltado.
- Ocupado: deshabilitado.
- Inactivo: oculto o deshabilitado.

## 7. Servicios

- AuthService
- CarteleraService
- FuncionService
- ReservaService
- AdminPeliculaService
- AdminSalaService
- AdminFuncionService

## 8. Interceptor JWT

Debe:

1. Leer token desde almacenamiento.
2. Agregar header Authorization.
3. Detectar 401.
4. Cerrar sesión cuando el token expire.

## 9. Guards

### AuthGuard

Requiere usuario autenticado.

### AdminGuard

Requiere rol ADMIN.

## 10. Principios de implementación

- Mantener componentes pequeños.
- No duplicar modelos.
- Evitar estado global complejo.
- No implementar reglas críticas solo en Angular.
- Mostrar errores del backend.
- Priorizar funcionalidad sobre diseño.
