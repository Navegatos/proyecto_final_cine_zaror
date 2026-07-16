package cl.ucm.cinezaror.funcion;

import cl.ucm.cinezaror.common.exception.BusinessException;
import cl.ucm.cinezaror.common.exception.ErrorCode;
import cl.ucm.cinezaror.funcion.dto.AsientosFuncionResponse;
import cl.ucm.cinezaror.funcion.dto.FuncionDetalleDto;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

@Service
public class FuncionService {

    private final FuncionRepository funcionRepository;

    public FuncionService(FuncionRepository funcionRepository) {
        this.funcionRepository = funcionRepository;
    }

    public FuncionDetalleDto obtenerDetalle(Long id) {
        return funcionRepository.findById(id)
                .orElseThrow(() -> new BusinessException(
                        "Función no encontrada", HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND));
    }

    public AsientosFuncionResponse obtenerAsientos(Long id) {
        obtenerDetalle(id);
        return new AsientosFuncionResponse(
                id,
                funcionRepository.findSalaNombre(id),
                funcionRepository.findAsientosByFuncion(id)
        );
    }
}
