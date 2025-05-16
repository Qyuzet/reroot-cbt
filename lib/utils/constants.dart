class AppConstants {
  // App information
  static const String appName = 'ReRoot CBT';
  static const String appDescription =
      'A CBT-based behavioral interruption app for managing PMO addiction';

  // Session constants
  static const int vibrationDurationMs = 1000;
  static const int flashlightDurationMs = 2000;
  static const int leftHandHoldDurationSec = 10;

  // Storage keys
  static const String sessionHistoryKey = 'session_history';
  static const String themePreferenceKey = 'theme_preference';
  static const String languagePreferenceKey = 'language_preference';

  // Intervention steps
  static const List<String> interventionSteps = [
    'Hold phone with left hand',
    'Vibration for mindfulness',
    'Prepare for light therapy',
    'Flashlight activation',
    'Listen to calming sound',
  ];

  // Audio assets
  static const String calmingAudioPath = 'assets/audio/calming_sound.mp3';

  // Permission messages
  static const String vibrationPermissionMessage =
      'Vibration is needed for the mindfulness exercise';
  static const String flashlightPermissionMessage =
      'Flashlight is needed for the light therapy exercise';
  static const String audioPermissionMessage =
      'Audio is needed for the calming sound exercise';
}
