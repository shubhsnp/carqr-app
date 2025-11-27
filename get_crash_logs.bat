@echo off
echo Capturing crash logs from Android device...
echo.
echo Make sure your phone is connected via USB with debugging enabled!
echo.
pause

echo Clearing old logs...
adb logcat -c

echo.
echo Starting logcat... Press Ctrl+C to stop
echo Filtering for CarQR app crashes...
echo.

adb logcat -v time | findstr /i "carqr AndroidRuntime FATAL flutter"
