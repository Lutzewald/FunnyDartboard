import 'package:dartboard_flutter/l10n/app_localizations.dart';
import 'package:dartboard_flutter/screens/game_screen.dart';
import 'package:dartboard_flutter/utils/game_provider.dart';
import 'package:dartboard_flutter/widgets/dartboard_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'finishes appear between scores and board and disappear after a miss',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});
      final provider = GameProvider();
      await tester.pump();
      provider.startGame();
      provider.currentGame!.currentPlayer.setScore(170);

      await tester.pumpWidget(
        ChangeNotifierProvider.value(
          value: provider,
          child: const MaterialApp(
            locale: Locale('en'),
            localizationsDelegates: [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            home: GameScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Finishing paths'), findsOneWidget);
      final route = find.text('T20 → T20 → D25');
      expect(route, findsOneWidget);
      final board = find.byWidgetPredicate(
        (widget) => widget is CustomPaint && widget.painter is DartboardPainter,
      );
      expect(
        tester.getBottomLeft(find.text('170')).dy,
        lessThan(tester.getTopLeft(route).dy),
      );
      expect(
        tester.getBottomLeft(route).dy,
        lessThanOrEqualTo(tester.getTopLeft(board).dy),
      );
      expect(tester.takeException(), isNull);

      provider.throwDart(0, 0, [1, 0]);
      await tester.pump();
      expect(find.text('Finishing paths'), findsNothing);
      provider.undoLastThrow();
      await tester.pump();
      expect(route, findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      provider.dispose();
    },
  );
}
