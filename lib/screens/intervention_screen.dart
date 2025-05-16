import 'package:flutter/material.dart';
import '../services/intervention_service.dart';
import '../utils/constants.dart';
import '../widgets/progress_indicator.dart';
import '../widgets/intervention_step.dart';

class InterventionScreen extends StatefulWidget {
  const InterventionScreen({super.key});

  @override
  State<InterventionScreen> createState() => _InterventionScreenState();
}

class _InterventionScreenState extends State<InterventionScreen> {
  late InterventionService _interventionService;
  int _currentStep = 0;
  double _progress = 0.0;
  bool _isSessionActive = false;

  // Step icons
  final List<IconData> _stepIcons = [
    Icons.vibration,
    Icons.pan_tool,
    Icons.flashlight_on,
    Icons.visibility_off,
    Icons.music_note,
  ];

  // Step descriptions
  final List<String> _stepDescriptions = [
    'Hold your phone with your left hand, then shake gently to confirm',
    'Feel the vibration and focus on your breath',
    'Position the phone so the flash faces your closed eyes, then shake to confirm',
    'The flashlight will activate briefly for light therapy',
    'Listen to the calming sound and relax',
  ];

  @override
  void initState() {
    super.initState();
    _initializeInterventionService();
  }

  void _initializeInterventionService() {
    _interventionService = InterventionService(
      context: context,
      onStepChanged: (step) {
        setState(() {
          _currentStep = step;
        });
      },
      onProgressChanged: (progress) {
        setState(() {
          _progress = progress;
        });
      },
      onSessionCompleted: _handleSessionCompleted,
      onSessionAborted: _handleSessionAborted,
    );
  }

  void _startSession() {
    setState(() {
      _isSessionActive = true;
    });
    _interventionService.startSession();
  }

  void _abortSession() {
    _interventionService.abortSession();
  }

  void _handleSessionCompleted() {
    setState(() {
      _isSessionActive = false;
    });

    // Show completion dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => AlertDialog(
            title: const Text('Session Completed'),
            content: const Text(
              'Great job! You\'ve successfully completed the intervention session.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context); // Close dialog
                  Navigator.pop(context); // Return to home screen
                },
                child: const Text('Return to Home'),
              ),
            ],
          ),
    );
  }

  void _handleSessionAborted() {
    setState(() {
      _isSessionActive = false;
    });
  }

  @override
  void dispose() {
    _interventionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Intervention Session'),
        automaticallyImplyLeading: !_isSessionActive,
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Session Progress', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 8),
                  SessionProgressIndicator(
                    progress: _progress,
                    progressColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.primary.withAlpha(
                      51,
                    ), // 0.2 opacity = 51 alpha
                  ),
                ],
              ),
            ),

            // Divider
            Divider(color: theme.dividerColor, thickness: 1),

            // Steps list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: AppConstants.interventionSteps.length,
                itemBuilder: (context, index) {
                  final isActive = index == _currentStep && _isSessionActive;
                  final isCompleted = index < _currentStep;

                  return InterventionStepWidget(
                    title: AppConstants.interventionSteps[index],
                    description: _stepDescriptions[index],
                    icon: _stepIcons[index],
                    isActive: isActive,
                    isCompleted: isCompleted,
                  );
                },
              ),
            ),

            // Action buttons
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (!_isSessionActive)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _startSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: theme.colorScheme.onPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Start Session',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _abortSession,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Break',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
