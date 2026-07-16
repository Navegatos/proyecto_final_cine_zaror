package cl.ucm.cinezaror.admin.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record SalaRequest(
        @NotBlank String nombre,
        @NotNull @Positive Integer filas,
        @NotNull @Positive Integer columnas
) {
}
