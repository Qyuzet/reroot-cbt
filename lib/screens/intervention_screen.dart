import 'package:flutter/material.dart';
import '../services/intervention_service.dart';
import '../utils/constants.dart';
import '../widgets/intervention_step_card.dart';
import '../widgets/progress_card.dart';
import '../theme/app_theme.dart';

class InterventionScreen extends StatefulWidget {
  const InterventionScreen({super.key});

  @override
  State<InterventionScreen> createState() => _InterventionScreenState();
}

class _InterventionScreenState extends State<InterventionScreen>
    with SingleTickerProviderStateMixin {
  late InterventionService _interventionService;
  int _currentStep = 0;
  double _progress = 0.0;
  bool _isSessionActive = false;

  // Animation controller for smooth transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Step icons
  final List<IconData> _stepIcons = [
    Icons.pan_tool,
    Icons.vibration,
    Icons.flashlight_on_outlined,
    Icons.flashlight_on,
    Icons.music_note,
  ];

  // Step descriptions
  final List<String> _stepDescriptions = [
    'Hold your phone with your left hand, then shake gently to confirm',
    'Feel the vibration and focus on your breath with each pulse',
    'Position the phone so the flash faces your closed eyes, then shake to confirm',
    'The flashlight will activate in a pattern for light therapy',
    'Listen to the calming sound and relax your mind',
  ];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeInterventionService();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _animationController.forward();
  }

  void _initializeInterventionService() {
    _interventionService = InterventionService(
      context: context,
      onStepChanged: (step) {
        setState(() {
          _currentStep = step;
        });
        // Animate transition between steps
        _animationController.reset();
        _animationController.forward();
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

  Future<void> _abortSession() async {
    await _interventionService.abortSession();
  }

  void _handleSessionCompleted() {
    setState(() {
      _isSessionActive = false;
    });

    // Show completion dialog with beautiful styling
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final theme = Theme.of(context);
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 0,
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: theme.colorScheme.primary.withOpacity(0.2),
                  blurRadius: 15,
                  spreadRadius: 0,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle_outline,
                  color: Colors.green,
                  size: 70,
                ),
                const SizedBox(height: 20),
                Text(
                  'Session Completed',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Great job! You\'ve successfully completed the intervention session.',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close dialog
                    Navigator.pop(context); // Return to home screen
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: const Text(
                    'Return to Home',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _handleSessionAborted() {
    setState(() {
      _isSessionActive = false;
    });
  }

  Future<bool> _onWillPop() async {
    if (_isSessionActive) {
      // Show confirmation dialog
      final shouldPop = await showDialog<bool>(
        context: context,
        builder: (context) {
          final theme = Theme.of(context);
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            elevation: 0,
            backgroundColor: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withOpacity(0.2),
                    blurRadius: 15,
                    spreadRadius: 0,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.amber,
                    size: 70,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'End Session?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Are you sure you want to end the current session? Your progress will be saved.',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(height: 1.5),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: const Text('Cancel'),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _abortSession();
                          Navigator.pop(context, true);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: const Text('End Session'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      );
      return shouldPop ?? false;
    }
    return true;
  }

  @override
  void dispose() {
    _animationController.dispose();
    _interventionService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Intervention Session'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          automaticallyImplyLeading: !_isSessionActive,
          actions: [
            if (_isSessionActive)
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => _onWillPop(),
              ),
          ],
        ),
        body: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                theme.colorScheme.primary.withOpacity(0.8),
                theme.colorScheme.primaryContainer.withOpacity(0.6),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Progress card
                  ProgressCard(
                    progress: _progress,
                    progressColor: theme.colorScheme.primary,
                    backgroundColor: theme.colorScheme.primary.withOpacity(0.2),
                  ),

                  const SizedBox(height: 30),

                  // Active step card with fade animation
                  if (_isSessionActive)
                    Expanded(
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: InterventionStepCard(
                          stepNumber: 'Step ${_currentStep + 1}',
                          title: AppConstants.interventionSteps[_currentStep],
                          description: _stepDescriptions[_currentStep],
                          icon: _stepIcons[_currentStep],
                          isActive: true,
                          progress: _progress,
                        ),
                      ),
                    )
                  else
                    Expanded(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.spa_outlined,
                              size: 80,
                              color: theme.colorScheme.onPrimary.withOpacity(
                                0.9,
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              'Ready to Begin',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: theme.colorScheme.onPrimary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'This session will guide you through a series of mindfulness exercises',
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.colorScheme.onPrimary.withOpacity(
                                  0.9,
                                ),
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Action button
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: theme.colorScheme.primary.withOpacity(0.2),
                          blurRadius: 8,
                          spreadRadius: 0,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed:
                          _isSessionActive ? () => _onWillPop() : _startSession,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            _isSessionActive
                                ? Colors.red
                                : theme.colorScheme.primary,
                        foregroundColor: theme.colorScheme.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        _isSessionActive ? 'End Session' : 'Start Session',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
