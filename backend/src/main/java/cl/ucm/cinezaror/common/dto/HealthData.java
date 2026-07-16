package cl.ucm.cinezaror.common.dto;

import java.time.Instant;

public record HealthData(
        String status,
        String database,
        Instant timestamp
) {
}
