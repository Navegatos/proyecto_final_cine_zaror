package cl.ucm.cinezaror.funcion.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record FuncionDetalleDto(
        Long funcionId,
        Long peliculaId,
        String titulo,
        String sinopsis,
        Integer duracionMinutos,
        String clasificacion,
        Long salaId,
        String sala,
        LocalDateTime fechaHora,
        BigDecimal precio,
        Integer asientosDisponibles
) {
}
