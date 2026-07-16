package cl.ucm.cinezaror.admin;

import cl.ucm.cinezaror.admin.dto.EstadoRequest;
import cl.ucm.cinezaror.admin.dto.FuncionRequest;
import cl.ucm.cinezaror.admin.dto.PeliculaRequest;
import cl.ucm.cinezaror.admin.dto.SalaRequest;
import cl.ucm.cinezaror.common.dto.ApiResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PatchMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/admin")
@PreAuthorize("hasRole('ADMIN')")
public class AdminController {

    private final AdminService adminService;

    public AdminController(AdminService adminService) {
        this.adminService = adminService;
    }

    @GetMapping("/peliculas")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> listarPeliculas() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.listarPeliculas()));
    }

    @PostMapping("/peliculas")
    public ResponseEntity<ApiResponse<Long>> crearPelicula(@Valid @RequestBody PeliculaRequest request) {
        Long id = adminService.crearPelicula(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok("Película creada", id));
    }

    @PutMapping("/peliculas/{id}")
    public ResponseEntity<ApiResponse<Void>> actualizarPelicula(
            @PathVariable Long id, @Valid @RequestBody PeliculaRequest request) {
        adminService.actualizarPelicula(id, request);
        return ResponseEntity.ok(ApiResponse.ok("Película actualizada", null));
    }

    @PatchMapping("/peliculas/{id}/estado")
    public ResponseEntity<ApiResponse<Void>> estadoPelicula(
            @PathVariable Long id, @Valid @RequestBody EstadoRequest request) {
        adminService.cambiarEstadoPelicula(id, request);
        return ResponseEntity.ok(ApiResponse.ok("Estado actualizado", null));
    }

    @GetMapping("/salas")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> listarSalas() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.listarSalas()));
    }

    @PostMapping("/salas")
    public ResponseEntity<ApiResponse<Long>> crearSala(@Valid @RequestBody SalaRequest request) {
        Long id = adminService.crearSala(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok("Sala creada", id));
    }

    @PutMapping("/salas/{id}")
    public ResponseEntity<ApiResponse<Void>> actualizarSala(
            @PathVariable Long id, @Valid @RequestBody SalaRequest request) {
        adminService.actualizarSala(id, request);
        return ResponseEntity.ok(ApiResponse.ok("Sala actualizada", null));
    }

    @PostMapping("/salas/{id}/generar-asientos")
    public ResponseEntity<ApiResponse<Void>> generarAsientos(@PathVariable Long id) {
        adminService.generarAsientos(id);
        return ResponseEntity.ok(ApiResponse.ok("Asientos generados", null));
    }

    @PatchMapping("/salas/{id}/estado")
    public ResponseEntity<ApiResponse<Void>> estadoSala(
            @PathVariable Long id, @Valid @RequestBody EstadoRequest request) {
        adminService.cambiarEstadoSala(id, request);
        return ResponseEntity.ok(ApiResponse.ok("Estado actualizado", null));
    }

    @GetMapping("/funciones")
    public ResponseEntity<ApiResponse<List<Map<String, Object>>>> listarFunciones() {
        return ResponseEntity.ok(ApiResponse.ok(adminService.listarFunciones()));
    }

    @PostMapping("/funciones")
    public ResponseEntity<ApiResponse<Long>> crearFuncion(@Valid @RequestBody FuncionRequest request) {
        Long id = adminService.crearFuncion(request);
        return ResponseEntity.status(HttpStatus.CREATED).body(ApiResponse.ok("Función creada", id));
    }

    @PutMapping("/funciones/{id}")
    public ResponseEntity<ApiResponse<Void>> actualizarFuncion(
            @PathVariable Long id, @Valid @RequestBody FuncionRequest request) {
        adminService.actualizarFuncion(id, request);
        return ResponseEntity.ok(ApiResponse.ok("Función actualizada", null));
    }

    @PatchMapping("/funciones/{id}/estado")
    public ResponseEntity<ApiResponse<Void>> desactivarFuncion(@PathVariable Long id) {
        adminService.desactivarFuncion(id);
        return ResponseEntity.ok(ApiResponse.ok("Función desactivada", null));
    }
}
