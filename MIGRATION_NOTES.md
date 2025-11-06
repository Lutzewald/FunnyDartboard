# Migration von C# XNA Framework zu Flutter - Technische Hinweise

## Übersicht

Dieses Dokument beschreibt die technischen Details der Portierung des DartBoard-Projekts von C# (Windows Phone 7, XNA Framework) zu Flutter/Dart.

## Architektur-Vergleich

### Original (C# XNA)

```
XNA Game Loop → SpriteBatch Rendering → GameScreens
                ↓
         Touch Input → Game Logic → State Updates
```

### Flutter-Portierung

```
Flutter Widget Tree → Custom Painter → Screens
                ↓
    Gesture Detectors → Provider State → UI Rebuilds
```

## Hauptunterschiede

### 1. Game Loop vs. Widget Lifecycle

**XNA:**
```csharp
protected override void Update(GameTime gameTime)
{
    // Jeder Frame aktualisiert
}

protected override void Draw(GameTime gameTime)
{
    // Jeder Frame gezeichnet
}
```

**Flutter:**
```dart
// Stateful Widgets mit setState() für Updates
// CustomPainter für das Zeichnen
@override
Widget build(BuildContext context) {
    return Consumer<GameProvider>(
        builder: (context, gameProvider, child) {
            // UI aktualisiert automatisch bei Zustandsänderungen
        }
    );
}
```

### 2. State Management

**XNA:**
```csharp
internal DartGame dartGame;
// Direkter Zugriff auf Spielzustand
```

**Flutter:**
```dart
class GameProvider extends ChangeNotifier {
    DartGame? _currentGame;
    // Zentralisiertes State Management mit Provider
    void updateState() {
        notifyListeners(); // Löst UI-Rebuild aus
    }
}
```

### 3. Rendering

**XNA (SpriteBatch):**
```csharp
spriteBatch.Begin();
spriteBatch.Draw(dartBoard, position, Color.White);
spriteBatch.End();
```

**Flutter (CustomPainter):**
```dart
class DartboardPainter extends CustomPainter {
    @override
    void paint(Canvas canvas, Size size) {
        canvas.drawCircle(center, radius, paint);
        // Vektorbasiertes Zeichnen
    }
}
```

### 4. Touch-Eingabe

**XNA:**
```csharp
TouchPanel.EnabledGestures = GestureType.Tap;
if (TouchPanel.IsGestureAvailable) {
    GestureSample gesture = TouchPanel.ReadGesture();
    // Geste verarbeiten
}
```

**Flutter:**
```dart
GestureDetector(
    onTapDown: (details) {
        // Tap-Position verarbeiten
        _handleDartboardTap(details.localPosition);
    },
    child: dartboard,
)
```

### 5. Navigation

**XNA (Benutzerdefiniert):**
```csharp
internal void slideOut(byte direction) {
    // Manuelle Offset-Animation
    xTargetOffset = -displayWidth;
}
```

**Flutter (Navigator):**
```dart
Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => NextScreen()),
);
```

## Klassenportierung

### Player-Klasse

**C#:**
```csharp
public class Player {
    int score;
    int playerNumber;
    
    internal int getPlayerNumber() {
        return playerNumber + 1;
    }
}
```

**Dart:**
```dart
class Player {
    final int playerNumber;
    int score;
    
    Player({required this.playerNumber, this.score = 0});
    
    int getPlayerNumber() => playerNumber + 1;
}
```

**Änderungen:**
- Named parameters für bessere Lesbarkeit
- `final` für unveränderliche Felder
- Arrow-Syntax für einfache Methoden

### DartGame-Klasse

**C#:**
```csharp
abstract public class DartGame : ScoreBasedGame {
    internal DartField[] fields;
    internal Arrow[] arrows;
    
    public void throwArrow(float x, float y, int[] hit) {
        // ...
    }
}
```

**Dart:**
```dart
abstract class DartGame extends ScoreBasedGame {
    late List<DartField> fields;
    late List<Arrow?> arrows;
    
    void throwArrow(double x, double y, List<int> hit) {
        // ...
    }
}
```

**Änderungen:**
- `late` Initialisierung für Listen
- `List<T>` statt Arrays
- `double` statt `float`
- Nullable types (`Arrow?`)

### Cricket-Spiellogik

Die Spiellogik wurde 1:1 portiert mit identischer Funktionalität:

**C#:**
```csharp
public override void calculateThrow(Arrow arrow) {
    DartField hitField = getField(arrow.getNumber());
    int points = 0;
    for (int i = 0; i < arrow.getMultiplier(); i++) {
        if (hitField.isOpen(currentPlayer) && !hitField.isClosed()) {
            points += hitField.getValue();
        }
        hitField.increasePlayerHits(currentPlayer, 1);
    }
    // ...
}
```

