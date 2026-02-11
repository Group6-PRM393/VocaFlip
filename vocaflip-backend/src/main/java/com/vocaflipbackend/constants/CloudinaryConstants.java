package com.vocaflipbackend.constants;

public class CloudinaryConstants {
    private CloudinaryConstants() {
        // Private constructor to prevent instantiation
    }

    public static final String DECK_COVER_FOLDER = "vocaflip/deck-covers";
    public static final int COVER_WIDTH = 800;
    public static final int COVER_HEIGHT = 600;
    
    // Giới hạn kích thước file upload (5MB)
    public static final long MAX_FILE_SIZE = 5 * 1024 * 1024; // 5MB in bytes
}
