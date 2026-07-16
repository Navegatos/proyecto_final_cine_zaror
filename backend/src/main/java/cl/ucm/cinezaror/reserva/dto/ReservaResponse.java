package cl.ucm.cinezaror.reserva.dto;

import java.math.BigDecimal;

public record ReservaResponse(
        Long reservaId,
        String codigo,
        Integer cantidad,
        BigDecimal total,
        String estado
) {
}
