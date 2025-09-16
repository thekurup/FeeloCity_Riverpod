
/*
 * MOOD FILTER PROVIDER - State Management for Mood Data Filtering
 * 
 * This file manages the current filter state for viewing mood logs in the Feelocity app.
 * It provides a centralized way to:
 * - Store the currently selected time period filter (Today, This Week, This Month, All)
 * - Update the filter selection when users change their view preference
 * - Provide a consistent filter state across all components that display mood data
 * 
 
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';

// Enum defining available mood filter options
enum MoodFilter {
  today('Today'),
  thisWeek('This Week'),
  thisMonth('This Month'),
  all('All');

  const MoodFilter(this.displayName);
  final String displayName;

  /// Gets a user-friendly description for each filter
  String get description {
    switch (this) {
      case MoodFilter.today:
        return 'Mood logs from today';
      case MoodFilter.thisWeek:
        return 'Mood logs from the past 7 days';
      case MoodFilter.thisMonth:
        return 'Mood logs from this month';
      case MoodFilter.all:
        return 'All mood logs';
    }
  }

  /// Gets an appropriate icon for each filter
  String get icon {
    switch (this) {
      case MoodFilter.today:
        return '📅';
      case MoodFilter.thisWeek:
        return '📊';
      case MoodFilter.thisMonth:
        return '🗓️';
      case MoodFilter.all:
        return '📈';
    }
  }
}

// StateProvider that manages the current mood filter selection
// Defaults to 'today' as the most commonly used filter
final moodFilterProvider = StateProvider<MoodFilter>((ref) {
  return MoodFilter.today;
});

// Additional computed providers for convenience

/// Provider that returns the display name of the current filter
final currentFilterDisplayNameProvider = Provider<String>((ref) {
  final filter = ref.watch(moodFilterProvider);
  return filter.displayName;
});

/// Provider that returns the description of the current filter
final currentFilterDescriptionProvider = Provider<String>((ref) {
  final filter = ref.watch(moodFilterProvider);
  return filter.description;
});

/// Provider that returns the icon of the current filter
final currentFilterIconProvider = Provider<String>((ref) {
  final filter = ref.watch(moodFilterProvider);
  return filter.icon;
});

/// Provider that checks if the current filter is "Today"
final isFilterTodayProvider = Provider<bool>((ref) {
  final filter = ref.watch(moodFilterProvider);
  return filter == MoodFilter.today;
});

/// Provider that checks if the current filter is "All"
final isFilterAllProvider = Provider<bool>((ref) {
  final filter = ref.watch(moodFilterProvider);
  return filter == MoodFilter.all;
});