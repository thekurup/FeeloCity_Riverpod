

/*
 * MOOD LOG PROVIDER - State Management for Mood Tracking
 * 
 * This file manages the global state of all mood logs in the Feelocity app.
 * It provides a centralized way to:
 * - Store and maintain a list of all user mood entries (MoodLog objects)
 * - Add new mood logs when users log their feelings
 * - Delete specific mood logs by ID
 * - Update existing mood logs (for future editing features)
 * 
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/mood_log.dart';

// StateNotifier class that manages the list of mood logs
class MoodLogNotifier extends StateNotifier<List<MoodLog>> {
  // Initialize with an empty list of mood logs
  MoodLogNotifier() : super([]);

  /// Adds a new mood log to the state
  /// Creates a new list with the added log to maintain immutability
  void addLog(MoodLog log) {
    // Create new list with the new log added
    // This ensures immutability and proper state updates
    state = [...state, log];
  }

  /// Deletes a mood log by its unique ID
  /// Returns true if log was found and deleted, false otherwise
  bool deleteLog(String id) {
    final initialLength = state.length;
    
    // Filter out the log with the matching ID
    state = state.where((log) => log.id != id).toList();
    
    // Return true if a log was actually removed
    return state.length < initialLength;
  }

  /// Updates an existing mood log
  /// Finds the log by ID and replaces it with the updated version
  /// Returns true if log was found and updated, false otherwise
  bool updateLog(MoodLog updatedLog) {
    final index = state.indexWhere((log) => log.id == updatedLog.id);
    
    if (index == -1) {
      // Log with this ID doesn't exist
      return false;
    }
    
    // Create new list with the updated log
    final updatedList = [...state];
    updatedList[index] = updatedLog;
    state = updatedList;
    
    return true;
  }

  /// Gets a specific mood log by ID
  /// Returns null if not found
  MoodLog? getLogById(String id) {
    try {
      return state.firstWhere((log) => log.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Gets mood logs for a specific date
  /// Returns a list of logs that match the given date (ignoring time)
  List<MoodLog> getLogsByDate(DateTime date) {
    final targetDate = DateTime(date.year, date.month, date.day);
    return state.where((log) => log.dateOnly == targetDate).toList();
  }

  /// Gets mood logs from today
  List<MoodLog> getTodaysLogs() {
    return state.where((log) => log.isToday).toList();
  }

  /// Gets mood logs from this week
  List<MoodLog> getThisWeeksLogs() {
    return state.where((log) => log.isThisWeek).toList();
  }

  /// Gets logs within a date range (inclusive)
  List<MoodLog> getLogsByDateRange(DateTime startDate, DateTime endDate) {
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    
    return state.where((log) {
      final logDate = log.dateOnly;
      return (logDate.isAtSameMomentAs(start) || logDate.isAfter(start)) &&
             (logDate.isAtSameMomentAs(end) || logDate.isBefore(end));
    }).toList();
  }

  /// Clears all mood logs
  /// Useful for testing or user data reset
  void clearAllLogs() {
    state = [];
  }

  /// Gets total count of logs
  int get totalLogs => state.length;

  /// Checks if there are any logs
  bool get hasLogs => state.isNotEmpty;

  /// Gets the most recent mood log
  MoodLog? get mostRecentLog {
    if (state.isEmpty) return null;
    
    // Sort by timestamp descending and return the first (most recent)
    final sortedLogs = [...state];
    sortedLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return sortedLogs.first;
  }
}

// Provider that exposes the MoodLogNotifier to the widget tree
// This is the main provider that widgets will consume
final moodLogProvider = StateNotifierProvider<MoodLogNotifier, List<MoodLog>>(
  (ref) => MoodLogNotifier(),
);

// Additional computed providers for common use cases
// These providers automatically update when moodLogProvider changes

/// Provider for today's mood logs
final todaysMoodLogsProvider = Provider<List<MoodLog>>((ref) {
  final logs = ref.watch(moodLogProvider);
  return logs.where((log) => log.isToday).toList();
});

/// Provider for this week's mood logs
final thisWeeksMoodLogsProvider = Provider<List<MoodLog>>((ref) {
  final logs = ref.watch(moodLogProvider);
  return logs.where((log) => log.isThisWeek).toList();
});

/// Provider for the total count of logs
final totalLogsCountProvider = Provider<int>((ref) {
  final logs = ref.watch(moodLogProvider);
  return logs.length;
});

/// Provider for checking if any logs exist
final hasLogsProvider = Provider<bool>((ref) {
  final logs = ref.watch(moodLogProvider);
  return logs.isNotEmpty;
});

/// Provider for the most recent mood log
final mostRecentLogProvider = Provider<MoodLog?>((ref) {
  final logs = ref.watch(moodLogProvider);
  if (logs.isEmpty) return null;
  
  final sortedLogs = [...logs];
  sortedLogs.sort((a, b) => b.timestamp.compareTo(a.timestamp));
  return sortedLogs.first;
});