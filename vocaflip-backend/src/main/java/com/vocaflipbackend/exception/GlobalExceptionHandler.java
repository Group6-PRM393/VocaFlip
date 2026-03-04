package com.vocaflipbackend.exception;

import com.vocaflipbackend.dto.response.ApiResponse;
import io.jsonwebtoken.ExpiredJwtException;
import io.jsonwebtoken.security.SignatureException;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.ResponseEntity;
import org.springframework.security.authentication.BadCredentialsException;
import org.springframework.security.core.userdetails.UsernameNotFoundException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ControllerAdvice;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.multipart.MaxUploadSizeExceededException;

@ControllerAdvice
@Slf4j
public class GlobalExceptionHandler {

    @ExceptionHandler(value = RuntimeException.class)
    ResponseEntity<ApiResponse> handlingRuntimeException(RuntimeException exception) {
        log.error("Uncategorized exception: ", exception);
        ApiResponse apiResponse = new ApiResponse();
        apiResponse.setCode(ErrorCode.UNCATEGORIZED_EXCEPTION.getCode());
        apiResponse.setMessage(exception.getMessage());
        return ResponseEntity.badRequest().body(apiResponse);
    }

    @ExceptionHandler(value = AppException.class)
    ResponseEntity<ApiResponse> handlingAppException(AppException exception) {
        ErrorCode errorCode = exception.getErrorCode();
        ApiResponse apiResponse = new ApiResponse();
        apiResponse.setCode(errorCode.getCode());
        apiResponse.setMessage(errorCode.getMessage());
        return ResponseEntity
                .status(errorCode.getStatusCode())
                .body(apiResponse);
    }

    @ExceptionHandler(value = MethodArgumentNotValidException.class)
    ResponseEntity<ApiResponse> handlingValidation(MethodArgumentNotValidException exception) {
        String enumKey = exception.getFieldError().getDefaultMessage();
        ErrorCode errorCode = ErrorCode.INVALID_KEY;
        try {
            errorCode = ErrorCode.valueOf(enumKey);
        } catch (IllegalArgumentException e) {
            // ignore
        }
        ApiResponse apiResponse = new ApiResponse();
        apiResponse.setCode(errorCode.getCode());
        apiResponse.setMessage(errorCode.getMessage());
        return ResponseEntity.badRequest().body(apiResponse);
    }

    @ExceptionHandler(value = MaxUploadSizeExceededException.class)
    ResponseEntity<ApiResponse> handlingMaxUploadSizeExceededException(MaxUploadSizeExceededException exception) {
        ErrorCode errorCode = ErrorCode.FILE_SIZE_EXCEEDED;
        ApiResponse apiResponse = new ApiResponse();
        apiResponse.setCode(errorCode.getCode());
        apiResponse.setMessage(errorCode.getMessage());
        return ResponseEntity.status(errorCode.getStatusCode()).body(apiResponse);
    }

    /**
     * Xử lý Bad Credentials Exception - Sai email/password
     */
    @ExceptionHandler(BadCredentialsException.class)
    ResponseEntity<ApiResponse> handleBadCredentialsException(BadCredentialsException exception) {
        log.error("Bad credentials: {}", exception.getMessage());
        ErrorCode errorCode = ErrorCode.INVALID_CREDENTIALS;
        ApiResponse apiResponse = new ApiResponse();
        apiResponse.setCode(errorCode.getCode());
        apiResponse.setMessage(errorCode.getMessage());
        return ResponseEntity.status(errorCode.getStatusCode()).body(apiResponse);
    }

    /**
     * Xử lý User Not Found Exception
     */
    @ExceptionHandler(UsernameNotFoundException.class)
    ResponseEntity<ApiResponse> handleUsernameNotFoundException(UsernameNotFoundException exception) {
        log.error("User not found: {}", exception.getMessage());
        ErrorCode errorCode = ErrorCode.USER_NOT_EXISTED;
        ApiResponse apiResponse = new ApiResponse();
        apiResponse.setCode(errorCode.getCode());
        apiResponse.setMessage(errorCode.getMessage());
        return ResponseEntity.status(errorCode.getStatusCode()).body(apiResponse);
    }

    /**
     * Xử lý Expired JWT Exception
     */
    @ExceptionHandler(ExpiredJwtException.class)
    ResponseEntity<ApiResponse> handleExpiredJwtException(ExpiredJwtException exception) {
        log.error("JWT token expired: {}", exception.getMessage());
        ErrorCode errorCode = ErrorCode.INVALID_TOKEN;
        ApiResponse apiResponse = new ApiResponse();
        apiResponse.setCode(errorCode.getCode());
        apiResponse.setMessage("Token has expired");
        return ResponseEntity.status(errorCode.getStatusCode()).body(apiResponse);
    }

    /**
     * Xử lý Invalid JWT Signature Exception
     */
    @ExceptionHandler(SignatureException.class)
    ResponseEntity<ApiResponse> handleSignatureException(SignatureException exception) {
        log.error("Invalid JWT signature: {}", exception.getMessage());
        ErrorCode errorCode = ErrorCode.INVALID_TOKEN;
        ApiResponse apiResponse = new ApiResponse();
        apiResponse.setCode(errorCode.getCode());
        apiResponse.setMessage("Invalid token signature");
        return ResponseEntity.status(errorCode.getStatusCode()).body(apiResponse);
    }
}
