class AppConstants {
  // App information
  static const String appName = 'ReRoot CBT';
  static const String appDescription =
      'A CBT-based behavioral interruption app for managing PMO addiction';

  // Session constants
  static const int vibrationDurationMs = 500; // Shorter for pattern
  static const int flashlightDurationMs = 500; // Shorter for pattern
  static const int leftHandHoldDurationSec = 10;

  // Pattern counts
  static const int vibrationPatternCount = 5; // 5 vibration pulses
  static const int flashlightPatternCount = 6; // 6 flash pulses

  // Pattern intervals
  static const int vibrationPatternIntervalMs = 300; // 300ms between vibrations
  static const int flashlightPatternIntervalMs = 500; // 500ms between flashes

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
