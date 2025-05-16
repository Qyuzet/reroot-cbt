import 'package:flutter/material.dart';

class InterventionStepWidget extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool isActive;
  final bool isCompleted;
  
  const InterventionStepWidget({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
    this.isActive = false,
    this.isCompleted = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Determine colors based on step state
    final Color backgroundColor = isActive
        ? theme.colorScheme.primary.withOpacity(0.1)
        : isCompleted
            ? theme.colorScheme.secondary.withOpacity(0.1)
            : theme.colorScheme.surface;
    
    final Color iconColor = isActive
        ? theme.colorScheme.primary
        : isCompleted
            ? theme.colorScheme.secondary
            : theme.colorScheme.onSurface.withOpacity(0.6);
    
    final Color textColor = isActive
        ? theme.colorScheme.primary
        : isCompleted
            ? theme.colorScheme.secondary
            : theme.colorScheme.onSurface;
    
    return Card(
      elevation: isActive ? 2 : 1,
      color: backgroundColor,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isActive
            ? BorderSide(color: theme.colorScheme.primary, width: 2)
            : BorderSide.none,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Step icon
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            
            // Step content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: textColor.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ),
            
            // Status indicator
            if (isCompleted)
              const Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }
}
