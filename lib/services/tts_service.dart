import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { playing, stopped, paused, continued }

class TtsService {
  FlutterTts? _flutterTts;
  TtsState _ttsState = TtsState.stopped;

  bool _isFemaleVoiceSet = false;

  // Constructor
  TtsService() {
    _initTts();
  }

  // Initialize TTS
  Future<void> _initTts() async {
    _flutterTts = FlutterTts();

    if (_flutterTts != null) {
      // Set completion handler
      _flutterTts!.setCompletionHandler(() {
        debugPrint('TTS Completed');
        _ttsState = TtsState.stopped;
      });

      // Set error handler
      _flutterTts!.setErrorHandler((msg) {
        debugPrint('TTS Error: $msg');
        _ttsState = TtsState.stopped;
      });

      // Set language
      await _flutterTts!.setLanguage('en-US');

      // Set speech rate (0.5 is half normal speed, good for clarity)
      await _flutterTts!.setSpeechRate(0.5);

      // Set volume
      await _flutterTts!.setVolume(1.0);

      // Set pitch (higher values for female voice)
      await _flutterTts!.setPitch(1.2);

      // Try to set a female voice
      await _setFemaleVoice();
    }
  }

  // Try to set a female voice
  Future<void> _setFemaleVoice() async {
    if (_flutterTts == null || _isFemaleVoiceSet) return;

    try {
      // Get available voices
      final voices = await _flutterTts!.getVoices;

      if (voices != null) {
        // Look for female voices
        final femaleVoices =
            voices.where((voice) {
              final voiceMap = voice as Map<String, dynamic>;
              final voiceName = voiceMap['name'] as String? ?? '';

              // Look for indicators of female voice in the name
              return voiceName.toLowerCase().contains('female') ||
                  voiceName.toLowerCase().contains('woman') ||
                  voiceName.toLowerCase().contains('girl') ||
                  voiceName.toLowerCase().contains('f') ||
                  // Some voice names include gender indicators
                  voiceName.toLowerCase().contains('samantha') ||
                  voiceName.toLowerCase().contains('victoria') ||
                  voiceName.toLowerCase().contains('karen') ||
                  voiceName.toLowerCase().contains('moira');
            }).toList();

        // If we found female voices, use the first one
        if (femaleVoices.isNotEmpty) {
          final femaleVoice = femaleVoices.first as Map<String, dynamic>;
          final voiceName = femaleVoice['name'] as String? ?? '';

          debugPrint('Setting female voice: $voiceName');
          await _flutterTts!.setVoice({'name': voiceName, 'locale': 'en-US'});
          _isFemaleVoiceSet = true;
        } else {
          // If no explicit female voice, just set a higher pitch
          await _flutterTts!.setPitch(1.5);
          debugPrint('No female voice found, using higher pitch instead');
        }
      }
    } catch (e) {
      debugPrint('Error setting female voice: $e');
      // Fallback to higher pitch
      await _flutterTts!.setPitch(1.5);
    }
  }

  // Speak text
  Future<void> speak(String text) async {
    if (_flutterTts == null) {
      await _initTts();
    }

    if (_flutterTts != null) {
      if (_ttsState == TtsState.playing) {
        await _flutterTts!.stop();
        // Add a small pause between stopping and starting new speech
        await Future.delayed(const Duration(milliseconds: 300));
      }

      await _flutterTts!.speak(text);
      _ttsState = TtsState.playing;

      debugPrint('Speaking: $text');

      // Calculate approximate speaking duration (average speaking rate is ~150 words per minute)
      // This is about 2.5 words per second, or 400ms per word
      final wordCount = text.split(' ').length;
      final estimatedDuration = wordCount * 400;

      // Wait for speech to complete with a small buffer
      await Future.delayed(Duration(milliseconds: estimatedDuration + 500));
    }
  }

  // Stop speaking
  Future<void> stop() async {
    if (_flutterTts != null && _ttsState == TtsState.playing) {
      await _flutterTts!.stop();
      _ttsState = TtsState.stopped;
    }
  }

  // Dispose resources
  Future<void> dispose() async {
    if (_flutterTts != null) {
      await _flutterTts!.stop();
      _ttsState = TtsState.stopped;
    }
  }
}
