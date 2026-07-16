package cl.ucm.cinezaror.usuario;

public record UsuarioRecord(
        Long id,
        String nombreCompleto,
        String correo,
        String rol,
        String passwordHash,
        int activo
) {
}
