# Sticky Teams Firefox Notifications (KDE / Arch Linux)

## 📌 Zweck

Dieses Script + User-Service überwacht Firefox Web-Notifications und erkennt eingehende Nachrichten aus Microsoft Teams (Web-Version).
Teams-Benachrichtigungen werden automatisch als **sticky Desktop-Notifications** erneut gesendet, damit sie nicht übersehen werden.

Die erzeugten Benachrichtigungen erscheinen unter einem eigenen App-Namen (`TeamsWatcher`) und können in KDE separat konfiguriert werden.

---

## ✅ Features

* Überwacht Firefox Desktop Notifications über DBus
* Erkennt Microsoft Teams Web-Benachrichtigungen
* Extrahiert Absender + Nachricht
* Sendet sticky Notification (`critical`, `timeout=0`)
* Eigener App-Name: `TeamsWatcher`
* Eigenes Icon konfigurierbar
* Startmeldung beim Login
* Läuft stabil als systemd User Service
* Automatischer Neustart bei Fehlern
* KDE-Benachrichtigungsregeln möglich

---

## 🧰 Voraussetzungen

* Arch Linux (oder andere systemd-basierte Distros)
* KDE Plasma
* Firefox mit erlaubten Web-Notifications
* Teams Web (`teams.microsoft.com`)
* Pakete:

  * `python`
  * `libnotify` (für notify-send)
  * `dbus`

Installieren falls nötig:

```bash
sudo pacman -S python libnotify
```

---

## ⚙️ Installation

### 1️⃣ Script speichern

```bash
mkdir -p ~/.local/bin
nano ~/.local/bin/sticky-firefox-notify.sh
```

Script-Inhalt einfügen (siehe Script-Datei).

Dann:

```bash
chmod +x ~/.local/bin/sticky-firefox-notify.sh
```

---

### 2️⃣ systemd User Service anlegen

```bash
mkdir -p ~/.config/systemd/user
nano ~/.config/systemd/user/sticky-teams-notify.service
```

```ini
[Unit]
Description=Sticky Teams Firefox Notifications
After=graphical-session.target

[Service]
ExecStart=%h/.local/bin/sticky-firefox-notify.sh
Restart=always
RestartSec=3

[Install]
WantedBy=default.target
```

---

### 3️⃣ Aktivieren

```bash
systemctl --user daemon-reload
systemctl --user enable --now sticky-teams-notify.service
```

---

## 🧪 Test

Script manuell starten:

```bash
~/.local/bin/sticky-firefox-notify.sh
```

Firefox Konsole:

```javascript
new Notification("Test User", { body: "Hallo" })
```

Erwartung:

* KDE Popup erscheint
* Sticky Notification erscheint
* Terminal zeigt `TRIGGER ...`

---

## 🔔 Teams korrekt konfigurieren

### Firefox

* teams.microsoft.com öffnen
* Adressleisten-Symbol → Berechtigungen
* **Benachrichtigungen = Erlauben**

### Teams Web

Einstellungen → Benachrichtigungen:

* Chat = Banner
* Erwähnungen = Banner
* Antworten = Banner

---

## 🎛️ Konfiguration im Script

```bash
ONLY_TEAMS=1
```

| Wert | Verhalten                         |
| ---- | --------------------------------- |
| 0    | Alle Firefox Notifications sticky |
| 1    | Nur Teams sticky                  |

Weitere Parameter:

```
APPNAME="TeamsWatcher"
ICON="mail-message-new"
```

---

## 🖥️ KDE Benachrichtigungsregeln

In KDE:

```
Systemeinstellungen → Benachrichtigungen → Anwendungen
```

App:

```
TeamsWatcher
```

Dort möglich:

* eigener Sound
* immer anzeigen
* Popup erzwingen
* Verlauf speichern
* Priorität überschreiben

---

## 🔍 Debugging

Service Status:

```bash
systemctl --user status sticky-teams-notify.service
```

Live Logs:

```bash
journalctl --user -u sticky-teams-notify.service -f
```

---

## 🛑 Stoppen / Deaktivieren

```bash
systemctl --user stop sticky-teams-notify.service
systemctl --user disable sticky-teams-notify.service
```

---

## ⚠️ Bekannte Einschränkungen

* Funktioniert nur mit Firefox Web-Notifications
* Teams Desktop App wird nicht überwacht
* Notification-Format kann sich bei Teams ändern
* Manche KDE Themes überschreiben Timeout

---

## 🚀 Erweiterungsmöglichkeiten

Möglich:

* nur @Mentions sticky
* Kanalname extrahieren
* Sound pro Absender
* Duplikate unterdrücken
* Notification bündeln
* Action Buttons

