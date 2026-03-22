class ErrorMessageUtils {
  const ErrorMessageUtils._();

  static String normalize(Object error, {required String fallback}) {
    final message = error.toString().replaceFirst('Exception: ', '').trim();
    return message.isEmpty ? fallback : message;
  }
}
