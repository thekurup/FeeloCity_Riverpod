// This is a computed provider that:

// Combines:

// Mood logs (mood_log_provider)

// Selected emoji (emoji_provider)

// Selected date range (date_range_provider)

// Filters the mood logs based on:

// Emoji (if any is selected)

// Date range (from → to)

// This gives the final list that shows up on the filter screen.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_log.dart';
import 'mood_log_provider.dart';
import 'emoji_provider.dart';
import 'date_range_provider.dart';

// Computed provider that returns filtered mood logs based on active filters
final filteredMoodLogsProvider = Provider<List<MoodLog>>((ref) {
  // Watch all relevant filter providers
  final allMoodLogs = ref.watch(moodLogProvider);
  final selectedEmoji = ref.watch(selectedEmojiProvider);
  final selectedDateRange = ref.watch(selectedDateRangeProvider);
  
  // Start with all mood logs
  List<MoodLog> filteredLogs = allMoodLogs;
  
  // Apply emoji filter if a specific emoji is selected (not default neutral)
  if (selectedEmoji != '😐') {
    filteredLogs = filteredLogs.where((log) {
      // Filter logs that match the selected emoji
      return log.mood.emoji == selectedEmoji;
    }).toList();
  }
  
  // Apply date range filter
  filteredLogs = filteredLogs.where((log) {
    // Get the date part of the log (using the helper method from MoodLog)
    final logDate = log.dateOnly;
    
    // Check if log date falls within the selected date range (inclusive)
    return (logDate.isAtSameMomentAs(selectedDateRange.start) || logDate.isAfter(selectedDateRange.start)) &&
           (logDate.isAtSameMomentAs(selectedDateRange.end) || logDate.isBefore(selectedDateRange.end.add(const Duration(days: 1))));
  }).toList();
  
  // Sort filtered logs by timestamp (most recent first)
  filteredLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  
  return filteredLogs;
});

// Additional computed providers for filtered data insights

/// Provider that returns the count of filtered mood logs
final filteredMoodCountProvider = Provider<int>((ref) {
  final filteredLogs = ref.watch(filteredMoodLogsProvider);
  return filteredLogs.length;
});

/// Provider that checks if any filters are currently active
final hasActiveFiltersProvider = Provider<bool>((ref) {
  final selectedEmoji = ref.watch(selectedEmojiProvider);
  
  // Check if emoji filter is active (not default neutral)
  final hasEmojiFilter = selectedEmoji != '😐';
  
  // Note: Date range filter checking can be added here if needed
  // For now, just check emoji filter
  return hasEmojiFilter;
});

/// Provider that returns filtered logs grouped by date
final filteredLogsByDateProvider = Provider<Map<DateTime, List<MoodLog>>>((ref) {
  final filteredLogs = ref.watch(filteredMoodLogsProvider);
  final Map<DateTime, List<MoodLog>> groupedLogs = {};
  
  for (final log in filteredLogs) {
    // Group by date only (using the helper method from MoodLog)
    final dateKey = log.dateOnly;
    
    if (groupedLogs.containsKey(dateKey)) {
      groupedLogs[dateKey]!.add(log);
    } else {
      groupedLogs[dateKey] = [log];
    }
  }
  
  return groupedLogs;
});

/// Provider that calculates the average mood rating from filtered logs
final filteredAverageMoodProvider = Provider<double?>((ref) {
  final filteredLogs = ref.watch(filteredMoodLogsProvider);
  
  if (filteredLogs.isEmpty) return null;
  
  // Calculate average mood rating from filtered logs
  // Map emoji to numeric rating for averaging
  final totalRating = filteredLogs.fold<double>(0.0, (sum, log) {
    // Map emoji to rating (adjust mapping based on your emoji system)
    switch (log.mood.emoji) {
      case '😢': return sum + 1.0;
      case '😠': return sum + 2.0;
      case '😐': return sum + 3.0;
      case '🙂': return sum + 4.0;
      case '🤩': return sum + 5.0;
      default: return sum + 3.0; // Default to neutral
    }
  });
  
  return totalRating / filteredLogs.length;
});

/// Provider that returns the most recent filtered mood log
final mostRecentFilteredLogProvider = Provider<MoodLog?>((ref) {
  final filteredLogs = ref.watch(filteredMoodLogsProvider);
  return filteredLogs.isNotEmpty ? filteredLogs.first : null;
});