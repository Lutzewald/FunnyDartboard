# DartBoard - Flutter Portierung

Eine moderne Flutter-Portierung des klassischen Windows Phone Dartspiel-Projekts.

## 📱 Über die App

DartBoard ist eine digitale Dartsscheiben-App mit automatischer Punktezählung für zwei beliebte Dart-Spielmodi:

### Spielmodi

**301 (CountDown)**
- Spieler starten mit 301 Punkten
- Jeder Wurf zieht Punkte ab
- Der erste Spieler, der genau 0 erreicht, gewinnt
- Bei Unterschreitung wird die gesamte Runde annulliert

**Cricket**
- Spieler zielen auf Felder 15-20 und das Bullseye (25)
- Jedes Feld muss 3-mal getroffen werden, um es zu "öffnen"
- Nach dem Öffnen gibt das Treffen des gleichen Feldes Punkte (wenn andere es nicht geschlossen haben)
- Der erste Spieler, der alle Felder öffnet UND die höchste Punktzahl hat, gewinnt

## 🎯 Features

✅ **Zwei Spielmodi**: 301 und Cricket
✅ **Mehrspieler-Unterstützung**: 1-16 Spieler
✅ **Interaktive Dartscheibe**: Tippen Sie zum Werfen auf die Scheibe
✅ **Automatische Treffererkennung**: Berechnet Feld und Multiplikator (Single, Double, Triple)
✅ **Rückgängig-Funktion**: Letzen Wurf rückgängig machen
✅ **Echtzeitpunktezählung**: Alle Spielerpunktzahlen werden live aktualisiert
✅ **Deutsche Benutzeroberfläche**: Alle Texte auf Deutsch
✅ **Custom-painted Dartscheibe**: Keine Bilder erforderlich, perfekt skalierbar

## 🏗️ Projektstruktur

```
lib/
├── game/               # Spiellogik
│   ├── dart_game.dart         # Basis-Dartspiel-Klasse
│   ├── countdown.dart         # 301-Modus
│   ├── cricket.dart           # Cricket-Modus
│   └── score_based_game.dart  # Abstrakte Basis-Klasse
├── models/             # Datenmodelle
│   ├── player.dart            # Spieler-Modell
│   ├── arrow.dart             # Pfeil-Modell
│   └── dart_field.dart        # Dartscheiben-Feld-Modell
├── screens/            # UI-Bildschirme
│   ├── main_menu_screen.dart         # Hauptmenü
│   ├── player_selection_screen.dart  # Spielerauswahl
│   ├── game_screen.dart              # Hauptspielbildschirm
│   └── game_over_screen.dart         # Siegesbildschirm
├── widgets/            # Wiederverwendbare Widgets
│   └── dartboard_painter.dart        # Custom-Paint Dartscheibe
├── utils/              # Hilfsfunktionen
│   ├── game_provider.dart            # State Management
│   └── dartboard_calculator.dart     # Treffererkennung
└── main.dart           # App-Einstiegspunkt
```

## 🚀 Installation und Ausführung

### Voraussetzungen

- Flutter SDK (3.8.1 oder höher)
- Android Studio / Xcode (für mobile Entwicklung)
- Ein Emulator oder physisches Gerät

### Schritte

1. **Abhängigkeiten installieren:**
   ```bash
   flutter pub get
   ```

2. **App ausführen:**
   ```bash
   flutter run
   ```

3. **Für Android erstellen:**
   ```bash
   flutter build apk --release
   ```

4. **Für iOS erstellen:**
   ```bash
   flutter build ios --release
   ```

5. **Für Desktop (Windows):**
   ```bash
   flutter build windows --release
   ```

## 🎮 Spielanleitung

1. **Spielmodus wählen**: Wählen Sie 301 oder Cricket
2. **Spieleranzahl**: Wählen Sie 1-16 Spieler
3. **Spiel starten**: Tippen Sie auf "Start"
4. **Dart werfen**: Tippen Sie auf die Dartscheibe, wo Ihr Dart landen soll
5. **Rückgängig**: Verwenden Sie "Rückgängig", um den letzten Wurf zu korrigieren
6. **Nächster Spieler**: Tippen Sie auf "Nächster", um zum nächsten Spieler zu wechseln

## 🔧 Technische Details

### Architektur

- **State Management**: Provider
- **UI Framework**: Flutter Material Design
- **Geometrische Berechnungen**: Dart Math-Bibliothek
- **Custom Rendering**: CustomPainter für die Dartscheibe

### Treffererkennung

Die App verwendet präzise geometrische Berechnungen:
- **Winkelberechnung**: Bestimmt das Feld basierend auf dem Winkel vom Zentrum
- **Distanzberechnung**: Bestimmt Single/Double/Triple basierend auf der Entfernung
- **Bullseye-Erkennung**: Spezielle Behandlung für den inneren und äußeren Bull

### Spiellogik

- Alle Spielregeln sind in eigenständigen Klassen implementiert
- Immutable-Spielzustände mit Provider für reaktive UI-Updates
- Saubere Trennung zwischen Geschäftslogik und UI

## 🎨 Design

- **Farbschema**: Warme Brauntöne für ein klassisches Dartboard-Ambiente
- **Portrait-Orientierung**: Optimiert für mobile Geräte
- **Responsive Layout**: Funktioniert auf allen Bildschirmgrößen
- **Intuitive Bedienung**: Große, leicht zu treffende Buttons

## 📊 Von C# zu Flutter

### Was wurde portiert:

✅ Alle Spiellogik-Klassen (DartGame, CountDown, Cricket, etc.)
✅ Datenmodelle (Player, Arrow, DartField)
✅ Alle UI-Bildschirme
✅ Touch-Eingabe und Gestensteuerung
✅ Punkteberechnung und -anzeige
✅ Geometrische Treffererkennung
✅ Mehrspieler-Unterstützung
✅ Deutsche Benutzeroberfläche

### Verbesserungen:

🎨 **Custom-gezeichnete Dartscheibe** statt Bilder
📱 **Cross-Platform** läuft auf Android, iOS, Web, Windows, macOS, Linux
🔄 **Modernes State Management** mit Provider
🎯 **Material Design 3** für moderne UI
⚡ **Bessere Performance** durch Flutter-Engine

## 🐛 Bekannte Probleme

- Keine bekannten Probleme

## 🔮 Zukünftige Verbesserungen

- [ ] Statistiken und Spielverlauf
- [ ] Verschiedene Start-Scores (501, 701, etc.)
- [ ] Soundeffekte
- [ ] Animationen beim Treffen
- [ ] Online-Multiplayer
- [ ] Spielerprofile und Namen
- [ ] Checkout-Vorschläge für 301

## 📝 Lizenz

Dieses Projekt ist eine Portierung des ursprünglichen Windows Phone DartBoard-Projekts.

## 🤝 Mitwirkende

Portiert von C# XNA Framework nach Flutter von AI Assistant.

---

**Viel Spaß beim Spielen! 🎯**
