import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// This is a simple implementation of internationalization
// For a more robust solution, consider using the flutter_localizations package
// with arb files for translations

class AppLocalizations {
  final Locale locale;
  
  AppLocalizations(this.locale);
  
  // Helper method to keep the code in the widgets concise
  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }
  
  // Static member to have a simple access to the delegate from the MaterialApp
  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();
  
  // Simple translations
  String get appName => 'ReRoot CBT';
  
  String get appDescription => 'A CBT-based behavioral interruption app for managing PMO addiction';
  
  String get helpButton => 'HELP';
  
  String get viewProgress => 'View My Progress';
  
  String get interventionSession => 'Intervention Session';
  
  String get sessionProgress => 'Session Progress';
  
  String get startSession => 'Start Session';
  
  String get breakSession => 'Break';
  
  String get sessionCompleted => 'Session Completed';
  
  String get sessionCompletedMessage => 'Great job! You\'ve successfully completed the intervention session.';
  
  String get returnToHome => 'Return to Home';
  
  String get progressDashboard => 'Progress Dashboard';
  
  String get totalSessions => 'Total Sessions';
  
  String get completionRate => 'Completion Rate';
  
  String get weeklyProgress => 'Weekly Progress';
  
  String get sessionHistory => 'Session History';
  
  String get completedSession => 'Completed Session';
  
  String get partialSession => 'Partial Session';
  
  String get noSessionsYet => 'No sessions yet';
  
  String get noSessionsMessage => 'Complete your first intervention session\nto start tracking your progress';
  
  String get completion => 'Completion';
  
  String get duration => 'Duration';
  
  // Intervention steps
  List<String> get interventionStepTitles => [
    'Vibration for mindfulness',
    'Hold phone with left hand',
    'Flashlight activation',
    'Close eyes and face light',
    'Listen to calming sound',
  ];
  
  List<String> get interventionStepDescriptions => [
    'Feel the vibration and focus on your breath',
    'Hold your phone with your left hand for 10 seconds',
    'The flashlight will turn on briefly',
    'Close your eyes and face the light for a moment',
    'Listen to the calming sound and relax',
  ];
  
  // Permission messages
  String get cameraPermissionTitle => 'Camera Permission Required';
  
  String get cameraPermissionMessage => 'Flashlight requires camera permission. Please enable it in app settings.';
  
  String get microphonePermissionTitle => 'Microphone Permission Required';
  
  String get microphonePermissionMessage => 'Audio features require microphone permission. Please enable it in app settings.';
  
  String get cancel => 'Cancel';
  
  String get openSettings => 'Open Settings';
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();
  
  @override
  bool isSupported(Locale locale) {
    // Support English for now, can be expanded later
    return locale.languageCode == 'en';
  }
  
  @override
  Future<AppLocalizations> load(Locale locale) async {
    // Return a SynchronousFuture because we're not doing any async loading
    return AppLocalizations(locale);
  }
  
  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
