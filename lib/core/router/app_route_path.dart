class AppRoutePath {
  static const String root = "/";

  static const String loginPath = "/login";
  static const String homePath = "/home";
  static const String registerPath = "/register";
  static const String chatsPath = "/chats";
  static const String chatDetailPath = "/chats/:chatId";

  static String chatDetail(String chatId) => "/chats/$chatId";

  static bool isAuthRoute(String path) {
    return path == loginPath ||
        path == registerPath ||
        path == root;
  }
}
