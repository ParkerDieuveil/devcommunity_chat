import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/chat_provider.dart';

/// Présence réelle : online/offline selon session + cycle de vie de l'app.
///
/// Pas de mock : écrit `users/{uid}.isOnline` / `lastSeen` dans Firestore.
/// Heartbeat pour éviter les faux « en ligne » après un crash.
class PresenceLifecycle extends ConsumerStatefulWidget {
  const PresenceLifecycle({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<PresenceLifecycle> createState() => _PresenceLifecycleState();
}

class _PresenceLifecycleState extends ConsumerState<PresenceLifecycle>
    with WidgetsBindingObserver {
  Timer? _heartbeat;
  static const _heartbeatEvery = Duration(seconds: 45);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = ref.read(currentUserProvider)?.id;
      if (uid != null) _goOnline(uid);
    });
  }

  @override
  void dispose() {
    _heartbeat?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final uid = ref.read(currentUserProvider)?.id;
    if (uid == null) return;

    switch (state) {
      case AppLifecycleState.resumed:
        _goOnline(uid);
      case AppLifecycleState.inactive:
        // Transitions iOS (notif, multitâche) : on ne coupe pas tout de suite.
        break;
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
      case AppLifecycleState.detached:
        _goOffline(uid);
    }
  }

  void _goOnline(String uid) {
    _heartbeat?.cancel();
    _heartbeat = Timer.periodic(_heartbeatEvery, (_) {
      unawaited(_writeOnline(uid));
    });
    unawaited(_writeOnline(uid));
  }

  void _goOffline(String uid) {
    _heartbeat?.cancel();
    _heartbeat = null;
    unawaited(_writeOffline(uid));
  }

  Future<void> _writeOnline(String uid) async {
    try {
      await ref.read(userProfileRepositoryProvider).setUserOnline(uid);
    } catch (_) {
      // best-effort
    }
  }

  Future<void> _writeOffline(String uid) async {
    try {
      await ref.read(userProfileRepositoryProvider).setUserOffline(uid);
    } catch (_) {
      // best-effort
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(currentUserProvider, (previous, next) {
      final prevId = previous?.id;
      final nextId = next?.id;
      if (nextId != null && nextId != prevId) {
        _goOnline(nextId);
      } else if (nextId == null && prevId != null) {
        _heartbeat?.cancel();
        _heartbeat = null;
        // Offline déjà géré par AuthController.logout.
      }
    });

    return widget.child;
  }
}
