import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:torch_light/torch_light.dart';
import 'package:audioplayers/audioplayers.dart';
import '../utils/constants.dart';
import '../utils/permission_handler.dart';
import '../models/session.dart';
import '../models/session_sequence.dart';
import 'storage_service.dart';
import 'shake_detector_service.dart';
import 'tts_service.dart';
import 'gemini_service.dart';

class DynamicInterventionService {
  final BuildContext context;
  final Function(int) onStepChanged;
  final Function(double) onProgressChanged;
  final Function(String, String) onStepInfoChanged; // Added for dynamic steps
  final Function() onSessionCompleted;
  final Function() onSessionAborted;

  // Private variables
  int _currentStep = 0;
  late SessionSequence _sessionSequence;
  late int _totalSteps;
  DateTime _sessionStartTime = DateTime.now();
  bool _isSessionActive = false;
  final AudioPlayer _audioPlayer = AudioPlayer();

  // Shake detector
  ShakeDetectorService? _shakeDetector;
  Completer<void>? _shakeCompleter;

  // Text-to-speech service
  final TtsService _ttsService = TtsService();

  // Gemini service for personalized sequences
  final GeminiService _geminiService = GeminiService();

  // Constructor
  DynamicInterventionService({
    required this.context,
    required this.onStepChanged,
    required this.onProgressChanged,
    required this.onStepInfoChanged,
    required this.onSessionCompleted,
    required this.onSessionAborted,
  });

  // Start the intervention session
  Future<void> startSession() async {
    _sessionStartTime = DateTime.now();
    _currentStep = 0;
    _isSessionActive = true;

    // Get past sessions for personalization
    final pastSessions = await StorageService.getSessions();

    try {
      // Try to get a personalized sequence from Gemini
      final userLevel = _calculateUserLevel(pastSessions);
      _sessionSequence = await _geminiService.generatePersonalizedSequence(
        pastSessions,
        userLevel,
      );
    } catch (e) {
      debugPrint('Error generating personalized sequence: $e');
      // Fallback to a random sequence
      _sessionSequence = SessionSequence.generateRandom();
    }

    _totalSteps = _sessionSequence.steps.length;

    // Start the first step
    await _executeCurrentStep();
  }

