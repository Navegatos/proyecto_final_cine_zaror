package cl.ucm.cinezaror.cartelera.dto;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.LocalDateTime;

public record CarteleraItemDto(
        Long funcionId,
        Long peliculaId,
        String titulo,
        String clasificacion,
        Integer duracionMinutos,
        String genero,
        Long salaId,
        String sala,
        LocalDate fecha,
        String hora,
        LocalDateTime fechaHora,
        BigDecimal precio,
        Integer asientosDisponibles
) {
}
