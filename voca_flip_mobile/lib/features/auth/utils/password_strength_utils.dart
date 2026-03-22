import 'package:voca_flip_mobile/features/auth/constants/password_constants.dart';

enum PasswordStrengthLevel { weak, medium, strong }

class PasswordStrengthResult {
  const PasswordStrengthResult({
    required this.hasMinLength,
    required this.hasUppercase,
    required this.hasSpecialCharacter,
    required this.score,
  });

  final bool hasMinLength;
  final bool hasUppercase;
  final bool hasSpecialCharacter;
  final int score;

  bool get isValid => hasMinLength && hasUppercase && hasSpecialCharacter;

  PasswordStrengthLevel get level {
    if (score <= 1) return PasswordStrengthLevel.weak;
    if (score <= 3) return PasswordStrengthLevel.medium;
    return PasswordStrengthLevel.strong;
  }

  String get label {
    switch (level) {
      case PasswordStrengthLevel.weak:
        return 'Weak';
      case PasswordStrengthLevel.medium:
        return 'Medium';
      case PasswordStrengthLevel.strong:
        return 'Strong';
    }
  }
}

class PasswordStrengthEvaluator {
  const PasswordStrengthEvaluator._();

  static PasswordStrengthResult evaluate(String password) {
    final hasMinLength = password.length >= PasswordConstants.minLength;
    final hasUppercase = RegExp(r'[A-Z]').hasMatch(password);
    final hasSpecialCharacter = password
        .split('')
        .any(PasswordConstants.specialCharacters.contains);

    var score = 0;
    if (hasMinLength) score++;
    if (hasUppercase) score++;
    if (hasSpecialCharacter) score++;
    if (password.length >= PasswordConstants.strongLengthBonus) score++;

    return PasswordStrengthResult(
      hasMinLength: hasMinLength,
      hasUppercase: hasUppercase,
      hasSpecialCharacter: hasSpecialCharacter,
      score: score,
    );
  }
}
