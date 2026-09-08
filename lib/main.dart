import 'package:devcommunitychat/features/profile/presentation/profile_screen.dart';
import "package:flutter/material.dart";
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const ProviderScope(child: DevCommunityChatApp()));
}

class DevCommunityChatApp extends StatelessWidget {
  const DevCommunityChatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DevCommunity Chat',
      home: const ProfileScreen(),
    );
  }
}
