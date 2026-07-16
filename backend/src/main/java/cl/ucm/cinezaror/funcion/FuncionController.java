package cl.ucm.cinezaror.funcion;

import cl.ucm.cinezaror.common.dto.ApiResponse;
import cl.ucm.cinezaror.funcion.dto.AsientosFuncionResponse;
import cl.ucm.cinezaror.funcion.dto.FuncionDetalleDto;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/funciones")
public class FuncionController {

    private final FuncionService funcionService;

    public FuncionController(FuncionService funcionService) {
        this.funcionService = funcionService;
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<FuncionDetalleDto>> detalle(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(funcionService.obtenerDetalle(id)));
    }

    @GetMapping("/{id}/asientos")
    public ResponseEntity<AsientosFuncionResponse> asientos(@PathVariable Long id) {
        return ResponseEntity.ok(funcionService.obtenerAsientos(id));
    }
}
