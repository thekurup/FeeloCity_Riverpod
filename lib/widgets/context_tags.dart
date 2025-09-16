// lib/widgets/context_tags.dart
import 'package:flutter/material.dart';

class ContextTags extends StatelessWidget {
  final String? selectedContext;
  final Function(String) onContextSelected;

  const ContextTags({
    super.key,
    required this.selectedContext,
    required this.onContextSelected,
  });

  // Context options with icons and colors
  static const List<Map<String, dynamic>> _contexts = [
    {
      'label': 'Work',
      'icon': Icons.work_outline,
      'color': Color(0xFF5C6BC0), // Indigo
    },
    {
      'label': 'Family',
      'icon': Icons.family_restroom,
      'color': Color(0xFFEC407A), // Pink
    },
    {
      'label': 'Friends',
      'icon': Icons.people_outline,
      'color': Color(0xFF42A5F5), // Blue
    },
    {
      'label': 'Alone',
      'icon': Icons.person_outline,
      'color': Color(0xFF66BB6A), // Green
    },
    {
      'label': 'Health',
      'icon': Icons.favorite_outline,
      'color': Color(0xFFEF5350), // Red
    },
    {
      'label': 'Exercise',
      'icon': Icons.fitness_center,
      'color': Color(0xFFFF7043), // Deep Orange
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _contexts.map((context) {
        final isSelected = selectedContext == context['label'];
        
        return _buildContextChip(
          context: context,
          isSelected: isSelected,
          theme: theme,
        );
      }).toList(),
    );
  }

  Widget _buildContextChip({
    required Map<String, dynamic> context,
    required bool isSelected,
    required ThemeData theme,
  }) {
    final colorScheme = theme.colorScheme;
    final contextColor = context['color'] as Color;
    
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onContextSelected(context['label']),
          borderRadius: BorderRadius.circular(24),
          splashColor: contextColor.withOpacity(0.1),
          highlightColor: contextColor.withOpacity(0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 250),
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? LinearGradient(
                      colors: [
                        contextColor.withOpacity(0.2),
                        contextColor.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected
                  ? null
                  : colorScheme.surfaceContainerHigh.withOpacity(0.4),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: isSelected
                    ? contextColor.withOpacity(0.6)
                    : colorScheme.outline.withOpacity(0.25),
                width: isSelected ? 2 : 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: contextColor.withOpacity(0.25),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                      ),
                      BoxShadow(
                        color: contextColor.withOpacity(0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: colorScheme.shadow.withOpacity(0.03),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  context['icon'],
                  size: 20,
                  color: isSelected
                      ? contextColor
                      : colorScheme.onSurface.withOpacity(0.7),
                ),
                const SizedBox(width: 8),
                Text(
                  context['label'],
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: 15,
                    color: isSelected
                        ? contextColor
                        : colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}