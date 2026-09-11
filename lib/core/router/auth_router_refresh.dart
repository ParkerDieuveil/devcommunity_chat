import 'package:flutter/foundation.dart';

/// Notifie GoRouter quand la session Riverpod change (login / logout).
/// Pas d'abonnement Firebase ici : le refresh est branché via ref.listen.
class AuthRouterRefresh extends ChangeNotifier {
  void notify() => notifyListeners();
}
