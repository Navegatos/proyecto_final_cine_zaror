package cl.ucm.cinezaror.funcion;

import cl.ucm.cinezaror.funcion.dto.AsientoDto;
import cl.ucm.cinezaror.funcion.dto.FuncionDetalleDto;
import org.springframework.dao.EmptyResultDataAccessException;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public class FuncionRepository {

    private final JdbcTemplate jdbcTemplate;

    public FuncionRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public Optional<FuncionDetalleDto> findById(Long id) {
        try {
            return Optional.of(jdbcTemplate.queryForObject("""
                    SELECT F.ID_FUNCION, P.ID_PELICULA, P.TITULO, P.SINOPSIS, P.DURACION_MINUTOS,
                           P.CLASIFICACION, S.ID_SALA, S.NOMBRE AS SALA, F.FECHA_HORA, F.PRECIO,
                           FN_CANTIDAD_ASIENTOS_DISPONIBLES(F.ID_FUNCION) AS ASIENTOS_DISPONIBLES
                    FROM FUNCION F
                    JOIN PELICULA P ON P.ID_PELICULA = F.ID_PELICULA
                    JOIN SALA S ON S.ID_SALA = F.ID_SALA
                    WHERE F.ID_FUNCION = ?
                    """, (rs, rowNum) -> new FuncionDetalleDto(
                    rs.getLong("ID_FUNCION"),
                    rs.getLong("ID_PELICULA"),
                    rs.getString("TITULO"),
                    rs.getString("SINOPSIS"),
                    rs.getInt("DURACION_MINUTOS"),
                    rs.getString("CLASIFICACION"),
                    rs.getLong("ID_SALA"),
                    rs.getString("SALA"),
                    rs.getTimestamp("FECHA_HORA").toLocalDateTime(),
                    rs.getBigDecimal("PRECIO"),
                    rs.getInt("ASIENTOS_DISPONIBLES")
            ), id));
        } catch (EmptyResultDataAccessException ex) {
            return Optional.empty();
        }
    }

    public List<AsientoDto> findAsientosByFuncion(Long funcionId) {
        return jdbcTemplate.query("""
                SELECT ID_ASIENTO, FILA, NUMERO, ESTADO
                FROM VW_ASIENTOS_FUNCION
                WHERE ID_FUNCION = ?
                ORDER BY FILA, NUMERO
                """, (rs, rowNum) -> new AsientoDto(
                rs.getLong("ID_ASIENTO"),
                rs.getString("FILA"),
                rs.getInt("NUMERO"),
                rs.getString("ESTADO")
        ), funcionId);
    }

    public String findSalaNombre(Long funcionId) {
        return jdbcTemplate.queryForObject(
                "SELECT S.NOMBRE FROM FUNCION F JOIN SALA S ON S.ID_SALA = F.ID_SALA WHERE F.ID_FUNCION = ?",
                String.class, funcionId);
    }
}
