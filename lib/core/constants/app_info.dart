abstract final class AppInfo {
  static const String name = 'DevCommunity Chat';
  static const String version = '1.0.0';
  static const String buildNumber = '1';

  static String get versionLabel => 'v$version';

  static String get buildLabel => 'Build $version+$buildNumber';
}
