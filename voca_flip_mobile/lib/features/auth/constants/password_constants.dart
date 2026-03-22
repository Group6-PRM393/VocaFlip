class PasswordConstants {
  const PasswordConstants._();

  static const int minLength = 8;
  static const int strongLengthBonus = 12;
  static const int maxLength = 255;

  static const String specialCharacters =
      r'''!@#$%^&*(),.?":{}|<>_-+=~`[]\/;''';

  static const String strengthGuideText =
      'Use at least 8 characters, 1 uppercase letter, and 1 special character.';
}
