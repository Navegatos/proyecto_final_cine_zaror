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
    private final SimpleJdbcCall actualizarPeliculaCall;
    private final SimpleJdbcCall cambiarEstadoPeliculaCall;
    private final SimpleJdbcCall crearSalaCall;
    private final SimpleJdbcCall actualizarSalaCall;
    private final SimpleJdbcCall cambiarEstadoSalaCall;
    private final SimpleJdbcCall generarAsientosCall;
    private final SimpleJdbcCall crearFuncionCall;
    private final SimpleJdbcCall actualizarFuncionCall;
    private final SimpleJdbcCall cambiarEstadoFuncionCall;

    public AdminRepository(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
        this.crearPeliculaCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("SP_CREAR_PELICULA");
        this.actualizarPeliculaCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("SP_ACTUALIZAR_PELICULA");
        this.cambiarEstadoPeliculaCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("SP_CAMBIAR_ESTADO_PELICULA");
        this.crearSalaCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("SP_CREAR_SALA");
        this.actualizarSalaCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("SP_ACTUALIZAR_SALA");
        this.cambiarEstadoSalaCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("SP_CAMBIAR_ESTADO_SALA");
        this.generarAsientosCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("SP_GENERAR_ASIENTOS_SALA");
        this.crearFuncionCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("SP_CREAR_FUNCION");
        this.actualizarFuncionCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("SP_ACTUALIZAR_FUNCION");
        this.cambiarEstadoFuncionCall = new SimpleJdbcCall(jdbcTemplate).withProcedureName("SP_CAMBIAR_ESTADO_FUNCION");
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
        actualizarPeliculaCall.execute(Map.of(
                "P_ID_PELICULA", id,
                "P_TITULO", req.titulo(),
                "P_SINOPSIS", req.sinopsis(),
                "P_DURACION_MINUTOS", req.duracionMinutos(),
                "P_CLASIFICACION", req.clasificacion(),
                "P_GENERO", req.genero(),
                "P_URL_IMAGEN", req.urlImagen()
        ));
    }

    public void cambiarEstadoPelicula(Long id, boolean activa) {
        cambiarEstadoPeliculaCall.execute(Map.of(
                "P_ID_PELICULA", id,
                "P_ACTIVA", activa ? 1 : 0
        ));
    }

    public List<Map<String, Object>> listarSalas() {
        return jdbcTemplate.queryForList("""
                SELECT S.*,
                       (SELECT COUNT(*) FROM ASIENTO A WHERE A.ID_SALA = S.ID_SALA) AS CANTIDAD_ASIENTOS
                FROM SALA S
                ORDER BY S.NOMBRE
                """);
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
        actualizarSalaCall.execute(Map.of(
                "P_ID_SALA", id,
                "P_NOMBRE", req.nombre(),
                "P_FILAS", req.filas(),
                "P_COLUMNAS", req.columnas()
        ));
    }

    public void cambiarEstadoSala(Long id, boolean activa) {
        cambiarEstadoSalaCall.execute(Map.of(
                "P_ID_SALA", id,
                "P_ACTIVA", activa ? 1 : 0
        ));
    }

    public void generarAsientos(Long salaId) {
        generarAsientosCall.execute(Map.of("P_ID_SALA", salaId));
    }

    public List<Map<String, Object>> listarFunciones() {
        return jdbcTemplate.queryForList("""
                SELECT F.ID_FUNCION, F.ID_PELICULA, F.ID_SALA,
                       P.TITULO AS PELICULA, S.NOMBRE AS SALA,
                       F.FECHA_HORA, F.PRECIO, F.ACTIVA
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
        actualizarFuncionCall.execute(Map.of(
                "P_ID_FUNCION", id,
                "P_ID_PELICULA", req.peliculaId(),
                "P_ID_SALA", req.salaId(),
                "P_FECHA_HORA", Timestamp.valueOf(req.fechaHora()),
                "P_PRECIO", req.precio()
        ));
    }

    public void cambiarEstadoFuncion(Long id, boolean activa) {
        cambiarEstadoFuncionCall.execute(Map.of(
                "P_ID_FUNCION", id,
                "P_ACTIVA", activa ? 1 : 0
        ));
    }
}
