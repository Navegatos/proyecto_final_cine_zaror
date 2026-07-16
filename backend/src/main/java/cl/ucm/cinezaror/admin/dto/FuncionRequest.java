package cl.ucm.cinezaror.admin.dto;

import jakarta.validation.constraints.NotNull;
import jakarta.validation.constraints.Positive;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public record FuncionRequest(
        @NotNull Long peliculaId,
        @NotNull Long salaId,
        @NotNull LocalDateTime fechaHora,
        @NotNull @Positive BigDecimal precio
) {
}
