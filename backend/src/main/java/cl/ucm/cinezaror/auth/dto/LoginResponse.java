package cl.ucm.cinezaror.auth.dto;

public record LoginResponse(
        String token,
        String nombre,
        String rol
) {
}
