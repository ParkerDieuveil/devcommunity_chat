

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:devcommunitychat/firebase_options.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late FirebaseAuth auth;

  setUpAll(() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    auth = FirebaseAuth.instance;

    // On s'assure qu'aucune session précédente
    // ne reste active avant les tests.
    await auth.signOut();
  });

  tearDown(() async {
    // Nettoyage après chaque test.
    await auth.signOut();
  });

  group('Firebase Authentication', () {
    testWidgets(
      'Un utilisateur peut créer un compte avec email et mot de passe',
          (tester) async {
        final email =
            'test_${DateTime.now().millisecondsSinceEpoch}@example.com';
        const password = 'TestPassword123!';

        UserCredential? credential;

        try {
          credential = await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          final user = credential.user;

          expect(user, isNotNull);
          expect(user!.email, email);
          expect(user.uid, isNotEmpty);

          print('✅ Compte créé');
          print('UID : ${user.uid}');
          print('Email : ${user.email}');
        } finally {
          // Suppression du compte de test.
          await credential?.user?.delete();
        }
      },
    );

    testWidgets(
      'Un utilisateur peut se connecter avec un compte existant',
          (tester) async {
        final email =
            'test_login_${DateTime.now().millisecondsSinceEpoch}@example.com';
        const password = 'TestPassword123!';

        UserCredential? credential;

        try {
          // Création du compte de test.
          credential = await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          await auth.signOut();

          // Connexion.
          final loginCredential =
          await auth.signInWithEmailAndPassword(
            email: email,
            password: password,
          );

          final user = loginCredential.user;

          expect(user, isNotNull);
          expect(user!.email, email);
          expect(auth.currentUser, isNotNull);
          expect(auth.currentUser!.uid, user.uid);

          print('✅ Connexion réussie');
          print('Utilisateur connecté : ${user.email}');
        } finally {
          // L'utilisateur doit être connecté pour être supprimé.
          await auth.currentUser?.delete();
        }
      },
    );

    testWidgets(
      'Un utilisateur peut se déconnecter',
          (tester) async {
        final email =
            'test_logout_${DateTime.now().millisecondsSinceEpoch}@example.com';
        const password = 'TestPassword123!';

        try {
          await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          expect(auth.currentUser, isNotNull);

          await auth.signOut();

          expect(auth.currentUser, isNull);

          print('✅ Déconnexion réussie');
        } catch (e) {
          await auth.currentUser?.delete();
          rethrow;
        }
      },
    );

    testWidgets(
      'Firebase permet de récupérer l utilisateur actuellement connecté',
          (tester) async {
        final email =
            'test_current_user_${DateTime.now().millisecondsSinceEpoch}@example.com';
        const password = 'TestPassword123!';

        try {
          final credential =
          await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          final user = auth.currentUser;

          expect(user, isNotNull);
          expect(user!.uid, credential.user!.uid);
          expect(user.email, email);

          print('✅ Current user récupéré');
          print('UID : ${user.uid}');
        } finally {
          await auth.currentUser?.delete();
        }
      },
    );

    testWidgets(
      'Firebase détecte les changements de session',
          (tester) async {
        final email =
            'test_session_${DateTime.now().millisecondsSinceEpoch}@example.com';
        const password = 'TestPassword123!';

        final states = <User?>[];

        final subscription = auth.authStateChanges().listen(states.add);

        try {
          await auth.signOut();

          // Attendre que le stream reçoive l'état initial.
          await Future<void>.delayed(
            const Duration(milliseconds: 500),
          );

          await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          await Future<void>.delayed(
            const Duration(milliseconds: 500),
          );

          expect(states.any((user) => user != null), isTrue);

          await auth.signOut();

          await Future<void>.delayed(
            const Duration(milliseconds: 500),
          );

          expect(states.any((user) => user == null), isTrue);

          print('✅ authStateChanges fonctionne');
        } finally {
          await subscription.cancel();
          await auth.currentUser?.delete();
        }
      },
    );

    testWidgets(
      'Une erreur est retournée avec un mauvais mot de passe',
          (tester) async {
        final email =
            'test_error_${DateTime.now().millisecondsSinceEpoch}@example.com';
        const password = 'TestPassword123!';

        try {
          await auth.createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

          await auth.signOut();

          expect(
                () => auth.signInWithEmailAndPassword(
              email: email,
              password: 'WrongPassword123!',
            ),
            throwsA(
              isA<FirebaseAuthException>(),
            ),
          );

          print('✅ Erreur Firebase correctement détectée');
        } finally {
          await auth.currentUser?.delete();
        }
      },
    );

    testWidgets(
      'Un mot de passe trop court est refusé',
          (tester) async {
        final email =
            'test_password_${DateTime.now().millisecondsSinceEpoch}@example.com';

        expect(
              () => auth.createUserWithEmailAndPassword(
            email: email,
            password: '123',
          ),
          throwsA(
            isA<FirebaseAuthException>(),
          ),
        );

        print('✅ Mot de passe invalide correctement refusé');
      },
    );
  });
}