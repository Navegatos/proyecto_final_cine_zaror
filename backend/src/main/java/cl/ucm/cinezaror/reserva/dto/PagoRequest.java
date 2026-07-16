package cl.ucm.cinezaror.reserva.dto;

import jakarta.validation.constraints.NotBlank;

public record PagoRequest(
        @NotBlank String metodo
) {
}
