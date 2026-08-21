class AppBuildInfo {
  const AppBuildInfo._();

  static const appName = 'ImageReminder';
  static const softwareName = 'JASAPART image reminder software';
  static const version = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );
  static const buildNumber = String.fromEnvironment(
    'BUILD_NUMBER',
    defaultValue: '1',
  );
  static const buildDate = String.fromEnvironment(
    'BUILD_DATE',
    defaultValue: '2026-08-21',
  );
  static const commit = String.fromEnvironment(
    'GIT_COMMIT',
    defaultValue: 'Local changes',
  );
}
