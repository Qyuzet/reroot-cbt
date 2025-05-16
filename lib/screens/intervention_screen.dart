import 'package:flutter/material.dart';
import '../services/dynamic_intervention_service.dart';
import '../widgets/intervention_step_card.dart';
import '../widgets/progress_card.dart';

class InterventionScreen extends StatefulWidget {
  const InterventionScreen({super.key});

  @override
  State<InterventionScreen> createState() => _InterventionScreenState();
}

class _InterventionScreenState extends State<InterventionScreen>
    with SingleTickerProviderStateMixin {
  late DynamicInterventionService _interventionService;
  int _currentStep = 0;
  double _progress = 0.0;
  bool _isSessionActive = false;

  // Dynamic step information
  String _currentStepTitle = '';
  String _currentStepDescription = '';

  // Animation controller for smooth transitions
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  // Step icons - will be selected based on step type
  final Map<String, IconData> _stepTypeIcons = {
    'handPosition': Icons.pan_tool,
    'vibration': Icons.vibration,
    'flashlight': Icons.flashlight_on,
    'audio': Icons.music_note,
    'breathe': Icons.air,
    'visualize': Icons.remove_red_eye,
  };

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
    _interventionService = DynamicInterventionService(
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
      onStepInfoChanged: (title, description) {
        // Update step info in the UI
        setState(() {
          _currentStepTitle = title;
          _currentStepDescription = description;
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

  // Get the appropriate icon for the current step
  IconData _getIconForCurrentStep() {
    // Default icon if we can't determine the step type
    if (_currentStepTitle.isEmpty) {
      return Icons.help_outline;
    }

    // Try to determine the step type from the title
    if (_currentStepTitle.toLowerCase().contains('vibration')) {
      return _stepTypeIcons['vibration']!;
    } else if (_currentStepTitle.toLowerCase().contains('flash') ||
        _currentStepTitle.toLowerCase().contains('light')) {
      return _stepTypeIcons['flashlight']!;
    } else if (_currentStepTitle.toLowerCase().contains('hold') ||
        _currentStepTitle.toLowerCase().contains('hand')) {
      return _stepTypeIcons['handPosition']!;
    } else if (_currentStepTitle.toLowerCase().contains('listen') ||
        _currentStepTitle.toLowerCase().contains('sound') ||
        _currentStepTitle.toLowerCase().contains('audio')) {
      return _stepTypeIcons['audio']!;
    } else if (_currentStepTitle.toLowerCase().contains('breath')) {
      return _stepTypeIcons['breathe']!;
    } else if (_currentStepTitle.toLowerCase().contains('visual') ||
        _currentStepTitle.toLowerCase().contains('imagine')) {
      return _stepTypeIcons['visualize']!;
    }

    // Fallback to a generic icon
    return Icons.spa;
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
                          title: _currentStepTitle,
                          description: _currentStepDescription,
                          icon: _getIconForCurrentStep(),
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
