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
import 'tts_service.dart';

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

  // Text-to-speech service
  final TtsService _ttsService = TtsService();

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
    final voiceMessage = '$message. Shake phone gently to continue.';

    // Show visual message
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(voiceMessage),
          duration: const Duration(seconds: 5),
        ),
      );
    }

    // Speak the instruction with female voice
    await _ttsService.speak(voiceMessage);

    // Create a completer that will be resolved when shake is detected
    _shakeCompleter = Completer<void>();

    // Initialize shake detector
    _shakeDetector = ShakeDetectorService(
      onShake: () {
        if (_shakeCompleter != null && !_shakeCompleter!.isCompleted) {
          debugPrint('Shake confirmed!');

          // Stop the TTS if it's still speaking
          _ttsService.stop();

          // Speak confirmation
          _ttsService.speak('Confirmed! Proceeding to next step.');

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

          // Stop the TTS if it's still speaking
          _ttsService.stop();

          // Speak timeout message
          _ttsService.speak('No shake detected. Proceeding anyway.');

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
        await _completeSession();
        return;
    }

    // Move to next step if session is still active
    if (_isSessionActive) {
      _currentStep++;

      if (_currentStep >= _totalSteps) {
        await _completeSession();
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
    final message =
        'Phone vibrating for mindfulness. Focus on your breath with each vibration pulse.';

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
    }

    // Speak the instruction
    await _ttsService.speak(message);

    // Add a small pause after speaking before starting vibration
    await Future.delayed(const Duration(milliseconds: 500));

    // Use actual vibration with pattern
    if (await Vibration.hasVibrator()) {
      // Create a pulsing vibration pattern
      for (int i = 0; i < AppConstants.vibrationPatternCount; i++) {
        // Vibrate
        debugPrint(
          'Vibration pulse ${i + 1}/${AppConstants.vibrationPatternCount}',
        );
        await Vibration.vibrate(duration: AppConstants.vibrationDurationMs);

        // Wait for vibration to complete
        await Future.delayed(
          Duration(milliseconds: AppConstants.vibrationDurationMs),
        );

        // Pause between pulses (except after the last one)
        if (i < AppConstants.vibrationPatternCount - 1) {
          await Future.delayed(
            Duration(milliseconds: AppConstants.vibrationPatternIntervalMs),
          );
        }
      }

      // Final pause after vibration sequence
      await Future.delayed(const Duration(milliseconds: 500));

      // Speak completion message
      await _ttsService.speak(
        'Vibration sequence complete. Take a deep breath.',
      );
    } else {
      // Fallback if vibration is not available
      await _ttsService.speak(
        'Your device does not support vibration. Please imagine gentle pulses as you breathe.',
      );

      // Simulate the time it would take for vibration pattern
      final totalDuration =
          AppConstants.vibrationPatternCount *
          (AppConstants.vibrationDurationMs +
              AppConstants.vibrationPatternIntervalMs);
      await Future.delayed(Duration(milliseconds: totalDuration));
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
    final message =
        'Flashlight pattern activated for light therapy. Keep your eyes closed and focus on the rhythm.';

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
    }

    // Speak the instruction
    await _ttsService.speak(message);

    // Add a small pause after speaking before starting flashlight
    await Future.delayed(const Duration(milliseconds: 500));

    // Use actual flashlight with pattern
    try {
      // Check if device has torch
      bool hasTorch = await TorchLight.isTorchAvailable();
      debugPrint('Device has torch: $hasTorch');

      if (hasTorch) {
        // Create a pulsing flashlight pattern
        for (int i = 0; i < AppConstants.flashlightPatternCount; i++) {
          // Enable torch
          debugPrint(
            'Flash pulse ${i + 1}/${AppConstants.flashlightPatternCount}',
          );
          await TorchLight.enableTorch();
          debugPrint('Torch enabled');

          // Keep torch on for specified duration
          await Future.delayed(
            Duration(milliseconds: AppConstants.flashlightDurationMs),
          );

          // Disable torch
          await TorchLight.disableTorch();
          debugPrint('Torch disabled');

          // Pause between flashes (except after the last one)
          if (i < AppConstants.flashlightPatternCount - 1) {
            await Future.delayed(
              Duration(milliseconds: AppConstants.flashlightPatternIntervalMs),
            );
          }
        }

        // Final pause after flashlight sequence
        await Future.delayed(const Duration(milliseconds: 500));

        // Speak completion message
        await _ttsService.speak(
          'Light therapy sequence complete. Take a moment to relax your eyes.',
        );
      } else {
        debugPrint('Device does not have torch');

        // Speak error message
        await _ttsService.speak(
          'Your device does not have a flashlight. Please imagine gentle light pulses with your eyes closed.',
        );

        // Simulate the time it would take for flashlight pattern
        final totalDuration =
            AppConstants.flashlightPatternCount *
            (AppConstants.flashlightDurationMs +
                AppConstants.flashlightPatternIntervalMs);
        await Future.delayed(Duration(milliseconds: totalDuration));
      }
    } catch (e) {
      debugPrint('Error controlling flashlight: $e');

      // Speak error message
      await _ttsService.speak(
        'There was an issue with the flashlight. Please imagine gentle light pulses with your eyes closed.',
      );

      // Simulate the time it would take for flashlight pattern
      final totalDuration =
          AppConstants.flashlightPatternCount *
          (AppConstants.flashlightDurationMs +
              AppConstants.flashlightPatternIntervalMs);
      await Future.delayed(Duration(milliseconds: totalDuration));
    }
  }

  // This method was removed as it's no longer needed

  // Step 5: Play calming sound
  Future<void> _executeAudioStep() async {
    final message =
        'Now listen to this calming sound and relax. Take deep breaths.';

    try {
      // Show a message to the user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Speak the instruction
      await _ttsService.speak(message);

      // Wait a moment after speaking before playing audio
      await Future.delayed(const Duration(seconds: 1));

      debugPrint(
        'Attempting to play audio from: ${AppConstants.calmingAudioPath}',
      );

      // Play actual audio - using a URL instead of asset for testing
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

      // Speak completion message
      await _ttsService.speak('Calming sound session complete.');
    } catch (e) {
      debugPrint('Error playing audio from URL: $e');

      // Speak error message
      await _ttsService.speak('There was an issue playing the calming sound.');

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
  Future<void> _completeSession() async {
    if (!_isSessionActive) return;

    _isSessionActive = false;

    // Speak completion message
    await _ttsService.speak(
      'Congratulations! You have completed the intervention session successfully.',
    );

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
  Future<void> abortSession() async {
    if (!_isSessionActive) return;

    _isSessionActive = false;

    // Speak abort message
    await _ttsService.speak(
      'Session interrupted. That\'s okay, you can try again later.',
    );

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
  Future<void> dispose() async {
    if (_isSessionActive) {
      await abortSession();
    }

    // Clean up shake detector
    _shakeDetector?.dispose();
    _shakeDetector = null;

    // Clean up TTS
    await _ttsService.dispose();

    // Clean up audio player
    _audioPlayer.dispose();
  }
}
