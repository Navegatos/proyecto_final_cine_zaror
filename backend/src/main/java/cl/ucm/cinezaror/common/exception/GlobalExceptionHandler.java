package cl.ucm.cinezaror.common.exception;

import cl.ucm.cinezaror.common.dto.ApiResponse;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataAccessException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.AuthenticationException;
import org.springframework.validation.FieldError;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;

import java.util.stream.Collectors;

@RestControllerAdvice
public class GlobalExceptionHandler {

    private static final Logger log = LoggerFactory.getLogger(GlobalExceptionHandler.class);

    @ExceptionHandler(BusinessException.class)
    public ResponseEntity<ApiResponse<Void>> handleBusinessException(BusinessException ex) {
        return ResponseEntity
                .status(ex.getStatus())
                .body(ApiResponse.error(ex.getMessage(), ex.getCode().name()));
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    public ResponseEntity<ApiResponse<Void>> handleValidationException(MethodArgumentNotValidException ex) {
        String message = ex.getBindingResult().getFieldErrors().stream()
                .map(this::formatFieldError)
                .collect(Collectors.joining("; "));

        return ResponseEntity
                .status(HttpStatus.BAD_REQUEST)
                .body(ApiResponse.error(message, ErrorCode.VALIDATION_ERROR.name()));
    }

    @ExceptionHandler({AuthenticationException.class, BadCredentialsException.class})
    public ResponseEntity<ApiResponse<Void>> handleAuthenticationException(AuthenticationException ex) {
        return ResponseEntity
                .status(HttpStatus.UNAUTHORIZED)
                .body(ApiResponse.error(ex.getMessage(), ErrorCode.UNAUTHORIZED.name()));
    }

    @ExceptionHandler(AccessDeniedException.class)
    public ResponseEntity<ApiResponse<Void>> handleAccessDeniedException(AccessDeniedException ex) {
        return ResponseEntity
                .status(HttpStatus.FORBIDDEN)
                .body(ApiResponse.error("No tiene permisos para esta operación", ErrorCode.FORBIDDEN.name()));
    }

    @ExceptionHandler(DataAccessException.class)
    public ResponseEntity<ApiResponse<Void>> handleDataAccessException(DataAccessException ex) {
        log.error("Error de acceso a datos", ex);
        String message = resolveOracleMessage(ex);
        HttpStatus status = resolveOracleStatus(ex);
        ErrorCode code = status == HttpStatus.CONFLICT
                ? ErrorCode.BUSINESS_CONFLICT
                : ErrorCode.DATABASE_ERROR;

        return ResponseEntity
                .status(status)
                .body(ApiResponse.error(message, code.name()));
    }

    @ExceptionHandler(Exception.class)
    public ResponseEntity<ApiResponse<Void>> handleGenericException(Exception ex) {
        log.error("Error interno no controlado", ex);
        return ResponseEntity
                .status(HttpStatus.INTERNAL_SERVER_ERROR)
                .body(ApiResponse.error("Error interno del servidor", ErrorCode.INTERNAL_ERROR.name()));
    }

    private String formatFieldError(FieldError error) {
        return error.getField() + ": " + error.getDefaultMessage();
    }

    private String resolveOracleMessage(DataAccessException ex) {
        String rawMessage = ex.getMostSpecificCause().getMessage();
        if (rawMessage == null) {
            return "Error al ejecutar operación en la base de datos";
        }

        int oraIndex = rawMessage.indexOf("ORA-");
        if (oraIndex >= 0) {
            int end = rawMessage.indexOf('\n', oraIndex);
            return end > oraIndex ? rawMessage.substring(oraIndex, end) : rawMessage.substring(oraIndex);
        }

        return "Error al ejecutar operación en la base de datos";
    }

    private HttpStatus resolveOracleStatus(DataAccessException ex) {
        String rawMessage = ex.getMostSpecificCause().getMessage();
        if (rawMessage != null && rawMessage.contains("ORA-200")) {
            return HttpStatus.CONFLICT;
        }
        return HttpStatus.INTERNAL_SERVER_ERROR;
    }
}
