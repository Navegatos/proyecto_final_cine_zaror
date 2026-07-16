package cl.ucm.cinezaror.admin.dto;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

public record PeliculaRequest(
        @NotBlank String titulo,
        String sinopsis,
        @NotNull @Positive Integer duracionMinutos,
        @NotBlank String clasificacion,
        String genero,
        String urlImagen
) {
}
