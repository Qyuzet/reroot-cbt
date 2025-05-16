import 'package:flutter/material.dart';

class SessionProgressIndicator extends StatelessWidget {
  final double progress;
  final Color backgroundColor;
  final Color progressColor;
  final double height;
  final double borderRadius;
  final bool showPercentage;
  final TextStyle? percentageTextStyle;
  
  const SessionProgressIndicator({
    super.key,
    required this.progress,
    this.backgroundColor = const Color(0xFFE0E0E0),
    this.progressColor = const Color(0xFF6A8EAE),
    this.height = 16.0,
    this.borderRadius = 8.0,
    this.showPercentage = true,
    this.percentageTextStyle,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final defaultTextStyle = theme.textTheme.bodyMedium?.copyWith(
      fontWeight: FontWeight.bold,
      color: theme.colorScheme.onPrimary,
    );
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Stack(
          alignment: Alignment.center,
          children: [
            // Background
            Container(
              height: height,
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(borderRadius),
              ),
            ),
            
            // Progress
            Align(
              alignment: Alignment.centerLeft,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Container(
                    height: height,
                    width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                    decoration: BoxDecoration(
                      color: progressColor,
                      borderRadius: BorderRadius.circular(borderRadius),
                    ),
                  );
                },
              ),
            ),
            
            // Percentage text
            if (showPercentage)
              Text(
                '${(progress * 100).toInt()}%',
                style: percentageTextStyle ?? defaultTextStyle,
              ),
          ],
        ),
      ],
    );
  }
}
