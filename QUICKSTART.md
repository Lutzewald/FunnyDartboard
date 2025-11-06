# 🚀 Schnellstart-Anleitung

## Sofort loslegen

### 1. App starten (empfohlen: Chrome/Edge für Web)

```bash
flutter run -d chrome
```

**Oder für Windows Desktop:**
```bash
flutter run -d windows
```

**Oder für Android (mit angeschlossenem Gerät/Emulator):**
```bash
flutter run
```

### 2. Erste Schritte in der App

1. **Hauptmenü:** Wählen Sie "301" oder "Cricket"
2. **Spieleranzahl:** Wählen Sie 2 Spieler (Standard) oder mehr/weniger
3. **Start:** Tippen Sie auf "Start"
4. **Spielen:** Tippen Sie auf die Dartscheibe, um Pfeile zu werfen
5. **Weiter:** Nach 3 Würfen, tippen Sie auf "Nächster"

## 🎯 Verfügbare Befehle

| Befehl | Beschreibung |
|--------|--------------|
| `flutter run` | App im Debug-Modus starten |
| `flutter run -d chrome` | In Chrome/Edge ausführen (Web) |
| `flutter run -d windows` | Als Windows-Desktop-App |
| `flutter build apk` | Android APK erstellen |
| `flutter build windows` | Windows .exe erstellen |
| `flutter analyze` | Code-Analyse |
| `flutter test` | Tests ausführen |

## 🔧 Entwicklung

### Hot Reload während der Entwicklung

Wenn die App läuft, drücken Sie:
- **`r`** - Hot Reload (schnelle Änderungen)
- **`R`** - Hot Restart (vollständiger Neustart)
- **`q`** - Beenden

### Projektstruktur verstehen

```
lib/
├── main.dart              # ← App-Start
├── game/                  # ← Spiellogik (301, Cricket)
├── models/                # ← Datenmodelle (Player, Arrow)
├── screens/               # ← UI-Bildschirme
├── widgets/               # ← Wiederverwendbare UI-Komponenten
└── utils/                 # ← Hilfsfunktionen, State Management
```

## 💡 Tipps

### Für die beste Erfahrung:

1. **Web-Version (Chrome):**
   - Schnellster Start
   - Keine Android SDK erforderlich
   - Perfekt zum Testen

2. **Windows Desktop:**
   - Native Performance
   - Keine Internetverbindung erforderlich

3. **Android:**
   - Touchscreen-optimiert
   - Beste mobile Erfahrung

### Fehlersuche

**Problem:** "No devices found"
- **Lösung:** Starten Sie mit `-d chrome` für Web

**Problem:** "Android SDK not found"
- **Lösung:** Verwenden Sie `-d chrome` oder `-d windows`

**Problem:** "Plugin not found"
- **Lösung:** `flutter pub get` ausführen

## 📱 Spielanleitung

### 301-Modus:
- Starten mit 301 Punkten
- Runterwerfen bis exakt 0
- Bei Überwurf: Runde ungültig

### Cricket-Modus:
- Felder 15-20 und Bull öffnen (3x treffen)
- Nach Öffnung: Punkte sammeln
- Alle Felder öffnen + höchste Punktzahl = Sieg

### Steuerung:
- **Tippen:** Dart werfen
- **Rückgängig:** Letzten Wurf korrigieren
- **Nächster:** Nächster Spieler
- **Zurück-Taste:** Pause-Menü

## 🎨 Anpassung

### Farben ändern:

`lib/main.dart`:
```dart
colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.brown,  // ← Hier ändern
    brightness: Brightness.dark,
),
```

### Start-Score ändern (301 → 501):

`lib/screens/player_selection_screen.dart`:
```dart
CountDown(
    numberOfPlayers: _numberOfPlayers,
    startScore: 501,  // ← Hier ändern
);
```

### Sprache ändern:

Alle deutschen Texte sind direkt in den Screens.
Suchen und ersetzen Sie z.B. "Spieler" durch "Player".

## 🚀 Produktionsbereitschaft

### Release-Build erstellen:

**Android:**
```bash
flutter build apk --release
# → build/app/outputs/flutter-apk/app-release.apk
```

**Windows:**
```bash
flutter build windows --release
# → build\windows\x64\runner\Release\
```

**Web:**
```bash
flutter build web --release
# → build/web/
```

## 📞 Weitere Hilfe

- **Flutter Docs:** https://docs.flutter.dev
- **Dart Docs:** https://dart.dev
- **README.md:** Vollständige Projektdokumentation
- **MIGRATION_NOTES.md:** Technische Details der Portierung

---

**Viel Erfolg! 🎯🎉**


