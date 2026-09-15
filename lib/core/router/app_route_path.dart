class AppRoutePath {
  static const String root = "/";

  static const String splashPath = "/splash";
  /// Internal hop after splash: router picks onboarding or login/home.
  static const String bootContinuePath = "/boot";
  static const String onboardingPath = "/onboarding";

  static const String loginPath = "/login";
  static const String homePath = "/home";
  static const String registerPath = "/register";
  static const String profilePath = "/profile";

  // Chat
  static const String chatsPath = "/chats";
  static const String newChatPath = "/new-chat";
  static const String createGroupPath = "/create-group";
  static const String chatDetailPath = "/chats/:chatId";

  static String chatDetail(String chatId) => "/chats/$chatId";

  static bool isAuthRoute(String path) {
    return path == loginPath ||
        path == registerPath ||
        path == root ||
        path == splashPath ||
        path == bootContinuePath ||
        path == onboardingPath;
  }

  static bool isBootRoute(String path) {
    return path == splashPath ||
        path == bootContinuePath ||
        path == onboardingPath;
  }
}