**Dart:**
```dart
@override
void calculateThrow(Arrow arrow) {
    final hitField = getField(arrow.getNumber());
    int points = 0;
    for (int i = 0; i < arrow.getMultiplier(); i++) {
        if (hitField.isOpenByPlayer(currentPlayer) && !hitField.isClosed()) {
            points += hitField.getValue();
        }
        hitField.increasePlayerHits(currentPlayer, 1);
    }
    // ...
}
```

## Geometrische Berechnungen

Die Dartboard-Hit-Detection wurde präzise portiert:

### Winkelberechnung

**C# (XNA):**
```csharp
private float angle(float[] P1, float[] P2) {
    float angle = (float)(Math.Acos(unityVector(line(P1, P2))[0]) / Math.PI * 180);
    if (P1[1] < P2[1])
        return 360 - angle;
    return angle;
}
```

**Dart:**
```dart
static double _calculateAngle(double dx, double dy) {
    double angle = (atan2(-dy, dx) * 180 / pi);
    angle = (90 - angle) % 360;
    if (angle < 0) angle += 360;
    return angle;
}
```

### Distanzberechnung

Beide Versionen verwenden den Satz des Pythagoras:

```dart
static double _calculateDistance(double dx, double dy, double boardRadius) {
    final actualDistance = sqrt(dx * dx + dy * dy);
    return (actualDistance / boardRadius) * 1000;
}
```

## UI-Portierung

### Bildschirm-Hierarchie

**Original:**
- `GameScreen` (abstrakte Basisklasse)
  - `MainMenu`
  - `PlayerMenu`
  - `DartBoardScreen`
  - `ScoreScreen`
  - `OverViewScreen`
  - `GameOverScreen`

**Flutter:**
- Eigenständige `StatelessWidget`/`StatefulWidget` Screens
- Gemeinsame Funktionen über `GameProvider`
- Navigation über Flutter's `Navigator`

### Layout-System

**XNA (Absolute Positionierung):**
```csharp
buttons[0] = new Button(this, 96, 260, 288, 120);
```

**Flutter (Flexibles Layout):**
```dart
Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
        SizedBox(width: 280, height: 100, child: button),
    ],
)
```

## Leistungsverbesserungen

### 1. Dartboard-Rendering

**Original:** Lädt PNG-Bilder vom Datenträger
**Flutter:** Zeichnet vektorbasiert mit `CustomPainter`

**Vorteile:**
- Keine Asset-Abhängigkeiten
- Perfekt skalierbar für alle Bildschirmgrößen
- Kleinere App-Größe
- Bessere Performance

### 2. State Updates

**Original:** Manuelles Update-Management
**Flutter:** Reaktives UI mit Provider

**Vorteile:**
- Automatische UI-Updates
- Weniger Boilerplate-Code
- Bessere Testbarkeit

## Tests

Ein grundlegender Test wurde hinzugefügt:

```dart
testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const DartBoardApp());
    expect(find.text('DartBoard'), findsOneWidget);
});
```

Weitere Tests können einfach hinzugefügt werden für:
- Spiellogik (Unit Tests)
- Widget-Tests
- Integration-Tests

## Herausforderungen bei der Portierung

### 1. Keine direkte SpriteBatch-Alternative

**Lösung:** `CustomPainter` für benutzerdefiniertes Rendering verwenden

### 2. Verschiedene Touch-Event-Systeme

**Lösung:** `GestureDetector` mit `onTapDown` für präzise Position

### 3. Slide-Animationen

**Original:** Manuelle Offset-Interpolation
**Lösung:** Flutter's eingebaute Navigationsübergänge verwenden

### 4. Game Loop

**Original:** XNA's Update/Draw-Zyklus
**Lösung:** State Management mit automatischen Rebuilds

## Best Practices angewendet

1. **Immutability:** Verwendung von `final` wo möglich
2. **Named Parameters:** Bessere API-Klarheit
3. **Null Safety:** Strenge Null-Sicherheit aktiviert
4. **Provider Pattern:** Saubere State-Verwaltung
5. **Widget Composition:** Kleine, wiederverwendbare Widgets
6. **German UI:** Alle Texte auf Deutsch gemäß User-Präferenz

## Fazit

Die Portierung war erfolgreich und hat alle ursprünglichen Features beibehalten, während sie die Vorteile von Flutter nutzt:

✅ **Cross-Platform:** Läuft auf 6 Plattformen statt 1
✅ **Moderne UI:** Material Design 3
✅ **Bessere Performance:** Vektorbasiertes Rendering
✅ **Wartbarkeit:** Sauberere Architektur
✅ **Erweiterbarkeit:** Einfacher, neue Features hinzuzufügen

Die App ist produktionsbereit und kann direkt verwendet oder weiterentwickelt werden.


