class AppRoutePath {
  // la base
  static const String root = "/";

  static const String loginPath = "/login";
  static const String homePath = "/home";
  static const String registerPath = "/register";

  // Route du chat
  static const String chatPath = "/chat";

  static bool isAuthRoute(String path) {
    return path == loginPath ||
        path == registerPath ||
        path == root;
  }
}