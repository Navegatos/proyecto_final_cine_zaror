package cl.ucm.cinezaror.reserva.dto;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record ReservaDetalleDto(
        Long reservaId,
        String codigo,
        String pelicula,
        LocalDateTime fechaHora,
        String sala,
        String asientos,
        BigDecimal total,
        String estado
) {
}
