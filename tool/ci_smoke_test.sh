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

# Audio must stop when the app goes to the background.
APP_UID=$(adb shell pm list packages -U "$PKG" | sed -n 's/.*uid:\([0-9]*\).*/\1/p' | tr -d '\r')
playing() { adb shell dumpsys audio | grep "u/pid:$APP_UID/" | grep -c "state:started" | tr -d '\r'; }
BEFORE=$(playing)
adb shell input keyevent KEYCODE_HOME
sleep 4
AFTER=$(playing)
echo "Active audio players for uid $APP_UID: foreground=$BEFORE background=$AFTER"
if [ "${BEFORE:-0}" -gt 0 ] && [ "${AFTER:-0}" -gt 0 ]; then
  echo "::error::Audio keeps playing after pressing Home"
  adb logcat -d > logcat.txt
  exit 1
fi
adb shell am start -n "$PKG/.MainActivity" >/dev/null
sleep 3
adb exec-out screencap -p > smoke_3_resumed.png

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
