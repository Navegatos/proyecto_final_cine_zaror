package cl.ucm.cinezaror.funcion.dto;

import java.util.List;

public record AsientosFuncionResponse(
        Long funcionId,
        String sala,
        List<AsientoDto> asientos
) {
}
