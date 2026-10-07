import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'en': _en,
    'de': _de,
    'it': _it,
    'es': _es,
    'fr': _fr,
    'ga': _ga, // Irish
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? 
           _localizedValues['en']?[key] ?? 
           key;
  }

  // Getters for all translatable strings
  String get appName => 'Steeldarts Companion';
  
  // Main Menu
  String get start => translate('start');
  String get donation => translate('donation');
  
  // Game Modes
  String get mode301 => translate('mode301');
  String get mode501 => translate('mode501');
  String get modeCricket => translate('modeCricket');
  String get modeShanghai => translate('modeShanghai');
  
  // Player Selection
  String get activePlayers => translate('activePlayers');
  String get pause => translate('pause');
  String get addPlayer => translate('addPlayer');
  String get editName => translate('editName');
  String get enterName => translate('enterName');
  String get save => translate('save');
  String get cancel => translate('cancel');
  String get remove => translate('remove');
  String get removePlayerQuestion => translate('removePlayerQuestion');
  String get reallyRemove => translate('reallyRemove');
  
  // Pause Reasons
  String get pauseBeer => translate('pauseBeer');
  String get pauseToilet => translate('pauseToilet');
  String get pauseSmoke => translate('pauseSmoke');
  String get pauseSick => translate('pauseSick');
  String get pauseLove => translate('pauseLove');
  String get backToGame => translate('backToGame');
  
  // Countdown Options
  String get gameRules => translate('gameRules');
  String get entry => translate('entry');
  String get exit => translate('exit');
  String get straight => translate('straight');
  String get double => translate('double');
  String get triple => translate('triple');
  String get master => translate('master');
  String get startGame => translate('startGame');
  
  // Game Screen
  String get back => translate('back');
  String get undo => translate('undo');
  String get next => translate('next');
  String get continue_ => translate('continue');
  String get finishingPaths => translate('finishingPaths');
  
  // Detailed Score
  String get score => translate('score');
  String get round => translate('round');
  String get target => translate('target');
  String get currentTarget => translate('currentTarget');
  String get quitGame => translate('quitGame');
  String get quitGameQuestion => translate('quitGameQuestion');
  String get quitGameWarning => translate('quitGameWarning');
  String get quit => translate('quit');
  
  // Game Over
  String get gameOver => translate('gameOver');
  String get winner => translate('winner');
  String get mainMenu => translate('mainMenu');
  
  // General
  String get yes => translate('yes');
  String get no => translate('no');
  String get ok => translate('ok');
  String get close => translate('close');
  String get edit => translate('edit');
  String get finalScore => translate('finalScore');
  String get exitDialogMessage => translate('exitDialogMessage');
  
  // URL errors
  String get linkCouldNotBeOpened => translate('linkCouldNotBeOpened');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'de', 'it', 'es', 'fr', 'ga'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

// English (fallback)
const Map<String, String> _en = {
  'finishingPaths': 'Finishing paths',
  'start': 'Start',
  'donation': 'Donation',
  'mode301': '301',
  'mode501': '501',
  'modeCricket': 'Cricket',
  'modeShanghai': 'Shanghai',
  'activePlayers': 'Active Players',
  'pause': 'Pause',
  'addPlayer': 'Add Player',
  'editName': 'Edit Name',
  'enterName': 'Enter name',
  'save': 'Save',
  'cancel': 'Cancel',
  'remove': 'Remove',
  'removePlayerQuestion': 'Remove Player',
  'reallyRemove': 'Do you really want to remove',
  'pauseBeer': '🍺 Beer',
  'pauseToilet': '🚽 Toilet',
  'pauseSmoke': '🚬 Smoke',
  'pauseSick': '🤮 Sick',
  'pauseLove': '❤️ Love',
  'backToGame': 'Back to game',
  'gameRules': 'Game Rules',
  'entry': 'Entry',
  'exit': 'Exit',
  'straight': 'Straight',
  'double': 'Double',
  'triple': 'Triple',
  'master': 'Master',
  'startGame': 'Start Game',
  'back': 'Back',
  'undo': 'Undo',
  'next': 'Next',
  'continue': 'Continue',
  'score': 'Score',
  'round': 'Round',
  'target': 'Target',
  'currentTarget': 'Current Target',
  'quitGame': 'Quit Game',
  'quitGameQuestion': 'Quit Game?',
  'quitGameWarning': 'Do you really want to quit the game and return to the main menu? The current game will be lost.',
  'quit': 'Quit',
  'gameOver': 'Game Over',
  'winner': 'Winner',
  'mainMenu': 'Main Menu',
  'yes': 'Yes',
  'no': 'No',
  'ok': 'OK',
  'close': 'Close',
  'edit': 'Edit',
  'finalScore': 'Final Score',
  'exitDialogMessage': 'Do you really want to return to the main menu?',
  'linkCouldNotBeOpened': 'Link could not be opened',
};

