package cl.ucm.cinezaror.admin.dto;

import jakarta.validation.constraints.NotNull;

public record EstadoRequest(
        @NotNull Boolean activo
) {
}
