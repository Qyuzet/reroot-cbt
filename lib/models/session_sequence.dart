import 'dart:math';

enum HandPosition {
  left,
  right,
  both,
}

enum VibrationPattern {
  gentle,
  pulsing,
  escalating,
  rhythmic,
  wave,
}

enum FlashlightPattern {
  steady,
  pulsing,
  strobe,
  fadeInOut,
  morse,
  heartbeat,
}

enum AudioType {
  whitenoise,
  nature,
  meditation,
  breathing,
  heartbeat,
}

class SessionStep {
  final String title;
  final String description;
  final StepType type;
  final Map<String, dynamic> parameters;
  
  SessionStep({
    required this.title,
    required this.description,
    required this.type,
    required this.parameters,
  });
  
  factory SessionStep.fromJson(Map<String, dynamic> json) {
    return SessionStep(
      title: json['title'],
      description: json['description'],
      type: StepType.values.firstWhere(
        (e) => e.toString().split('.').last == json['type'],
        orElse: () => StepType.handPosition,
      ),
      parameters: json['parameters'] ?? {},
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'description': description,
      'type': type.toString().split('.').last,
      'parameters': parameters,
    };
  }
}

enum StepType {
  handPosition,
  vibration,
  flashlight,
  audio,
  breathe,
  visualize,
}

class SessionSequence {
  final String id;
  final String name;
  final String description;
  final List<SessionStep> steps;
  final int difficultyLevel; // 1-5
  final int estimatedDurationSec;
  
  SessionSequence({
    required this.id,
    required this.name,
    required this.description,
    required this.steps,
    required this.difficultyLevel,
    required this.estimatedDurationSec,
  });
  
  factory SessionSequence.fromJson(Map<String, dynamic> json) {
    return SessionSequence(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      steps: (json['steps'] as List)
          .map((step) => SessionStep.fromJson(step))
          .toList(),
      difficultyLevel: json['difficultyLevel'],
      estimatedDurationSec: json['estimatedDurationSec'],
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'steps': steps.map((step) => step.toJson()).toList(),
      'difficultyLevel': difficultyLevel,
      'estimatedDurationSec': estimatedDurationSec,
    };
  }
  
  // Generate a random session sequence for testing
  static SessionSequence generateRandom() {
    final random = Random();
    final steps = <SessionStep>[];
    
    // Add hand position step
    final handPositions = HandPosition.values;
    final randomHandPosition = handPositions[random.nextInt(handPositions.length)];
    steps.add(
      SessionStep(
        title: 'Hold Phone ${randomHandPosition.toString().split('.').last.capitalize()}',
        description: 'Hold your phone with your ${randomHandPosition.toString().split('.').last} hand, then shake gently to confirm',
        type: StepType.handPosition,
        parameters: {
          'position': randomHandPosition.toString().split('.').last,
          'durationSec': 5 + random.nextInt(10),
        },
      ),
    );
    
    // Add vibration step
    final vibrationPatterns = VibrationPattern.values;
    final randomVibrationPattern = vibrationPatterns[random.nextInt(vibrationPatterns.length)];
    steps.add(
      SessionStep(
        title: 'Feel ${randomVibrationPattern.toString().split('.').last.capitalize()} Vibrations',
        description: 'Focus on the ${randomVibrationPattern.toString().split('.').last} vibration pattern and your breath',
        type: StepType.vibration,
        parameters: {
          'pattern': randomVibrationPattern.toString().split('.').last,
          'intensity': 0.5 + random.nextDouble() * 0.5,
          'durationSec': 5 + random.nextInt(10),
          'pulseCount': 3 + random.nextInt(5),
        },
      ),
    );
    
    // Add flashlight step
    final flashlightPatterns = FlashlightPattern.values;
    final randomFlashlightPattern = flashlightPatterns[random.nextInt(flashlightPatterns.length)];
    steps.add(
      SessionStep(
        title: 'Prepare for Light Therapy',
        description: 'Position the phone so the flash faces your closed eyes, then shake to confirm',
        type: StepType.handPosition,
        parameters: {
          'position': 'facing_eyes',
          'durationSec': 3 + random.nextInt(5),
        },
      ),
    );
    
    steps.add(
      SessionStep(
        title: '${randomFlashlightPattern.toString().split('.').last.capitalize()} Light Therapy',
        description: 'The flashlight will activate with a ${randomFlashlightPattern.toString().split('.').last} pattern. Keep your eyes closed.',
        type: StepType.flashlight,
        parameters: {
          'pattern': randomFlashlightPattern.toString().split('.').last,
          'intensity': 0.5 + random.nextDouble() * 0.5,
          'durationSec': 5 + random.nextInt(10),
          'pulseCount': 4 + random.nextInt(4),
        },
      ),
    );
    
    // Add audio step
    final audioTypes = AudioType.values;
    final randomAudioType = audioTypes[random.nextInt(audioTypes.length)];
    steps.add(
      SessionStep(
        title: 'Listen to ${randomAudioType.toString().split('.').last.capitalize()} Sounds',
        description: 'Close your eyes and focus on the calming ${randomAudioType.toString().split('.').last} sounds',
        type: StepType.audio,
        parameters: {
          'audioType': randomAudioType.toString().split('.').last,
          'volume': 0.7 + random.nextDouble() * 0.3,
          'durationSec': 10 + random.nextInt(20),
        },
      ),
    );
    
    // Calculate total duration
    final totalDuration = steps.fold<int>(
      0,
      (sum, step) => sum + (step.parameters['durationSec'] as int),
    );
    
    return SessionSequence(
      id: 'random_${DateTime.now().millisecondsSinceEpoch}',
      name: 'Dynamic Session ${random.nextInt(100)}',
      description: 'A dynamically generated session sequence',
      steps: steps,
      difficultyLevel: 1 + random.nextInt(5),
      estimatedDurationSec: totalDuration,
    );
  }
  
