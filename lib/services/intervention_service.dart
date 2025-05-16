import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:torch_light/torch_light.dart';
import 'package:audioplayers/audioplayers.dart';
import '../utils/constants.dart';
import '../utils/permission_handler.dart';
import '../models/session.dart';
import 'storage_service.dart';
import 'shake_detector_service.dart';

class InterventionService {
  final BuildContext context;
  final Function(int) onStepChanged;
  final Function(double) onProgressChanged;
  final Function() onSessionCompleted;
  final Function() onSessionAborted;

  // Private variables
  int _currentStep = 0;
  final int _totalSteps = AppConstants.interventionSteps.length;
  DateTime _sessionStartTime = DateTime.now();
  bool _isSessionActive = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Shake detector
  ShakeDetectorService? _shakeDetector;
  Completer<void>? _shakeCompleter;

  // Constructor
  InterventionService({
    required this.context,
    required this.onStepChanged,
    required this.onProgressChanged,
    required this.onSessionCompleted,
    required this.onSessionAborted,
  });

  // Start the intervention session
  Future<void> startSession() async {
    _sessionStartTime = DateTime.now();
    _currentStep = 0;
    _isSessionActive = true;

    // Start the first step
    await _executeCurrentStep();
  }

  // Wait for shake confirmation
  Future<void> _waitForShakeConfirmation(String message) async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$message - Shake phone gently to continue'),
          duration: const Duration(seconds: 5),
        ),
      );
    }

    // Create a completer that will be resolved when shake is detected
    _shakeCompleter = Completer<void>();

    // Initialize shake detector
    _shakeDetector = ShakeDetectorService(
      onShake: () {
        if (_shakeCompleter != null && !_shakeCompleter!.isCompleted) {
          debugPrint('Shake confirmed!');

          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Confirmed! Proceeding to next step...'),
                duration: Duration(seconds: 1),
              ),
            );
          }

          _shakeCompleter!.complete();
        }
      },
    );

    // Start listening for shakes
    _shakeDetector!.startListening();

    // Wait for shake or timeout after 30 seconds
    try {
      await _shakeCompleter!.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          debugPrint('Shake timeout - proceeding anyway');
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('No shake detected - proceeding anyway'),
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
      );
    } catch (e) {
      debugPrint('Error waiting for shake: $e');
    } finally {
      // Clean up
      _shakeDetector?.stopListening();
      _shakeDetector = null;
    }
  }

  // Execute the current step
  Future<void> _executeCurrentStep() async {
    if (!_isSessionActive) return;

    // Update progress
    double progress = _currentStep / _totalSteps;
    onProgressChanged(progress);
    onStepChanged(_currentStep);

    // Execute step based on index
    switch (_currentStep) {
      case 0: // Hold phone with left hand
        await _executeLeftHandStep();
        break;
      case 1: // Vibration for mindfulness
        await _executeVibrationStep();
        break;
      case 2: // Prepare for light therapy
        await _executePrepareForLightStep();
        break;
      case 3: // Flashlight activation
        await _executeFlashlightStep();
        break;
      case 4: // Listen to calming sound
        await _executeAudioStep();
        break;
      default:
        _completeSession();
        return;
    }

    // Move to next step if session is still active
    if (_isSessionActive) {
      _currentStep++;

      if (_currentStep >= _totalSteps) {
        _completeSession();
      } else {
        await _executeCurrentStep();
      }
    }
  }

  // Step 1: Hold phone with left hand
  Future<void> _executeLeftHandStep() async {
    // Wait for user to confirm they're holding the phone with left hand
    await _waitForShakeConfirmation('Hold phone with your left hand');

    // Give them a moment to adjust their grip after shaking
    await Future.delayed(const Duration(seconds: 2));
  }

  // Step 2: Vibration for mindfulness
  Future<void> _executeVibrationStep() async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Phone vibrating for mindfulness...'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // Use actual vibration
    if (await Vibration.hasVibrator()) {
      await Vibration.vibrate(duration: AppConstants.vibrationDurationMs);
      await Future.delayed(
        Duration(milliseconds: AppConstants.vibrationDurationMs + 500),
      );
    } else {
      // Fallback if vibration is not available
      await Future.delayed(
        Duration(milliseconds: AppConstants.vibrationDurationMs + 500),
      );
    }
  }

  // Step 3: Prepare for light therapy
  Future<void> _executePrepareForLightStep() async {
    // Wait for user to confirm they're ready for light therapy
    await _waitForShakeConfirmation(
      'Position phone so flash faces your closed eyes',
    );

    // Give them a moment to get ready after shaking
    await Future.delayed(const Duration(seconds: 2));
  }

  // Step 3: Flashlight activation
  Future<void> _executeFlashlightStep() async {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Flashlight activated...'),
          duration: Duration(seconds: 2),
        ),
      );
    }

    // Use actual flashlight - simplified approach
    try {
      // Check if device has torch
      bool hasTorch = await TorchLight.isTorchAvailable();
      debugPrint('Device has torch: $hasTorch');

      if (hasTorch) {
        // Enable torch
        await TorchLight.enableTorch();
        debugPrint('Torch enabled');

        // Keep torch on for specified duration
        await Future.delayed(
          Duration(milliseconds: AppConstants.flashlightDurationMs),
        );

        // Disable torch
        await TorchLight.disableTorch();
        debugPrint('Torch disabled');
      } else {
        debugPrint('Device does not have torch');
        await Future.delayed(
          Duration(milliseconds: AppConstants.flashlightDurationMs),
        );
      }
    } catch (e) {
      debugPrint('Error controlling flashlight: $e');
      // Fallback if flashlight fails
      await Future.delayed(
        Duration(milliseconds: AppConstants.flashlightDurationMs),
      );
    }
  }

  // This method was removed as it's no longer needed

  // Step 5: Play calming sound
  Future<void> _executeAudioStep() async {
    try {
      // Show a message to the user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Playing calming sound...'),
            duration: Duration(seconds: 3),
          ),
        );
      }

      debugPrint(
        'Attempting to play audio from: ${AppConstants.calmingAudioPath}',
      );

      // Play actual audio - using a different URL that's more reliable
      // You can replace this with a real MP3 file in your assets later
      const String testAudioUrl =
          'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';

      // Set volume to maximum
      await _audioPlayer.setVolume(1.0);
      debugPrint('Volume set to maximum');

      // Set release mode to stop audio when app is in background
      await _audioPlayer.setReleaseMode(ReleaseMode.release);

      // Request audio focus (important for Android)
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);
      debugPrint('Set player mode to media player');

      // Play the audio
      await _audioPlayer.play(UrlSource(testAudioUrl));
      debugPrint('Audio playback started');

      // Add a listener to track audio state
      _audioPlayer.onPlayerStateChanged.listen((state) {
        debugPrint('Audio player state changed: $state');
      });

      // Add a listener to track audio position
      _audioPlayer.onPositionChanged.listen((position) {
        debugPrint('Audio position: ${position.inSeconds}s');
      });

      // Add a listener to track audio completion
      _audioPlayer.onPlayerComplete.listen((_) {
        debugPrint('Audio playback completed');
      });

      // Wait for audio to play
      for (int i = 0; i < 10; i++) {
        await Future.delayed(const Duration(seconds: 1));
        final state = _audioPlayer.state;
        debugPrint('Audio state after ${i + 1} seconds: $state');
      }

      // Stop the audio
      await _audioPlayer.stop();
      debugPrint('Audio playback stopped');
    } catch (e) {
      debugPrint('Error playing audio from URL: $e');

      // Try playing a system beep sound as fallback
      try {
        debugPrint('Trying to play system beep sound...');
        // Use a short beep sound that's built into Android
        await _audioPlayer.play(AssetSource('audio/beep.mp3'));
        await Future.delayed(const Duration(seconds: 1));
        await _audioPlayer.stop();
      } catch (e2) {
        debugPrint('Error playing fallback sound: $e2');
      }

      // Wait for the remaining time
      await Future.delayed(const Duration(seconds: 9));
    }
  }

  // Complete the session
  void _completeSession() {
    if (!_isSessionActive) return;

    _isSessionActive = false;

    // Calculate session duration
    final sessionEndTime = DateTime.now();
    final durationInSeconds =
        sessionEndTime.difference(_sessionStartTime).inSeconds;

    // Create and save session record
    final session = Session(
      timestamp: _sessionStartTime,
      completionPercentage: 100.0,
      durationInSeconds: durationInSeconds,
      wasCompleted: true,
    );

    StorageService.saveSession(session);

    // Notify listeners
    onProgressChanged(1.0);
    onSessionCompleted();
  }

  // Abort the session
  void abortSession() {
    if (!_isSessionActive) return;

    _isSessionActive = false;

    // Clean up resources
    _audioPlayer.stop();
    try {
      TorchLight.disableTorch();
    } catch (e) {
      debugPrint('Error disabling torch: $e');
    }

    // Clean up shake detector
    _shakeDetector?.dispose();
    _shakeDetector = null;

    // Complete any pending shake completer to avoid hanging
    if (_shakeCompleter != null && !_shakeCompleter!.isCompleted) {
      _shakeCompleter!.complete();
    }

    // Calculate session duration and completion percentage
    final sessionEndTime = DateTime.now();
    final durationInSeconds =
        sessionEndTime.difference(_sessionStartTime).inSeconds;
    final completionPercentage = (_currentStep / _totalSteps) * 100;

    // Create and save session record
    final session = Session(
      timestamp: _sessionStartTime,
      completionPercentage: completionPercentage,
      durationInSeconds: durationInSeconds,
      wasCompleted: false,
    );

    StorageService.saveSession(session);

    // Notify listeners
    onSessionAborted();
  }

  // Dispose resources
  void dispose() {
    if (_isSessionActive) {
      abortSession();
    }

    // Clean up shake detector
    _shakeDetector?.dispose();
    _shakeDetector = null;

    // Clean up audio player
    _audioPlayer.dispose();
  }
}
