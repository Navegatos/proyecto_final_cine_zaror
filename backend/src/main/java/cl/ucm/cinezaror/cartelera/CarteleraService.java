package cl.ucm.cinezaror.cartelera;

import cl.ucm.cinezaror.cartelera.dto.CarteleraItemDto;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;

@Service
public class CarteleraService {

    private final CarteleraRepository carteleraRepository;

    public CarteleraService(CarteleraRepository carteleraRepository) {
        this.carteleraRepository = carteleraRepository;
    }

    public List<CarteleraItemDto> obtenerCartelera(LocalDate fecha) {
        return carteleraRepository.findByFecha(fecha);
    }
}
