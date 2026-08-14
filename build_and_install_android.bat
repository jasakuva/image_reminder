@echo on
setlocal
cd /d %~dp0

set "JAVA_HOME=C:\Program Files\Android\Android Studio\jbr"
set "PATH=%JAVA_HOME%\bin;%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools;%PATH%"
set "ADB=%USERPROFILE%\AppData\Local\Android\Sdk\platform-tools\adb.exe"

echo.
echo ========================================
echo Picture Reminder Android deploy
echo ========================================
echo Project: %CD%
echo JAVA_HOME: %JAVA_HOME%
echo.

echo Checking connected Android devices...
"%ADB%" devices
if errorlevel 1 goto adb_failed

echo.
echo Building debug APK...
flutter build apk --debug
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