  // Predefined session sequences for different levels
  static List<SessionSequence> getPredefinedSequences() {
    return [
      _getBeginnerSequence(),
      _getIntermediateSequence(),
      _getAdvancedSequence(),
    ];
  }
  
  static SessionSequence _getBeginnerSequence() {
    return SessionSequence(
      id: 'beginner_1',
      name: 'Beginner Sequence',
      description: 'A gentle introduction to the intervention techniques',
      steps: [
        SessionStep(
          title: 'Hold Phone Left',
          description: 'Hold your phone with your left hand, then shake gently to confirm',
          type: StepType.handPosition,
          parameters: {
            'position': 'left',
            'durationSec': 8,
          },
        ),
        SessionStep(
          title: 'Feel Gentle Vibrations',
          description: 'Focus on the gentle vibration pattern and your breath',
          type: StepType.vibration,
          parameters: {
            'pattern': 'gentle',
            'intensity': 0.6,
            'durationSec': 10,
            'pulseCount': 5,
          },
        ),
        SessionStep(
          title: 'Prepare for Light Therapy',
          description: 'Position the phone so the flash faces your closed eyes, then shake to confirm',
          type: StepType.handPosition,
          parameters: {
            'position': 'facing_eyes',
            'durationSec': 5,
          },
        ),
        SessionStep(
          title: 'Pulsing Light Therapy',
          description: 'The flashlight will activate with a pulsing pattern. Keep your eyes closed.',
          type: StepType.flashlight,
          parameters: {
            'pattern': 'pulsing',
            'intensity': 0.7,
            'durationSec': 8,
            'pulseCount': 6,
          },
        ),
        SessionStep(
          title: 'Listen to Nature Sounds',
          description: 'Close your eyes and focus on the calming nature sounds',
          type: StepType.audio,
          parameters: {
            'audioType': 'nature',
            'volume': 0.8,
            'durationSec': 15,
          },
        ),
      ],
      difficultyLevel: 1,
      estimatedDurationSec: 46,
    );
  }
  
  static SessionSequence _getIntermediateSequence() {
    return SessionSequence(
      id: 'intermediate_1',
      name: 'Intermediate Sequence',
      description: 'A balanced intervention for those with some experience',
      steps: [
        SessionStep(
          title: 'Hold Phone Right',
          description: 'Hold your phone with your right hand, then shake gently to confirm',
          type: StepType.handPosition,
          parameters: {
            'position': 'right',
            'durationSec': 8,
          },
        ),
        SessionStep(
          title: 'Feel Rhythmic Vibrations',
          description: 'Focus on the rhythmic vibration pattern and your breath',
          type: StepType.vibration,
          parameters: {
            'pattern': 'rhythmic',
            'intensity': 0.7,
            'durationSec': 12,
            'pulseCount': 6,
          },
        ),
        SessionStep(
          title: 'Prepare for Light Therapy',
          description: 'Position the phone so the flash faces your closed eyes, then shake to confirm',
          type: StepType.handPosition,
          parameters: {
            'position': 'facing_eyes',
            'durationSec': 5,
          },
        ),
        SessionStep(
          title: 'FadeInOut Light Therapy',
          description: 'The flashlight will activate with a fade in/out pattern. Keep your eyes closed.',
          type: StepType.flashlight,
          parameters: {
            'pattern': 'fadeInOut',
            'intensity': 0.8,
            'durationSec': 10,
            'pulseCount': 7,
          },
        ),
        SessionStep(
          title: 'Listen to Meditation Sounds',
          description: 'Close your eyes and focus on the calming meditation sounds',
          type: StepType.audio,
          parameters: {
            'audioType': 'meditation',
            'volume': 0.8,
            'durationSec': 20,
          },
        ),
      ],
      difficultyLevel: 3,
      estimatedDurationSec: 55,
    );
  }
  
  static SessionSequence _getAdvancedSequence() {
    return SessionSequence(
      id: 'advanced_1',
      name: 'Advanced Sequence',
      description: 'A challenging intervention for experienced users',
      steps: [
        SessionStep(
          title: 'Hold Phone Both Hands',
          description: 'Hold your phone with both hands, then shake gently to confirm',
          type: StepType.handPosition,
          parameters: {
            'position': 'both',
            'durationSec': 10,
          },
        ),
        SessionStep(
          title: 'Feel Wave Vibrations',
          description: 'Focus on the wave vibration pattern and your breath',
          type: StepType.vibration,
          parameters: {
            'pattern': 'wave',
            'intensity': 0.9,
            'durationSec': 15,
            'pulseCount': 8,
          },
        ),
        SessionStep(
          title: 'Prepare for Light Therapy',
          description: 'Position the phone so the flash faces your closed eyes, then shake to confirm',
          type: StepType.handPosition,
          parameters: {
            'position': 'facing_eyes',
            'durationSec': 5,
          },
        ),
        SessionStep(
          title: 'Heartbeat Light Therapy',
          description: 'The flashlight will activate with a heartbeat pattern. Keep your eyes closed.',
          type: StepType.flashlight,
          parameters: {
            'pattern': 'heartbeat',
            'intensity': 0.9,
            'durationSec': 12,
            'pulseCount': 8,
          },
        ),
        SessionStep(
          title: 'Listen to Breathing Guidance',
          description: 'Close your eyes and follow the breathing guidance',
          type: StepType.audio,
          parameters: {
            'audioType': 'breathing',
            'volume': 0.9,
            'durationSec': 25,
          },
        ),
      ],
      difficultyLevel: 5,
      estimatedDurationSec: 67,
    );
  }
}

extension StringExtension on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