// German
const Map<String, String> _de = {
  'finishingPaths': 'Finish-Wege',
  'start': 'Start',
  'donation': 'Spende',
  'mode301': '301',
  'mode501': '501',
  'modeCricket': 'Cricket',
  'modeShanghai': 'Shanghai',
  'activePlayers': 'Aktive Spieler',
  'pause': 'Pause',
  'addPlayer': 'Spieler hinzufügen',
  'editName': 'Namen bearbeiten',
  'enterName': 'Name eingeben',
  'save': 'Speichern',
  'cancel': 'Abbrechen',
  'remove': 'Entfernen',
  'removePlayerQuestion': 'Spieler entfernen',
  'reallyRemove': 'Möchten Sie',
  'pauseBeer': '🍺 Bier',
  'pauseToilet': '🚽 WC',
  'pauseSmoke': '🚬 Rauchen',
  'pauseSick': '🤮 Kotzen',
  'pauseLove': '❤️ Liebe',
  'backToGame': 'Zurück zum Spiel',
  'gameRules': 'Spielregeln',
  'entry': 'Einstieg',
  'exit': 'Ausstieg',
  'straight': 'Straight',
  'double': 'Double',
  'triple': 'Triple',
  'master': 'Master',
  'startGame': 'Spiel starten',
  'back': 'Zurück',
  'undo': 'Zurück',
  'next': 'Nächster',
  'continue': 'Weiter',
  'score': 'Spielstand',
  'round': 'Runde',
  'target': 'Ziel',
  'currentTarget': 'Aktuelles Ziel',
  'quitGame': 'Spiel beenden',
  'quitGameQuestion': 'Spiel beenden?',
  'quitGameWarning': 'Möchten Sie wirklich das Spiel beenden und zum Hauptmenü zurückkehren? Der aktuelle Spielstand geht verloren.',
  'quit': 'Beenden',
  'gameOver': 'Spiel vorbei',
  'winner': 'Gewinner',
  'mainMenu': 'Hauptmenü',
  'yes': 'Ja',
  'no': 'Nein',
  'ok': 'OK',
  'close': 'Schließen',
  'edit': 'Bearbeiten',
  'finalScore': 'Endstand',
  'exitDialogMessage': 'Möchten Sie wirklich zum Hauptmenü zurückkehren?',
  'linkCouldNotBeOpened': 'Link konnte nicht geöffnet werden',
};

// Italian
const Map<String, String> _it = {
  'finishingPaths': 'Percorsi di chiusura',
  'start': 'Inizia',
  'donation': 'Donazione',
  'mode301': '301',
  'mode501': '501',
  'modeCricket': 'Cricket',
  'modeShanghai': 'Shanghai',
  'activePlayers': 'Giocatori Attivi',
  'pause': 'Pausa',
  'addPlayer': 'Aggiungi Giocatore',
  'editName': 'Modifica Nome',
  'enterName': 'Inserisci nome',
  'save': 'Salva',
  'cancel': 'Annulla',
  'remove': 'Rimuovi',
  'removePlayerQuestion': 'Rimuovi Giocatore',
  'reallyRemove': 'Vuoi davvero rimuovere',
  'pauseBeer': '🍺 Birra',
  'pauseToilet': '🚽 Bagno',
  'pauseSmoke': '🚬 Fumare',
  'pauseSick': '🤮 Malato',
  'pauseLove': '❤️ Amore',
  'backToGame': 'Torna al gioco',
  'gameRules': 'Regole del Gioco',
  'entry': 'Entrata',
  'exit': 'Uscita',
  'straight': 'Dritto',
  'double': 'Doppio',
  'triple': 'Triplo',
  'master': 'Master',
  'startGame': 'Inizia Partita',
  'back': 'Indietro',
  'undo': 'Annulla',
  'next': 'Prossimo',
  'continue': 'Continua',
  'score': 'Punteggio',
  'round': 'Round',
  'target': 'Obiettivo',
  'currentTarget': 'Obiettivo Attuale',
  'quitGame': 'Esci dal Gioco',
  'quitGameQuestion': 'Esci dal Gioco?',
  'quitGameWarning': 'Vuoi davvero uscire dal gioco e tornare al menu principale? La partita attuale andrà persa.',
  'quit': 'Esci',
  'gameOver': 'Partita Finita',
  'winner': 'Vincitore',
  'mainMenu': 'Menu Principale',
  'yes': 'Sì',
  'no': 'No',
  'ok': 'OK',
  'close': 'Chiudi',
  'edit': 'Modifica',
  'finalScore': 'Punteggio Finale',
  'exitDialogMessage': 'Vuoi davvero tornare al menu principale?',
  'linkCouldNotBeOpened': 'Il link non può essere aperto',
};

