#!/usr/bin/env bash
# Installs the APK on the CI emulator, launches it, and checks it survives.
# Leaves logcat.txt and smoke_*.png behind for debugging.
set -u
PKG=com.floppyswing.floppy_swing

# Every adb call gets a timeout: if the emulator dies, adb would otherwise
# wait for a device forever and the job would hang until GitHub kills it.
a() { timeout 60 adb "$@"; }

emulator_alive() {
  if [ "$(timeout 15 adb get-state 2>/dev/null | tr -d '\r')" != "device" ]; then
    echo "::error::The emulator went offline during the test ($1). This is an emulator/CI problem, not an app crash; see logcat.txt for what the app logged before."
    exit 2
  fi
}

a install -r FloppySwing.apk
a logcat -c
# Stream logcat to a file the whole time, so there's a log even if the
# emulator dies mid-test.
timeout 600 adb logcat > logcat.txt 2>/dev/null &
LOGCAT_PID=$!
trap 'kill $LOGCAT_PID 2>/dev/null' EXIT
a shell am start -W -n "$PKG/.MainActivity"
sleep 25
emulator_alive "after launch"
a exec-out screencap -p > smoke_1_launch.png

# Poke around: tap the middle-lower screen (PLAY on the menu).
read -r W H < <(a shell wm size | awk -F'[ x]' '/Physical/ {print $3, $4}')
a shell input tap $((${W:-1080} / 2)) $((${H:-2400} * 72 / 100))
sleep 4
emulator_alive "after tapping PLAY"
a exec-out screencap -p > smoke_2_after_tap.png

# Audio must stop when the app goes to the background.
APP_UID=$(a shell pm list packages -U "$PKG" | sed -n 's/.*uid:\([0-9]*\).*/\1/p' | tr -d '\r')
playing() { a shell dumpsys audio | grep "u/pid:$APP_UID/" | grep -c "state:started" | tr -d '\r'; }
BEFORE=$(playing)
a shell input keyevent KEYCODE_HOME
sleep 4
emulator_alive "after pressing Home"
AFTER=$(playing)
echo "Active audio players for uid $APP_UID: foreground=$BEFORE background=$AFTER"
if [ "${BEFORE:-0}" -gt 0 ] && [ "${AFTER:-0}" -gt 0 ]; then
  echo "::error::Audio keeps playing after pressing Home"
  exit 1
fi
a shell am start -n "$PKG/.MainActivity" >/dev/null
sleep 3
emulator_alive "after returning to the app"
a exec-out screencap -p > smoke_3_resumed.png

PID=$(a shell pidof "$PKG" | tr -d '\r')
CRASH_DIALOG=$(a shell dumpsys window | grep -c "Application Error: $PKG")
echo "---- crash / flutter log ----"
grep -E "FATAL|AndroidRuntime|E flutter|I flutter|Exception|Error|DEBUG   :|signal [0-9]+" logcat.txt | grep -v "GoogleApiManager\|chromium" | tail -150
if grep -q "FATAL EXCEPTION" logcat.txt && grep -A2 "FATAL EXCEPTION" logcat.txt | grep -q "$PKG"; then
  echo "::error::App crashed (FATAL EXCEPTION in logcat)"
  exit 1
fi
if [ "${CRASH_DIALOG:-0}" -gt 0 ]; then
  echo "::error::App crashed (crash dialog is showing)"
  exit 1
fi
if [ -z "$PID" ]; then
  echo "::error::App is not running after launch (crashed)"
  exit 1
fi
echo "App is running (pid $PID)"
