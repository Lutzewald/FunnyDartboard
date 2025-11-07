import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'utils/game_provider.dart';
import 'screens/main_menu_screen.dart';
import 'l10n/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Set portrait orientation only
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  runApp(const DartBoardApp());
}

class DartBoardApp extends StatelessWidget {
  const DartBoardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => GameProvider(),
      child: MaterialApp(
        title: 'Steeldarts Companion',
        debugShowCheckedModeBanner: false,
        localizationsDelegates: [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en'), // English
          Locale('de'), // German
          Locale('it'), // Italian
          Locale('es'), // Spanish
          Locale('fr'), // French
          Locale('ga'), // Irish
        ],
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.brown,
            brightness: Brightness.dark,
          ),
          useMaterial3: true,
        ),
        home: const MainMenuScreen(),
      ),
    );
  }
}
