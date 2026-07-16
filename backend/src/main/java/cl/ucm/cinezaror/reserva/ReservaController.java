package cl.ucm.cinezaror.reserva;

import cl.ucm.cinezaror.common.dto.ApiResponse;
import cl.ucm.cinezaror.reserva.dto.CrearReservaRequest;
import cl.ucm.cinezaror.reserva.dto.PagoRequest;
import cl.ucm.cinezaror.reserva.dto.ReservaDetalleDto;
import cl.ucm.cinezaror.reserva.dto.ReservaResponse;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/reservas")
public class ReservaController {

    private final ReservaService reservaService;

    public ReservaController(ReservaService reservaService) {
        this.reservaService = reservaService;
    }

    @PostMapping
    public ResponseEntity<ApiResponse<ReservaResponse>> crear(@Valid @RequestBody CrearReservaRequest request) {
        ReservaResponse data = reservaService.crearReserva(request);
        return ResponseEntity.status(HttpStatus.CREATED)
                .body(ApiResponse.ok("Reserva creada", data));
    }

    @PostMapping("/{id}/pago")
    public ResponseEntity<ApiResponse<Map<String, Object>>> pagar(
            @PathVariable Long id,
            @Valid @RequestBody PagoRequest request) {
        Map<String, Object> data = reservaService.confirmarPago(id, request);
        return ResponseEntity.ok(ApiResponse.ok("Pago confirmado", data));
    }

    @GetMapping("/mis-reservas")
    public ResponseEntity<ApiResponse<List<ReservaDetalleDto>>> misReservas() {
        return ResponseEntity.ok(ApiResponse.ok(reservaService.misReservas()));
    }

    @GetMapping("/{id}")
    public ResponseEntity<ApiResponse<ReservaDetalleDto>> detalle(@PathVariable Long id) {
        return ResponseEntity.ok(ApiResponse.ok(reservaService.obtenerReserva(id)));
    }
}
