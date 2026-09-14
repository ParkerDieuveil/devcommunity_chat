import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/profile/domain/usecases/update_profile.dart';

import '../../fakes/fake_profile_repository.dart';

void main() {
  group('UpdateProfile', () {
    test('délègue au repository avec les bons paramètres', () async {
      final repository = FakeProfileRepository();
      final useCase = UpdateProfile(repository);

      final result = await useCase.call(
        userId: 'user-1',
        name: 'Alex',
        email: 'alex@example.com',
        bio: 'Dev Flutter',
      );

      expect(repository.updateCalls, hasLength(1));
      final call = repository.updateCalls.single;
      expect(call.userId, 'user-1');
      expect(call.name, 'Alex');
      expect(call.email, 'alex@example.com');
      expect(call.bio, 'Dev Flutter');
      expect(result.displayname, 'Alex');
    });

    test('propage l\'erreur du repository', () {
      final repository = FakeProfileRepository()
        ..updateProfileError = Exception('Firestore indisponible');
      final useCase = UpdateProfile(repository);

      expect(
        () => useCase.call(userId: 'user-1', name: 'Alex'),
        throwsException,
      );
    });
  });
}
