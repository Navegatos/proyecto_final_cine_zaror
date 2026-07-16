package cl.ucm.cinezaror.cartelera;

import cl.ucm.cinezaror.cartelera.dto.CarteleraItemDto;
import cl.ucm.cinezaror.common.dto.ApiResponse;
import org.springframework.format.annotation.DateTimeFormat;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;

import java.time.LocalDate;
import java.util.List;

@RestController
@RequestMapping("/api/cartelera")
public class CarteleraController {

    private final CarteleraService carteleraService;

    public CarteleraController(CarteleraService carteleraService) {
        this.carteleraService = carteleraService;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<List<CarteleraItemDto>>> cartelera(
            @RequestParam @DateTimeFormat(iso = DateTimeFormat.ISO.DATE) LocalDate fecha) {
        List<CarteleraItemDto> data = carteleraService.obtenerCartelera(fecha);
        return ResponseEntity.ok(ApiResponse.ok(data));
    }
}
