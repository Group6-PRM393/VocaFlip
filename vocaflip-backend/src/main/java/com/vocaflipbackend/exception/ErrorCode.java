package com.vocaflipbackend.exception;

import lombok.Getter;
import org.springframework.http.HttpStatus;
import org.springframework.http.HttpStatusCode;

@Getter
public enum ErrorCode {
    UNCATEGORIZED_EXCEPTION(9999, "Uncategorized error", HttpStatus.INTERNAL_SERVER_ERROR),
    INVALID_KEY(1001, "Uncategorized error", HttpStatus.BAD_REQUEST),
    USER_EXISTED(1002, "User existed", HttpStatus.BAD_REQUEST),
    USERNAME_INVALID(1003, "Username must be at least 3 characters", HttpStatus.BAD_REQUEST),
    INVALID_PASSWORD(1004, "Password must be at least 8 characters", HttpStatus.BAD_REQUEST),
    USER_NOT_FOUND(1005, "User not found", HttpStatus.NOT_FOUND),
    UNAUTHENTICATED(1006, "Unauthenticated", HttpStatus.UNAUTHORIZED),
    UNAUTHORIZED(1007, "You do not have permission", HttpStatus.FORBIDDEN),
    DECK_NOT_FOUND(1008, "Deck not found", HttpStatus.NOT_FOUND),
    CATEGORY_NOT_FOUND(1009, "Category not found", HttpStatus.NOT_FOUND),
    CATEGORY_REQUIRED(1010, "Category is required", HttpStatus.BAD_REQUEST),
    // File upload errors
    FILE_EMPTY(1011, "File is empty", HttpStatus.BAD_REQUEST),
    FILE_UPLOAD_FAILED(1012, "Failed to upload file", HttpStatus.INTERNAL_SERVER_ERROR),
    FILE_DELETE_FAILED(1013, "Failed to delete file", HttpStatus.INTERNAL_SERVER_ERROR),
    INVALID_FILE_TYPE(1014, "Invalid file type", HttpStatus.BAD_REQUEST),
    ;

    ErrorCode(int code, String message, HttpStatusCode statusCode) {
        this.code = code;
        this.message = message;
        this.statusCode = statusCode;
    }

    private final int code;
    private final String message;
    private final HttpStatusCode statusCode;
}