  // Calculate user level based on past sessions
  int _calculateUserLevel(List<Session> pastSessions) {
    if (pastSessions.isEmpty) return 1;

    final completedSessions = pastSessions.where((s) => s.wasCompleted).length;

    if (completedSessions < 3) return 1;
    if (completedSessions < 7) return 2;
    if (completedSessions < 15) return 3;
    if (completedSessions < 30) return 4;
    return 5;
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

    // Get current step
    final currentStep = _sessionSequence.steps[_currentStep];

    // Update step info
    onStepInfoChanged(currentStep.title, currentStep.description);

    // Execute step based on type
    switch (currentStep.type) {
      case StepType.handPosition:
        await _executeHandPositionStep(currentStep);
        break;
      case StepType.vibration:
        await _executeVibrationStep(currentStep);
        break;
      case StepType.flashlight:
        await _executeFlashlightStep(currentStep);
        break;
      case StepType.audio:
        await _executeAudioStep(currentStep);
        break;
      case StepType.breathe:
        await _executeBreathingStep(currentStep);
        break;
      case StepType.visualize:
        await _executeVisualizationStep(currentStep);
        break;
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

  // Execute hand position step
  Future<void> _executeHandPositionStep(SessionStep step) async {
    final position = step.parameters['position'] as String;
    final durationSec = step.parameters['durationSec'] as int;

    // Wait for user to confirm they're holding the phone correctly
    await _waitForShakeConfirmation(step.description);

    // Give them a moment to adjust their grip after shaking
    await Future.delayed(Duration(seconds: durationSec));
  }

  // Execute vibration step
  Future<void> _executeVibrationStep(SessionStep step) async {
    final pattern = step.parameters['pattern'] as String;
    final intensity = step.parameters['intensity'] as double;
    final durationMs = (step.parameters['durationSec'] as int) * 1000;
    final pulseCount = step.parameters['pulseCount'] as int;

    // Show a message to the user
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(step.description),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Speak the instruction
    await _ttsService.speak(step.description);

    // Add a small pause after speaking before starting vibration
    await Future.delayed(const Duration(milliseconds: 500));

    // Use actual vibration with pattern
    if (await Vibration.hasVibrator()) {
      // Calculate pulse duration and interval based on pattern
      final pulseDuration = _calculateVibrationDuration(
        pattern,
        durationMs,
        pulseCount,
      );
      final pulseInterval = _calculateVibrationInterval(
        pattern,
        durationMs,
        pulseCount,
      );

      // Create vibration pattern
      for (int i = 0; i < pulseCount; i++) {
        // Vibrate
        debugPrint('Vibration pulse ${i + 1}/$pulseCount');
        await Vibration.vibrate(duration: pulseDuration);

        // Wait for vibration to complete
        await Future.delayed(Duration(milliseconds: pulseDuration));

        // Pause between pulses (except after the last one)
        if (i < pulseCount - 1) {
          await Future.delayed(Duration(milliseconds: pulseInterval));
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
      final vibrationDuration = _calculateVibrationDuration(
        pattern,
        durationMs,
        pulseCount,
      );
      final vibrationInterval = _calculateVibrationInterval(
        pattern,
        durationMs,
        pulseCount,
      );
      final totalDuration =
          pulseCount * (vibrationDuration + vibrationInterval);
      await Future.delayed(Duration(milliseconds: totalDuration));
    }
  }

  // Execute flashlight step
  Future<void> _executeFlashlightStep(SessionStep step) async {
    final pattern = step.parameters['pattern'] as String;
    final intensity = step.parameters['intensity'] as double;
    final durationMs = (step.parameters['durationSec'] as int) * 1000;
    final pulseCount = step.parameters['pulseCount'] as int;

    // Show a message to the user
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(step.description),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Speak the instruction
    await _ttsService.speak(step.description);

    // Add a small pause after speaking before starting flashlight
    await Future.delayed(const Duration(milliseconds: 500));

    // Use actual flashlight with pattern
    try {
      // Check if device has torch
      bool hasTorch = await TorchLight.isTorchAvailable();
      debugPrint('Device has torch: $hasTorch');

      if (hasTorch) {
        // Calculate pulse duration and interval based on pattern
        final pulseDuration = _calculateFlashlightDuration(
          pattern,
          durationMs,
          pulseCount,
        );
        final pulseInterval = _calculateFlashlightInterval(
          pattern,
          durationMs,
          pulseCount,
        );

        // Create flashlight pattern
        for (int i = 0; i < pulseCount; i++) {
          // Enable torch
          debugPrint('Flash pulse ${i + 1}/$pulseCount');
          await TorchLight.enableTorch();
          debugPrint('Torch enabled');

          // Keep torch on for specified duration
          await Future.delayed(Duration(milliseconds: pulseDuration));

          // Disable torch
          await TorchLight.disableTorch();
          debugPrint('Torch disabled');

          // Pause between flashes (except after the last one)
          if (i < pulseCount - 1) {
            await Future.delayed(Duration(milliseconds: pulseInterval));
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
        final flashDuration = _calculateFlashlightDuration(
          pattern,
          durationMs,
          pulseCount,
        );
        final flashInterval = _calculateFlashlightInterval(
          pattern,
          durationMs,
          pulseCount,
        );
        final totalDuration = pulseCount * (flashDuration + flashInterval);
        await Future.delayed(Duration(milliseconds: totalDuration));
      }
    } catch (e) {
      debugPrint('Error controlling flashlight: $e');

      // Speak error message
      await _ttsService.speak(
        'There was an issue with the flashlight. Please imagine gentle light pulses with your eyes closed.',
      );

      // Simulate the time it would take for flashlight pattern
      final defaultDuration = 500;
      final defaultInterval = 500;
      final totalDuration =
          pulseCount * (defaultDuration + defaultInterval); // Default values
      await Future.delayed(Duration(milliseconds: totalDuration));
    }
  }

  // Execute audio step
  Future<void> _executeAudioStep(SessionStep step) async {
    final audioType = step.parameters['audioType'] as String;
    final volume = step.parameters['volume'] as double;
    final durationSec = step.parameters['durationSec'] as int;

    try {
      // Show a message to the user
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(step.description),
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Speak the instruction
      await _ttsService.speak(step.description);

      // Wait a moment after speaking before playing audio
      await Future.delayed(const Duration(seconds: 1));

      // Get audio URL based on type
      final audioUrl = _getAudioUrlForType(audioType);
      debugPrint('Playing audio: $audioUrl');

      // Set volume
      await _audioPlayer.setVolume(volume);
      debugPrint('Volume set to $volume');

      // Set release mode to stop audio when app is in background
      await _audioPlayer.setReleaseMode(ReleaseMode.release);

      // Request audio focus (important for Android)
      await _audioPlayer.setPlayerMode(PlayerMode.mediaPlayer);

      // Play the audio
      await _audioPlayer.play(UrlSource(audioUrl));
      debugPrint('Audio playback started');

      // Wait for audio to play
      await Future.delayed(Duration(seconds: durationSec));

      // Stop the audio
      await _audioPlayer.stop();
      debugPrint('Audio playback stopped');

      // Speak completion message
      await _ttsService.speak('Audio session complete.');
    } catch (e) {
      debugPrint('Error playing audio: $e');

      // Speak error message
      await _ttsService.speak('There was an issue playing the audio.');

      // Try playing a system beep sound as fallback
      try {
        await _audioPlayer.play(AssetSource('audio/beep.mp3'));
        await Future.delayed(const Duration(seconds: 1));
        await _audioPlayer.stop();
      } catch (e2) {
        debugPrint('Error playing fallback sound: $e2');
      }

      // Wait for the remaining time
      await Future.delayed(Duration(seconds: durationSec - 1));
    }
  }

  // Execute breathing step
  Future<void> _executeBreathingStep(SessionStep step) async {
    final durationSec = step.parameters['durationSec'] as int;
    final cycles = step.parameters['cycles'] as int? ?? 5;

    // Show a message to the user
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(step.description),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Speak the instruction
    await _ttsService.speak(step.description);

    // Wait a moment after speaking before starting breathing
    await Future.delayed(const Duration(seconds: 1));

    // Guide through breathing cycles
    for (int i = 0; i < cycles; i++) {
      // Inhale
      await _ttsService.speak('Inhale slowly through your nose...');
      await Future.delayed(const Duration(seconds: 4));

      // Hold
      await _ttsService.speak('Hold your breath...');
      await Future.delayed(const Duration(seconds: 2));

      // Exhale
      await _ttsService.speak('Exhale slowly through your mouth...');
      await Future.delayed(const Duration(seconds: 4));

      // Pause between cycles
      if (i < cycles - 1) {
        await Future.delayed(const Duration(seconds: 1));
      }
    }

    // Speak completion message
    await _ttsService.speak('Breathing exercise complete. Well done.');
  }

  // Execute visualization step
  Future<void> _executeVisualizationStep(SessionStep step) async {
    final durationSec = step.parameters['durationSec'] as int;
    final scenario = step.parameters['scenario'] as String? ?? 'calm_place';

    // Show a message to the user
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(step.description),
          duration: const Duration(seconds: 3),
        ),
      );
    }

    // Speak the instruction
    await _ttsService.speak(step.description);

    // Wait a moment after speaking before starting visualization
    await Future.delayed(const Duration(seconds: 1));

    // Guide through visualization
    final visualizationText = _getVisualizationText(scenario);
    await _ttsService.speak(visualizationText);

    // Wait for the specified duration
    await Future.delayed(Duration(seconds: durationSec));

    // Speak completion message
    await _ttsService.speak(
      'Visualization exercise complete. Gently return your awareness to the present moment.',
    );
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

  // Helper methods
  int _calculateVibrationDuration(
    String pattern,
    int totalDurationMs,
    int pulseCount,
  ) {
    switch (pattern) {
      case 'gentle':
        return 300;
      case 'pulsing':
        return 200;
      case 'escalating':
        return 400;
      case 'rhythmic':
        return 250;
      case 'wave':
        return 500;
      default:
        return totalDurationMs ~/ (pulseCount * 2);
    }
  }

  int _calculateVibrationInterval(
    String pattern,
    int totalDurationMs,
    int pulseCount,
  ) {
    switch (pattern) {
      case 'gentle':
        return 700;
      case 'pulsing':
        return 300;
      case 'escalating':
        return 200;
      case 'rhythmic':
        return 500;
      case 'wave':
        return 800;
      default:
        return totalDurationMs ~/ (pulseCount * 2);
    }
  }

  int _calculateFlashlightDuration(
    String pattern,
    int totalDurationMs,
    int pulseCount,
  ) {
    switch (pattern) {
      case 'steady':
        return totalDurationMs;
      case 'pulsing':
        return 300;
      case 'strobe':
        return 100;
      case 'fadeInOut':
        return 800;
      case 'morse':
        return 200;
      case 'heartbeat':
        return 400;
      default:
        return totalDurationMs ~/ (pulseCount * 2);
    }
  }

  int _calculateFlashlightInterval(
    String pattern,
    int totalDurationMs,
    int pulseCount,
  ) {
    switch (pattern) {
      case 'steady':
        return 0;
      case 'pulsing':
        return 500;
      case 'strobe':
        return 100;
      case 'fadeInOut':
        return 400;
      case 'morse':
        return 300;
      case 'heartbeat':
        return 600;
      default:
        return totalDurationMs ~/ (pulseCount * 2);
    }
  }

  String _getAudioUrlForType(String audioType) {
    switch (audioType) {
      case 'whitenoise':
        return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';
      case 'nature':
        return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-3.mp3';
      case 'meditation':
        return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-4.mp3';
      case 'breathing':
        return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-5.mp3';
      case 'heartbeat':
        return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-6.mp3';
      default:
        return 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-1.mp3';
    }
  }

  String _getVisualizationText(String scenario) {
    switch (scenario) {
      case 'calm_place':
        return 'Imagine yourself in a peaceful, calm place. It could be a beach, a forest, or anywhere you feel safe and relaxed. Take in the sights, sounds, and sensations of this place. Feel the tension leaving your body as you breathe deeply.';
      case 'mountain':
        return 'Imagine yourself standing at the top of a mountain. The air is clean and crisp. You can see for miles in every direction. Feel the strength and stability of the mountain beneath you, supporting you completely.';
      case 'water':
        return 'Imagine yourself beside a clear, calm body of water. It could be a lake, a river, or the ocean. Watch how the water moves gently. With each breath, imagine the water washing away your stress and tension.';
      default:
        return 'Close your eyes and take a few deep breaths. Imagine a place where you feel completely safe and at peace. Notice the details around you in this place. Allow yourself to fully relax in this peaceful sanctuary.';
    }
  }
}
