class AppMessages {
  const AppMessages._();

  static const String tryAgain = 'Try Again';
  static const String unknownError = 'Unknown error.';
  static const String genericActionFailed =
      'Something went wrong. Please try again.';
}

class AuthMessages {
  const AuthMessages._();

  static const String googleSignInCancelled = 'Google sign-in was cancelled.';
  static const String registrationSuccessful =
      'Registration successful. Please sign in.';
  static const String otpDigitsRequired = 'Please enter all 4 digits.';
  static const String otpVerifySuccess =
      'Email verified successfully. Please sign in.';
  static const String resetPasswordFailed =
      'Unable to reset password. Please try again.';
  static const String resetPasswordSuccess = 'Password updated successfully.';

  static const String requiredFullName = 'Please enter your full name';
  static const String requiredEmail = 'Please enter your email';
  static const String invalidEmail = 'Invalid email format';
  static const String requiredPassword = 'Please enter your password';
  static const String requiredConfirmPassword = 'Please confirm your password';
  static const String passwordMismatch = 'Passwords do not match';
  static const String passwordTooLong =
      'Password must be less than 255 characters';
  static const String passwordRequirementSummary =
      'Password must include 8+ chars, an uppercase letter, and a special character';
}

class CategoryMessages {
  const CategoryMessages._();

  static const String requiredCategoryName = 'Please enter a category name.';
  static const String noCategories =
      'No categories yet. Create one to get started.';
  static const String categoryCreateFailed = 'Failed to create category';
  static const String categoryUpdateFailed = 'Failed to update category';
  static const String categoryDeleteFailed = 'Failed to delete category';

  static String deletedCategory(String categoryName) =>
      'Deleted $categoryName.';
}

class StudyMessages {
  const StudyMessages._();

  static const String startSessionFailed =
      'Unable to start the study session. Please try again.';
  static const String startSessionTitle = 'Unable to start the study session.';
  static const String noSessionData = 'No study session data available.';
  static const String goBack = 'Go Back';
}
