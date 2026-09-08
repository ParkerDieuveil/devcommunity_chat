import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AuthRouterRefresh extends ChangeNotifier {
  AuthRouterRefresh(FirebaseAuth auth) {
    _subscription = auth.authStateChanges().listen(
          (_) => notifyListeners(),
    );
  }

  late final StreamSubscription<User?> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}