# ReRoot CBT

A Flutter mobile app for Android that helps users manage PMO addiction using CBT-based behavioral interruption techniques.

## Features

- **Clean and Calming UI**: A user-friendly interface designed to provide a calming experience
- **Guided Intervention Sessions**: Interactive steps to help users break unwanted behavioral patterns
- **Multisensory Approach**: Uses vibration, flashlight, and audio for a comprehensive intervention
- **Progress Tracking**: Records session completion and displays growth over time
- **Light and Dark Themes**: Supports both light and dark mode for user preference
- **Responsive Design**: Optimized for various screen sizes
- **Internationalization Support**: Ready for multilingual expansion

## Technical Details

### Dependencies

- **vibration**: For phone vibration during mindfulness exercises
- **torch_light**: For flashlight control during light therapy
- **audioplayers**: For playing calming sounds
- **shared_preferences**: For local storage of session data
- **fl_chart**: For visualizing progress data
- **provider**: For state management
- **flutter_localizations**: For internationalization support

### Project Structure

```
lib/
├── l10n/                  # Internationalization
├── models/                # Data models
├── screens/               # UI screens
├── services/              # Business logic
├── themes/                # Theme configurations
├── utils/                 # Utility functions
├── widgets/               # Reusable UI components
└── main.dart              # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (version 3.7.2 or higher)
- Android Studio or VS Code with Flutter extensions
- Android device or emulator

### Installation

1. Clone the repository:

   ```
   git clone https://github.com/yourusername/reroot-cbt.git
   ```

2. Navigate to the project directory:

   ```
   cd reroot-cbt
   ```

3. Install dependencies:

   ```
   flutter pub get
   ```

4. Add audio files:

   - Place a calming audio file named `calming_sound.mp3` in the `assets/audio/` directory

5. Run the app:
   ```
   flutter run
   ```

## Usage

1. Launch the app
2. Tap the "HELP" button when you need intervention
3. Follow the guided steps in the intervention session
4. Track your progress in the dashboard

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter team for the amazing framework
- Contributors and maintainers of the used packages
