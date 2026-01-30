#!/usr/bin/env bash
set -euo pipefail

# ============ CONFIG ============
# 1 = nur Teams/Microsoft Notifications
# 0 = alle Firefox Web Notifications
ONLY_TEAMS=1
APPNAME="TeamsWatcher"
ICON="mail-message-new"
# ================================

# Startmeldung beim Login/Start
notify-send -a "$APPNAME" -u low "Teams Watcher" "läuft jetzt"

python3 - "$ONLY_TEAMS" "$APPNAME" "$ICON" <<'PY'
import re, sys, subprocess

only_teams = int(sys.argv[1])
appname = sys.argv[2]
icon = sys.argv[3]

cmd = [
    "dbus-monitor",
    "--session",
    "type='method_call',interface='org.freedesktop.Notifications',member='Notify'"
]

p = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.DEVNULL, text=True)

string_re = re.compile(r'^\s*string "([^"]*)"')

collecting = False
block_strings = []

def flush():
    global block_strings
    if not block_strings:
        return

    app = block_strings[0] if len(block_strings) >= 1 else ""
    summary = block_strings[3] if len(block_strings) >= 4 else ""
    body = block_strings[4] if len(block_strings) >= 5 else ""
    block_strings = []

    # Nur Firefox-origin
    if not re.search(r'(firefox|org\.mozilla\.firefox)', app, re.I):
        return

    text = (summary + "\n" + body).lower()

    # Optional: nur Teams
    if only_teams and not re.search(r'(teams|microsoft|teams\.microsoft\.com)', text):
        return

    sender = summary.strip() if summary else "Unbekannt"
    message = body.strip() if body else ""

    title = f"Teams — {sender}"

    # Debug
    print(f"TRIGGER sender={sender} | body={message}", file=sys.stderr)

    subprocess.run(
        [
            "notify-send",
            "-a", appname,
            "-u", "critical",
            "-t", "0",
            "-i", icon,
            title,
            message
        ],
        check=False
    )

for line in p.stdout:
    if "member=Notify" in line:
        collecting = True
        block_strings = []
        continue

    if collecting:
        m = string_re.match(line)
        if m:
            block_strings.append(m.group(1))

        if re.match(r'^\s*\)\s*$', line):
            collecting = False
            flush()
PY
