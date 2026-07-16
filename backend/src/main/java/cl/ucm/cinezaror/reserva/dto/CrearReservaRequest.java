package cl.ucm.cinezaror.reserva.dto;

import jakarta.validation.constraints.NotEmpty;
import jakarta.validation.constraints.NotNull;

import java.util.List;

public record CrearReservaRequest(
        @NotNull Long funcionId,
        @NotEmpty List<Long> asientoIds
) {
}
