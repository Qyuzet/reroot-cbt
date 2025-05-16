import 'dart:async';
import 'package:flutter/material.dart';
import 'package:vibration/vibration.dart';
import 'package:torch_light/torch_light.dart';
import 'package:audioplayers/audioplayers.dart';
import '../utils/constants.dart';
import '../utils/permission_handler.dart';
import '../models/session.dart';
import 'storage_service.dart';

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

  // Execute the current step
  Future<void> _executeCurrentStep() async {
    if (!_isSessionActive) return;

    // Update progress
    double progress = _currentStep / _totalSteps;
    onProgressChanged(progress);
    onStepChanged(_currentStep);

    // Execute step based on index
    switch (_currentStep) {
      case 0:
        await _executeVibrationStep();
        break;
      case 1:
        await _executeLeftHandStep();
        break;
      case 2:
        await _executeFlashlightStep();
        break;
      case 3:
        await _executeCloseEyesStep();
        break;
      case 4:
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

  // Step 1: Vibration for mindfulness
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

  // Step 2: Hold phone with left hand
  Future<void> _executeLeftHandStep() async {
    // This step is passive - just wait for the specified duration
    await Future.delayed(
      Duration(seconds: AppConstants.leftHandHoldDurationSec),
    );
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

    // Use actual flashlight
    if (await PermissionUtil.requestFlashlightPermission(context)) {
      try {
        await TorchLight.enableTorch();
        await Future.delayed(
          Duration(milliseconds: AppConstants.flashlightDurationMs),
        );
        await TorchLight.disableTorch();
      } catch (e) {
        debugPrint('Error controlling flashlight: $e');
        // Fallback if flashlight fails
        await Future.delayed(
          Duration(milliseconds: AppConstants.flashlightDurationMs),
        );
      }
    } else {
      // Fallback if permission is denied
      await Future.delayed(
        Duration(milliseconds: AppConstants.flashlightDurationMs),
      );
    }
  }

  // Step 4: Close eyes and face light
  Future<void> _executeCloseEyesStep() async {
    // This step is passive - just wait for a few seconds
    await Future.delayed(const Duration(seconds: 5));
  }

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

      // Play actual audio
      await _audioPlayer.play(AssetSource(AppConstants.calmingAudioPath));

      // Wait for audio to play
      await Future.delayed(const Duration(seconds: 10));

      // Stop the audio
      await _audioPlayer.stop();
    } catch (e) {
      debugPrint('Error playing audio: $e');
      // Fallback if audio fails
      await Future.delayed(const Duration(seconds: 10));
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
    _audioPlayer.dispose();
  }
}
