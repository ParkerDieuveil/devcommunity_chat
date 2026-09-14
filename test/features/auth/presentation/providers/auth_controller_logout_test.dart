import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:devcommunitychat/features/auth/domain/entities/app_user.dart';
import 'package:devcommunitychat/features/auth/domain/usecases/logout_use_case.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_controller.dart';
import 'package:devcommunitychat/features/auth/presentation/providers/auth_provider.dart';

import '../../fakes/fake_auth_repository.dart';

void main() {
  group('AuthController.logout', () {
    late FakeAuthRepository fakeRepository;
    late ProviderContainer container;

    setUp(() {
      fakeRepository = FakeAuthRepository();
      container = ProviderContainer(
        overrides: [
          logoutUseCaseProvider.overrideWithValue(
            LogoutUseCase(fakeRepository),
          ),
        ],
      );
      addTearDown(container.dispose);
      addTearDown(fakeRepository.dispose);
    });

    test('délègue au repository et passe à AsyncData(null) en cas de succès', () async {
      final states = <AsyncValue<AppUser?>>[];
      container.listen(
        authControllerProvider,
        (previous, next) => states.add(next),
        fireImmediately: true,
      );

      await container.read(authControllerProvider.notifier).logout();

      expect(fakeRepository.logoutCalled, isTrue);
      expect(states.any((s) => s.isLoading), isTrue);
      expect(states.last, isA<AsyncData<AppUser?>>());
      expect(states.last.value, isNull);
    });

    test('expose une AsyncError si le repository échoue', () async {
      fakeRepository.logoutError = Exception('boom');

      await container.read(authControllerProvider.notifier).logout();

      final state = container.read(authControllerProvider);
      expect(state, isA<AsyncError<AppUser?>>());
    });
  });
}
