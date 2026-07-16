package cl.ucm.cinezaror.auth.dto;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public record RegisterRequest(
        @NotBlank String rut,
        @NotBlank String nombreCompleto,
        @NotBlank @Email String correo,
        @NotBlank @Size(min = 6) String password
) {
}
