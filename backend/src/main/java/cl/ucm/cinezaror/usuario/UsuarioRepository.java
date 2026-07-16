package cl.ucm.cinezaror.usuario;

import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import java.util.Map;
import java.util.Optional;

@Repository
public class UsuarioRepository {

    private final JdbcTemplate jdbcTemplate;
    private final SimpleJdbcCall registrarUsuarioCall;

    public UsuarioRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        this.registrarUsuarioCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("SP_REGISTRAR_USUARIO");
    }

    public Optional<UsuarioRecord> findByCorreo(String correo) {
        try {
            return Optional.of(jdbcTemplate.queryForObject("""
                    SELECT U.ID_USUARIO, U.NOMBRE_COMPLETO, U.CORREO, R.NOMBRE AS ROL,
                           U.PASSWORD_HASH, U.ACTIVO
                    FROM USUARIO U
                    JOIN ROL R ON R.ID_ROL = U.ID_ROL
                    WHERE U.CORREO = ?
                    """, (rs, rowNum) -> new UsuarioRecord(
                    rs.getLong("ID_USUARIO"),
                    rs.getString("NOMBRE_COMPLETO"),
                    rs.getString("CORREO"),
                    rs.getString("ROL"),
                    rs.getString("PASSWORD_HASH"),
                    rs.getInt("ACTIVO")
            ), correo.toLowerCase().trim()));
        } catch (EmptyResultDataAccessException ex) {
            return Optional.empty();
        }
    }

    public Long registrarUsuario(String rut, String nombreCompleto, String correo, String passwordHash) {
        Map<String, Object> result = registrarUsuarioCall.execute(
                Map.of(
                        "P_RUT", rut,
                        "P_NOMBRE_COMPLETO", nombreCompleto,
                        "P_CORREO", correo,
                        "P_PASSWORD_HASH", passwordHash
                )
        );
        return ((Number) result.get("P_ID_USUARIO")).longValue();
    }
}
