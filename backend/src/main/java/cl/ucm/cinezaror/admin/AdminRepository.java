package cl.ucm.cinezaror.admin;

import cl.ucm.cinezaror.admin.dto.FuncionRequest;
import cl.ucm.cinezaror.admin.dto.PeliculaRequest;
import cl.ucm.cinezaror.admin.dto.SalaRequest;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.core.simple.SimpleJdbcCall;
import org.springframework.stereotype.Repository;

import java.sql.Timestamp;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Repository
public class AdminRepository {

    private final JdbcTemplate jdbcTemplate;
    private final SimpleJdbcCall crearPeliculaCall;
    private final SimpleJdbcCall crearSalaCall;
    private final SimpleJdbcCall generarAsientosCall;
    private final SimpleJdbcCall crearFuncionCall;
    private final SimpleJdbcCall desactivarFuncionCall;

    public AdminRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        this.crearPeliculaCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("SP_CREAR_PELICULA");
        this.crearSalaCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("SP_CREAR_SALA");
        this.generarAsientosCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("SP_GENERAR_ASIENTOS_SALA");
        this.crearFuncionCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("SP_CREAR_FUNCION");
        this.desactivarFuncionCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("SP_DESACTIVAR_FUNCION");
    }

    public List<Map<String, Object>> listarPeliculas() {
        return jdbcTemplate.queryForList("SELECT * FROM PELICULA ORDER BY TITULO");
    }

    public Long crearPelicula(PeliculaRequest req) {
        Map<String, Object> params = new HashMap<>();
        params.put("P_TITULO", req.titulo());
        params.put("P_SINOPSIS", req.sinopsis());
        params.put("P_DURACION_MINUTOS", req.duracionMinutos());
        params.put("P_CLASIFICACION", req.clasificacion());
        params.put("P_GENERO", req.genero());
        params.put("P_URL_IMAGEN", req.urlImagen());
        Map<String, Object> result = crearPeliculaCall.execute(params);
        return ((Number) result.get("P_ID_PELICULA")).longValue();
    }

    public void actualizarPelicula(Long id, PeliculaRequest req) {
        jdbcTemplate.update("""
                UPDATE PELICULA SET TITULO=?, SINOPSIS=?, DURACION_MINUTOS=?, CLASIFICACION=?, GENERO=?, URL_IMAGEN=?
                WHERE ID_PELICULA=?
                """, req.titulo(), req.sinopsis(), req.duracionMinutos(), req.clasificacion(),
                req.genero(), req.urlImagen(), id);
    }

    public void cambiarEstadoPelicula(Long id, boolean activa) {
        jdbcTemplate.update("UPDATE PELICULA SET ACTIVA = ? WHERE ID_PELICULA = ?", activa ? 1 : 0, id);
    }

    public List<Map<String, Object>> listarSalas() {
        return jdbcTemplate.queryForList("SELECT * FROM SALA ORDER BY NOMBRE");
    }

    public Long crearSala(SalaRequest req) {
        Map<String, Object> result = crearSalaCall.execute(Map.of(
                "P_NOMBRE", req.nombre(),
                "P_FILAS", req.filas(),
                "P_COLUMNAS", req.columnas()
        ));
        return ((Number) result.get("P_ID_SALA")).longValue();
    }

    public void actualizarSala(Long id, SalaRequest req) {
        jdbcTemplate.update("""
                UPDATE SALA SET NOMBRE=?, FILAS=?, COLUMNAS=? WHERE ID_SALA=?
                """, req.nombre(), req.filas(), req.columnas(), id);
    }

    public void cambiarEstadoSala(Long id, boolean activa) {
        jdbcTemplate.update("UPDATE SALA SET ACTIVA = ? WHERE ID_SALA = ?", activa ? 1 : 0, id);
    }

    public void generarAsientos(Long salaId) {
        generarAsientosCall.execute(Map.of("P_ID_SALA", salaId));
    }

    public List<Map<String, Object>> listarFunciones() {
        return jdbcTemplate.queryForList("""
                SELECT F.ID_FUNCION, P.TITULO AS PELICULA, S.NOMBRE AS SALA, F.FECHA_HORA, F.PRECIO, F.ACTIVA
                FROM FUNCION F
                JOIN PELICULA P ON P.ID_PELICULA = F.ID_PELICULA
                JOIN SALA S ON S.ID_SALA = F.ID_SALA
                ORDER BY F.FECHA_HORA
                """);
    }

    public Long crearFuncion(FuncionRequest req) {
        Map<String, Object> result = crearFuncionCall.execute(Map.of(
                "P_ID_PELICULA", req.peliculaId(),
                "P_ID_SALA", req.salaId(),
                "P_FECHA_HORA", Timestamp.valueOf(req.fechaHora()),
                "P_PRECIO", req.precio()
        ));
        return ((Number) result.get("P_ID_FUNCION")).longValue();
    }

    public void actualizarFuncion(Long id, FuncionRequest req) {
        jdbcTemplate.update("""
                UPDATE FUNCION SET ID_PELICULA=?, ID_SALA=?, FECHA_HORA=?, PRECIO=? WHERE ID_FUNCION=?
                """, req.peliculaId(), req.salaId(), Timestamp.valueOf(req.fechaHora()), req.precio(), id);
    }

    public void desactivarFuncion(Long id) {
        desactivarFuncionCall.execute(Map.of("P_ID_FUNCION", id));
    }
}
