package cl.ucm.cinezaror.reserva;

import cl.ucm.cinezaror.database.OracleArrayHelper;
import cl.ucm.cinezaror.reserva.dto.ReservaDetalleDto;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.namedparam.MapSqlParameterSource;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Map;
import java.util.Optional;

@Repository
public class ReservaRepository {

    private final JdbcTemplate jdbcTemplate;
    private final SimpleJdbcCall crearReservaCall;
    private final SimpleJdbcCall confirmarPagoCall;

    public ReservaRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        this.crearReservaCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("SP_CREAR_RESERVA");
        this.confirmarPagoCall = new SimpleJdbcCall(jdbcTemplate)
                .withProcedureName("SP_CONFIRMAR_PAGO");
    }

    public Map<String, Object> crearReserva(Long idUsuario, Long idFuncion, List<Long> asientoIds) {
        MapSqlParameterSource params = new MapSqlParameterSource()
                .addValue("P_ID_USUARIO", idUsuario)
                .addValue("P_ID_FUNCION", idFuncion)
                .addValue("P_ASIENTOS", OracleArrayHelper.numberListType("T_LISTA_ID", asientoIds));
        return crearReservaCall.execute(params);
    }

    public Map<String, Object> confirmarPago(Long idReserva, String metodo) {
        return confirmarPagoCall.execute(Map.of(
                "P_ID_RESERVA", idReserva,
                "P_METODO", metodo
        ));
    }

    public List<ReservaDetalleDto> findByUsuarioCorreo(String correo) {
        return jdbcTemplate.query("""
                SELECT V.ID_RESERVA, V.CODIGO, V.PELICULA, V.FECHA_HORA, V.SALA, V.ASIENTOS, V.TOTAL, V.ESTADO
                FROM VW_RESERVAS_USUARIO V
                JOIN USUARIO U ON U.ID_USUARIO = V.ID_USUARIO
                WHERE U.CORREO = ?
                ORDER BY V.FECHA_CREACION DESC
                """, (rs, rowNum) -> new ReservaDetalleDto(
                rs.getLong("ID_RESERVA"),
                rs.getString("CODIGO"),
                rs.getString("PELICULA"),
                rs.getTimestamp("FECHA_HORA").toLocalDateTime(),
                rs.getString("SALA"),
                rs.getString("ASIENTOS"),
                rs.getBigDecimal("TOTAL"),
                rs.getString("ESTADO")
        ), correo);
    }

    public Optional<ReservaDetalleDto> findById(Long id) {
        List<ReservaDetalleDto> result = jdbcTemplate.query("""
                SELECT ID_RESERVA, CODIGO, PELICULA, FECHA_HORA, SALA, ASIENTOS, TOTAL, ESTADO
                FROM VW_RESERVAS_USUARIO
                WHERE ID_RESERVA = ?
                """, (rs, rowNum) -> new ReservaDetalleDto(
                rs.getLong("ID_RESERVA"),
                rs.getString("CODIGO"),
                rs.getString("PELICULA"),
                rs.getTimestamp("FECHA_HORA").toLocalDateTime(),
                rs.getString("SALA"),
                rs.getString("ASIENTOS"),
                rs.getBigDecimal("TOTAL"),
                rs.getString("ESTADO")
        ), id);
        return result.stream().findFirst();
    }

    public Optional<Long> findUsuarioIdByCorreo(String correo) {
        List<Long> ids = jdbcTemplate.query(
                "SELECT ID_USUARIO FROM USUARIO WHERE CORREO = ?",
                (rs, rowNum) -> rs.getLong("ID_USUARIO"),
                correo);
        return ids.stream().findFirst();
    }

    public boolean belongsToUser(Long reservaId, String correo) {
        Integer count = jdbcTemplate.queryForObject("""
                SELECT COUNT(*) FROM RESERVA R
                JOIN USUARIO U ON U.ID_USUARIO = R.ID_USUARIO
                WHERE R.ID_RESERVA = ? AND U.CORREO = ?
                """, Integer.class, reservaId, correo);
        return count != null && count > 0;
    }
}
