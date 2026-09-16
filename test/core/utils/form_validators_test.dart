import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:devcommunitychat/core/locale/app_strings.dart';
import 'package:devcommunitychat/core/utils/form_validators.dart';

void main() {
  final s = AppStrings(const Locale('fr'));

  test('accepte un email réel', () {
    expect(validateEmail('marie.dupont@gmail.com', s), isNull);
  });

  test('refuse format invalide', () {
    expect(validateEmail('pas-un-email', s), s.invalidEmail);
  });

  test('refuse test@gmail.com', () {
    expect(validateEmail('test@gmail.com', s), s.emailNotAllowed);
  });

  test('refuse demo@ et example.com', () {
    expect(validateEmail('demo@yahoo.com', s), s.emailNotAllowed);
    expect(validateEmail('andry@example.com', s), s.emailNotAllowed);
  });
}
