package cl.ucm.cinezaror.reserva;

import cl.ucm.cinezaror.common.exception.BusinessException;
import cl.ucm.cinezaror.common.exception.ErrorCode;
import cl.ucm.cinezaror.common.util.SecurityUtils;
import cl.ucm.cinezaror.reserva.dto.CrearReservaRequest;
import cl.ucm.cinezaror.reserva.dto.PagoRequest;
import cl.ucm.cinezaror.reserva.dto.ReservaDetalleDto;
import cl.ucm.cinezaror.reserva.dto.ReservaResponse;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;

import java.math.BigDecimal;
import java.util.List;
import java.util.Map;

@Service
public class ReservaService {

    private final ReservaRepository reservaRepository;

    public ReservaService(ReservaRepository reservaRepository) {
        this.reservaRepository = reservaRepository;
    }

    public ReservaResponse crearReserva(CrearReservaRequest request) {
        String correo = SecurityUtils.currentUserEmail();
        Long idUsuario = reservaRepository.findUsuarioIdByCorreo(correo)
                .orElseThrow(() -> new BusinessException(
                        "Usuario no autenticado", HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHORIZED));

        Map<String, Object> result = reservaRepository.crearReserva(
                idUsuario, request.funcionId(), request.asientoIds());

        Long idReserva = ((Number) result.get("P_ID_RESERVA")).longValue();
        String codigo = (String) result.get("P_CODIGO");
        BigDecimal total = new BigDecimal(result.get("P_TOTAL").toString());

        return new ReservaResponse(idReserva, codigo, request.asientoIds().size(), total, "PENDIENTE");
    }

    public Map<String, Object> confirmarPago(Long idReserva, PagoRequest request) {
        validarAccesoReserva(idReserva);
        return reservaRepository.confirmarPago(idReserva, request.metodo());
    }

    public List<ReservaDetalleDto> misReservas() {
        String correo = SecurityUtils.currentUserEmail();
        return reservaRepository.findByUsuarioCorreo(correo);
    }

    public ReservaDetalleDto obtenerReserva(Long id) {
        validarAccesoReserva(id);
        return reservaRepository.findById(id)
                .orElseThrow(() -> new BusinessException(
                        "Reserva no encontrada", HttpStatus.NOT_FOUND, ErrorCode.NOT_FOUND));
    }

    private void validarAccesoReserva(Long idReserva) {
        if (SecurityUtils.isAdmin()) {
            return;
        }
        String correo = SecurityUtils.currentUserEmail();
        if (!reservaRepository.belongsToUser(idReserva, correo)) {
            throw new BusinessException(
                    "No tiene permisos para esta reserva", HttpStatus.FORBIDDEN, ErrorCode.FORBIDDEN);
        }
    }
}
