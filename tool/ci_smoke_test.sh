#!/usr/bin/env bash
# Installs the APK on the CI emulator, launches it, and checks it survives.
# Leaves logcat.txt and smoke_*.png behind for debugging.
set -u
PKG=com.floppyswing.floppy_swing

adb install -r FloppySwing.apk
adb logcat -c
adb shell am start -W -n "$PKG/.MainActivity"
sleep 25
adb exec-out screencap -p > smoke_1_launch.png

# Poke around: tap the middle-lower screen (PLAY on the menu), then hold.
read -r W H < <(adb shell wm size | awk -F'[ x]' '/Physical/ {print $3, $4}')
adb shell input tap $((W / 2)) $((H * 72 / 100))
sleep 4
adb exec-out screencap -p > smoke_2_after_tap.png

PID=$(adb shell pidof "$PKG" | tr -d '\r')
adb logcat -d > logcat.txt
echo "---- crash / flutter log ----"
grep -E "FATAL|AndroidRuntime|E flutter|I flutter|Exception|Error|DEBUG   :|signal [0-9]+" logcat.txt | grep -v "GoogleApiManager\|chromium" | tail -150
if grep -q "FATAL EXCEPTION" logcat.txt && grep -A2 "FATAL EXCEPTION" logcat.txt | grep -q "$PKG"; then
  echo "::error::App crashed (FATAL EXCEPTION in logcat)"
  exit 1
fi
if adb shell dumpsys window | grep -q "Application Error: $PKG"; then
  echo "::error::App crashed (crash dialog is showing)"
  exit 1
fi
if [ -z "$PID" ]; then
  echo "::error::App is not running after launch (crashed)"
  exit 1
fi
echo "App is running (pid $PID)"
