package cl.ucm.cinezaror.auth;

import cl.ucm.cinezaror.auth.dto.LoginRequest;
import cl.ucm.cinezaror.auth.dto.LoginResponse;
import cl.ucm.cinezaror.auth.dto.RegisterRequest;
import cl.ucm.cinezaror.common.exception.BusinessException;
import cl.ucm.cinezaror.common.exception.ErrorCode;
import cl.ucm.cinezaror.security.JwtTokenProvider;
import cl.ucm.cinezaror.usuario.UsuarioRecord;
import cl.ucm.cinezaror.usuario.UsuarioRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

@Service
public class AuthService {

    private final UsuarioRepository usuarioRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtTokenProvider jwtTokenProvider;

    public AuthService(UsuarioRepository usuarioRepository,
                       PasswordEncoder passwordEncoder,
                       JwtTokenProvider jwtTokenProvider) {
        this.usuarioRepository = usuarioRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtTokenProvider = jwtTokenProvider;
    }

    public void register(RegisterRequest request) {
        String hash = passwordEncoder.encode(request.password());
        usuarioRepository.registrarUsuario(
                request.rut(),
                request.nombreCompleto(),
                request.correo(),
                hash
        );
    }

    public LoginResponse login(LoginRequest request) {
        UsuarioRecord usuario = usuarioRepository.findByCorreo(request.correo())
                .orElseThrow(() -> new BusinessException(
                        "Credenciales inválidas", HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHORIZED));

        if (usuario.activo() != 1) {
            throw new BusinessException(
                    "Usuario inactivo", HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHORIZED);
        }

        if (!passwordEncoder.matches(request.password(), usuario.passwordHash())) {
            throw new BusinessException(
                    "Credenciales inválidas", HttpStatus.UNAUTHORIZED, ErrorCode.UNAUTHORIZED);
        }

        String token = jwtTokenProvider.generateToken(usuario.correo(), usuario.rol());
        return new LoginResponse(token, usuario.nombreCompleto(), usuario.rol());
    }
}
