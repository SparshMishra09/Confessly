@echo off
echo Building Confessly APK...
echo.

echo Step 1: Cleaning project...
flutter clean
if %errorlevel% neq 0 (
    echo Error: Flutter clean failed
    pause
    exit /b 1
)

echo Step 2: Getting dependencies...
flutter pub get
if %errorlevel% neq 0 (
    echo Error: Flutter pub get failed
    pause
    exit /b 1
)

echo Step 3: Building APK...
flutter build apk --release
if %errorlevel% neq 0 (
    echo Error: APK build failed
    pause
    exit /b 1
)

echo.
echo SUCCESS: APK built successfully!
echo Location: build\app\outputs\flutter-apk\app-release.apk
echo.
pause