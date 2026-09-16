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

      expect(repository.updateProfileCallCount, 1);
      expect(repository.lastUserId, 'user-1');
      expect(repository.lastName, 'Alex');
      expect(repository.lastEmail, 'alex@example.com');
      expect(repository.lastBio, 'Dev Flutter');
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
