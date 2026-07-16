package cl.ucm.cinezaror.admin;

import cl.ucm.cinezaror.admin.dto.EstadoRequest;
import cl.ucm.cinezaror.admin.dto.FuncionRequest;
import cl.ucm.cinezaror.admin.dto.PeliculaRequest;
import cl.ucm.cinezaror.admin.dto.SalaRequest;
import org.springframework.stereotype.Service;

import java.util.List;
import java.util.Map;

@Service
public class AdminService {

    private final AdminRepository adminRepository;

    public AdminService(AdminRepository adminRepository) {
        this.adminRepository = adminRepository;
    }

    public List<Map<String, Object>> listarPeliculas() { return adminRepository.listarPeliculas(); }
    public Long crearPelicula(PeliculaRequest req) { return adminRepository.crearPelicula(req); }
    public void actualizarPelicula(Long id, PeliculaRequest req) { adminRepository.actualizarPelicula(id, req); }
    public void cambiarEstadoPelicula(Long id, EstadoRequest req) { adminRepository.cambiarEstadoPelicula(id, req.activo()); }

    public List<Map<String, Object>> listarSalas() { return adminRepository.listarSalas(); }
    public Long crearSala(SalaRequest req) { return adminRepository.crearSala(req); }
    public void actualizarSala(Long id, SalaRequest req) { adminRepository.actualizarSala(id, req); }
    public void cambiarEstadoSala(Long id, EstadoRequest req) { adminRepository.cambiarEstadoSala(id, req.activo()); }
    public void generarAsientos(Long salaId) { adminRepository.generarAsientos(salaId); }

    public List<Map<String, Object>> listarFunciones() { return adminRepository.listarFunciones(); }
    public Long crearFuncion(FuncionRequest req) { return adminRepository.crearFuncion(req); }
    public void actualizarFuncion(Long id, FuncionRequest req) { adminRepository.actualizarFuncion(id, req); }
    public void desactivarFuncion(Long id) { adminRepository.desactivarFuncion(id); }
}
