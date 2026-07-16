package cl.ucm.cinezaror.controller;

import cl.ucm.cinezaror.common.dto.ApiResponse;
import cl.ucm.cinezaror.common.dto.HealthData;
import org.springframework.dao.DataAccessException;
import org.springframework.http.ResponseEntity;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

import java.time.Instant;

@RestController
@RequestMapping("/api/health")
public class HealthController {

    private final JdbcTemplate jdbcTemplate;

    public HealthController(JdbcTemplate jdbcTemplate) {
        this.jdbcTemplate = jdbcTemplate;
    }

    @GetMapping
    public ResponseEntity<ApiResponse<HealthData>> health() {
        String databaseStatus = checkDatabase();

        HealthData data = new HealthData(
                "UP",
                databaseStatus,
                Instant.now()
        );

        String message = "UP".equals(databaseStatus)
                ? "Servicio operativo"
                : "Servicio activo con problemas de base de datos";

        return ResponseEntity.ok(ApiResponse.ok(message, data));
    }

    private String checkDatabase() {
        try {
            jdbcTemplate.queryForObject("SELECT 1 FROM DUAL", Integer.class);
            return "UP";
        } catch (DataAccessException ex) {
            return "DOWN";
        }
    }
}
