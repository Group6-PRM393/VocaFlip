package com.vocaflipbackend.constants;

public final class FlipMatchConstants {

    private FlipMatchConstants() {
    }

    public static final int DEFAULT_CARD_FETCH_LIMIT = 32;
    public static final int MAX_CARD_FETCH_LIMIT = 120;
    public static final int DEFAULT_HISTORY_LIMIT = 20;
    public static final int MAX_HISTORY_LIMIT = 100;
    public static final int DEFAULT_MIN_DECK_CARDS = 12;

    public static final String DEFAULT_MIN_DECK_CARDS_QUERY = "12";
    public static final String DEFAULT_CARD_FETCH_LIMIT_QUERY = "32";
    public static final String DEFAULT_HISTORY_LIMIT_QUERY = "20";

    public static final String REDIS_HISTORY_KEY_PREFIX = "flip_match:history:";
    public static final String REDIS_TOTAL_SCORE_KEY_PREFIX = "flip_match:total_score:";

    public static final String SAVE_RESULT_SUCCESS_MESSAGE = "Flip match result saved";
    public static final String SAVE_HISTORY_ERROR_MESSAGE = "Cannot save flip-match history";
}