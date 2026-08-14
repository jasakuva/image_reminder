@echo on
setlocal
cd /d %~dp0

set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
set "PATH=%JAVA_HOME%\bin;%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools;%PATH%"
set "ADB=%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools\adb.exe"
set "APP_VERSION=1.0.0"
set "BUILD_NUMBER=1"
for /f %%i in ('git rev-parse --short HEAD') do set "GIT_COMMIT=%%i"
for /f %%i in ('powershell -NoProfile -Command "Get-Date -Format yyyy-MM-dd"') do set "BUILD_DATE=%%i"

echo.
echo ========================================
echo Picture Reminder Android deploy
echo ========================================
echo Project: %CD%
echo JAVA_HOME: %JAVA_HOME%
echo Version: %APP_VERSION%+%BUILD_NUMBER%
echo Build date: %BUILD_DATE%
echo Commit: %GIT_COMMIT%
echo.

echo Checking connected Android devices...
"%ADB%" devices
if errorlevel 1 goto adb_failed

echo.
echo Building debug APK...
flutter build apk --debug ^
  --dart-define=APP_VERSION=%APP_VERSION% ^
  --dart-define=BUILD_NUMBER=%BUILD_NUMBER% ^
  --dart-define=BUILD_DATE=%BUILD_DATE% ^
  --dart-define=GIT_COMMIT=%GIT_COMMIT%
if errorlevel 1 goto build_failed

if not exist "build\app\outputs\flutter-apk\app-debug.apk" goto apk_missing

echo.
echo Installing APK to connected phone...
"%ADB%" install -r "build\app\outputs\flutter-apk\app-debug.apk"
if errorlevel 1 goto install_failed

echo.
echo Starting app on phone...
"%ADB%" shell am start -n com.example.pic_reminder/.MainActivity

echo.
echo ========================================
echo Installed and started successfully.
echo ========================================
pause
exit /b 0

:adb_failed
echo.
echo ERROR: ADB failed. Check that USB debugging is enabled and phone is authorized.
pause
exit /b 1

:build_failed
echo.
echo ERROR: Flutter APK build failed.
pause
exit /b 1

:apk_missing
echo.
echo ERROR: APK file was not found after build.
pause
exit /b 1

:install_failed
echo.
echo ERROR: APK install failed. Check phone screen for permission/authorization prompts.
pause
exit /b 1
