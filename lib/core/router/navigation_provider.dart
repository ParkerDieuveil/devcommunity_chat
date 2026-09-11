import 'package:flutter_riverpod/flutter_riverpod.dart';

enum MainTab { chat, profile }

final mainTabProvider = NotifierProvider<MainTabNotifier, MainTab>(
  MainTabNotifier.new,
);

class MainTabNotifier extends Notifier<MainTab> {
  @override
  MainTab build() {
    return MainTab.chat;
  }

  void selectTab(MainTab tab) {
    state = tab;
  }
}