// Spanish
const Map<String, String> _es = {
  'finishingPaths': 'Rutas de cierre',
  'start': 'Comenzar',
  'donation': 'Donación',
  'mode301': '301',
  'mode501': '501',
  'modeCricket': 'Cricket',
  'modeShanghai': 'Shanghai',
  'activePlayers': 'Jugadores Activos',
  'pause': 'Pausa',
  'addPlayer': 'Añadir Jugador',
  'editName': 'Editar Nombre',
  'enterName': 'Introducir nombre',
  'save': 'Guardar',
  'cancel': 'Cancelar',
  'remove': 'Eliminar',
  'removePlayerQuestion': 'Eliminar Jugador',
  'reallyRemove': '¿Realmente quieres eliminar a',
  'pauseBeer': '🍺 Cerveza',
  'pauseToilet': '🚽 Baño',
  'pauseSmoke': '🚬 Fumar',
  'pauseSick': '🤮 Enfermo',
  'pauseLove': '❤️ Amor',
  'backToGame': 'Volver al juego',
  'gameRules': 'Reglas del Juego',
  'entry': 'Entrada',
  'exit': 'Salida',
  'straight': 'Directo',
  'double': 'Doble',
  'triple': 'Triple',
  'master': 'Master',
  'startGame': 'Comenzar Partida',
  'back': 'Atrás',
  'undo': 'Deshacer',
  'next': 'Siguiente',
  'continue': 'Continuar',
  'score': 'Puntuación',
  'round': 'Ronda',
  'target': 'Objetivo',
  'currentTarget': 'Objetivo Actual',
  'quitGame': 'Salir del Juego',
  'quitGameQuestion': '¿Salir del Juego?',
  'quitGameWarning': '¿Realmente quieres salir del juego y volver al menú principal? La partida actual se perderá.',
  'quit': 'Salir',
  'gameOver': 'Juego Terminado',
  'winner': 'Ganador',
  'mainMenu': 'Menú Principal',
  'yes': 'Sí',
  'no': 'No',
  'ok': 'OK',
  'close': 'Cerrar',
  'edit': 'Editar',
  'finalScore': 'Puntuación Final',
  'exitDialogMessage': '¿Realmente quieres volver al menú principal?',
  'linkCouldNotBeOpened': 'No se pudo abrir el enlace',
};

