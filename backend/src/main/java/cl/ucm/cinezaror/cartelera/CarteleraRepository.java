package cl.ucm.cinezaror.cartelera;

import cl.ucm.cinezaror.cartelera.dto.CarteleraItemDto;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.RowMapper;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.time.LocalDate;
import java.util.List;

@Repository
public class CarteleraRepository {

    private final JdbcTemplate jdbcTemplate;

    private static final RowMapper<CarteleraItemDto> ROW_MAPPER = (rs, rowNum) -> new CarteleraItemDto(
            rs.getLong("ID_FUNCION"),
            rs.getLong("ID_PELICULA"),
            rs.getString("TITULO"),
            rs.getString("CLASIFICACION"),
            rs.getInt("DURACION_MINUTOS"),
            rs.getString("GENERO"),
            rs.getLong("ID_SALA"),
            rs.getString("SALA"),
            rs.getDate("FECHA").toLocalDate(),
            rs.getString("HORA"),
            rs.getTimestamp("FECHA_HORA").toLocalDateTime(),
            rs.getBigDecimal("PRECIO"),
            rs.getInt("ASIENTOS_DISPONIBLES")
    );

    public CarteleraRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    public List<CarteleraItemDto> findByFecha(LocalDate fecha) {
        return jdbcTemplate.query("""
                SELECT ID_FUNCION, ID_PELICULA, TITULO, CLASIFICACION, DURACION_MINUTOS, GENERO,
                       ID_SALA, SALA, FECHA, HORA, FECHA_HORA, PRECIO, ASIENTOS_DISPONIBLES
                FROM VW_CARTELERA
                WHERE FECHA = ?
                ORDER BY TITULO, HORA
                """, ROW_MAPPER, java.sql.Date.valueOf(fecha));
    }
}
