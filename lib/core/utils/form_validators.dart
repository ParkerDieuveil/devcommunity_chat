import '../locale/app_strings.dart';

/// Parties locales typiques d'emails de test / fictifs.
const _blockedLocalParts = {
  'test',
  'testing',
  'fake',
  'demo',
  'sample',
  'example',
  'asdf',
  'qwerty',
  'temp',
  'tmp',
  'user',
  'username',
  'email',
  'mail',
  'admin',
  'root',
  'null',
  'undefined',
};

/// Domaines fictifs / jetables courants.
const _blockedDomains = {
  'example.com',
  'example.org',
  'example.net',
  'test.com',
  'test.org',
  'localhost',
  'mailinator.com',
  'guerrillamail.com',
  'tempmail.com',
  'throwaway.email',
  'yopmail.com',
  '10minutemail.com',
};

String? validateEmail(String? value, AppStrings s) {
  final email = value?.trim() ?? '';

  if (email.isEmpty) {
    return s.emailRequired;
  }

  final emailRegex = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');

  if (!emailRegex.hasMatch(email)) {
    return s.invalidEmail;
  }

  final parts = email.toLowerCase().split('@');
  if (parts.length != 2) {
    return s.invalidEmail;
  }

  final local = parts[0];
  final domain = parts[1];

  // test, test1, test123, fake.user, etc.
  final localRoot = local.split(RegExp(r'[._+-]')).first;
  final looksLikeTestLocal = _blockedLocalParts.contains(localRoot) ||
      RegExp(r'^test\d*$').hasMatch(localRoot);

  if (looksLikeTestLocal || _blockedDomains.contains(domain)) {
    return s.emailNotAllowed;
  }

  return null;
}