// French
const Map<String, String> _fr = {
  'finishingPaths': 'Possibilités de finition',
  'start': 'Commencer',
  'donation': 'Don',
  'mode301': '301',
  'mode501': '501',
  'modeCricket': 'Cricket',
  'modeShanghai': 'Shanghai',
  'activePlayers': 'Joueurs Actifs',
  'pause': 'Pause',
  'addPlayer': 'Ajouter un Joueur',
  'editName': 'Modifier le Nom',
  'enterName': 'Entrer le nom',
  'save': 'Sauvegarder',
  'cancel': 'Annuler',
  'remove': 'Supprimer',
  'removePlayerQuestion': 'Supprimer le Joueur',
  'reallyRemove': 'Voulez-vous vraiment supprimer',
  'pauseBeer': '🍺 Bière',
  'pauseToilet': '🚽 Toilettes',
  'pauseSmoke': '🚬 Fumer',
  'pauseSick': '🤮 Malade',
  'pauseLove': '❤️ Amour',
  'backToGame': 'Retour au jeu',
  'gameRules': 'Règles du Jeu',
  'entry': 'Entrée',
  'exit': 'Sortie',
  'straight': 'Direct',
  'double': 'Double',
  'triple': 'Triple',
  'master': 'Master',
  'startGame': 'Commencer la Partie',
  'back': 'Retour',
  'undo': 'Annuler',
  'next': 'Suivant',
  'continue': 'Continuer',
  'score': 'Score',
  'round': 'Manche',
  'target': 'Cible',
  'currentTarget': 'Cible Actuelle',
  'quitGame': 'Quitter le Jeu',
  'quitGameQuestion': 'Quitter le Jeu?',
  'quitGameWarning': 'Voulez-vous vraiment quitter le jeu et retourner au menu principal? La partie actuelle sera perdue.',
  'quit': 'Quitter',
  'gameOver': 'Partie Terminée',
  'winner': 'Gagnant',
  'mainMenu': 'Menu Principal',
  'yes': 'Oui',
  'no': 'Non',
  'ok': 'OK',
  'close': 'Fermer',
  'edit': 'Modifier',
  'finalScore': 'Score Final',
  'exitDialogMessage': 'Voulez-vous vraiment retourner au menu principal?',
  'linkCouldNotBeOpened': 'Le lien n\'a pas pu être ouvert',
};

// Irish
const Map<String, String> _ga = {
  'finishingPaths': 'Bealaí críochnaithe',
  'start': 'Tosaigh',
  'donation': 'Síntiús',
  'mode301': '301',
  'mode501': '501',
  'modeCricket': 'Cruicéad',
  'modeShanghai': 'Shang​hai',
  'activePlayers': 'Imreoirí Gníomhacha',
  'pause': 'Sos',
  'addPlayer': 'Cuir Imreoir Leis',
  'editName': 'Cuir an tAinm in Eagar',
  'enterName': 'Iontráil ainm',
  'save': 'Sábháil',
  'cancel': 'Cealaigh',
  'remove': 'Bain',
  'removePlayerQuestion': 'Bain Imreoir',
  'reallyRemove': 'Ar mhaith leat',
  'pauseBeer': '🍺 Beoir',
  'pauseToilet': '🚽 Leithreas',
  'pauseSmoke': '🚬 Caith Tobac',
  'pauseSick': '🤮 Tinn',
  'pauseLove': '❤️ Grá',
  'backToGame': 'Ar ais go dtí an cluiche',
  'gameRules': 'Rialacha an Chluiche',
  'entry': 'Iontráil',
  'exit': 'Scoir',
  'straight': 'Díreach',
  'double': 'Dúbailt',
  'triple': 'Triarach',
  'master': 'Máistir',
  'startGame': 'Tosaigh an Cluiche',
  'back': 'Ar Ais',
  'undo': 'Cealaigh',
  'next': 'Ar Aghaidh',
  'continue': 'Lean Ar Aghaidh',
  'score': 'Scór',
  'round': 'Babhta',
  'target': 'Sprioc',
  'currentTarget': 'Sprioc Reatha',
  'quitGame': 'Scoir an Cluiche',
  'quitGameQuestion': 'Scoir an Cluiche?',
  'quitGameWarning': 'Ar mhaith leat an cluiche a scor agus dul ar ais go dtí an príomhroghchlár? Caillfear an cluiche reatha.',
  'quit': 'Scoir',
  'gameOver': 'Cluiche Thart',
  'winner': 'Buaiteoir',
  'mainMenu': 'Príomhroghchlár',
  'yes': 'Tá',
  'no': 'Níl',
  'ok': 'Ceart go Leor',
  'close': 'Dún',
  'edit': 'Cuir in Eagar',
  'finalScore': 'Scór Deiridh',
  'exitDialogMessage': 'Ar mhaith leat dul ar ais go dtí an príomhroghchlár?',
  'linkCouldNotBeOpened': 'Níorbh fhéidir an nasc a oscailt',
};
