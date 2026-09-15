import '../locale/app_strings.dart';

String? validateEmail(String? value, AppStrings s) {
  final email = value?.trim() ?? '';

  if (email.isEmpty) {
    return s.emailRequired;
  }

  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  if (!emailRegex.hasMatch(email)) {
    return s.invalidEmail;
  }

  return null;
}
