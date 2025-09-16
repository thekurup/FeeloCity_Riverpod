

// This provider is used to:

// Store the selected date range (like from 1st July to 15th July)

// Let the user filter mood logs based on date range

// Update the range when user picks new start and end dates

// This will be used heavily in the Filter Section of your app.


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateProvider that manages the selected date range for mood data filtering
// Defaults to the last 7 days (from 7 days ago to today)
final selectedDateRangeProvider = StateProvider<DateTimeRange>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final sevenDaysAgo = today.subtract(const Duration(days: 7));
  
  return DateTimeRange(
    start: sevenDaysAgo,
    end: today,
  );
});

// Additional computed providers for common date range operations

/// Provider that returns the start date of the current range
final startDateProvider = Provider<DateTime>((ref) {
  final dateRange = ref.watch(selectedDateRangeProvider);
  return dateRange.start;
});

/// Provider that returns the end date of the current range
final endDateProvider = Provider<DateTime>((ref) {
  final dateRange = ref.watch(selectedDateRangeProvider);
  return dateRange.end;
});

/// Provider that calculates the duration of the current date range in days
final dateRangeDurationProvider = Provider<int>((ref) {
  final dateRange = ref.watch(selectedDateRangeProvider);
  return dateRange.duration.inDays + 1; // +1 to include both start and end dates
});

/// Provider that checks if the current range includes today
final incluesTodayProvider = Provider<bool>((ref) {
  final dateRange = ref.watch(selectedDateRangeProvider);
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  return dateRange.start.isBefore(today.add(const Duration(days: 1))) &&
         dateRange.end.isAfter(today.subtract(const Duration(days: 1)));
});

/// Provider that formats the date range as a readable string
final dateRangeDisplayProvider = Provider<String>((ref) {
  final dateRange = ref.watch(selectedDateRangeProvider);
  final duration = ref.watch(dateRangeDurationProvider);
  
  // Format dates
  final startFormatted = '${dateRange.start.day}/${dateRange.start.month}/${dateRange.start.year}';
  final endFormatted = '${dateRange.end.day}/${dateRange.end.month}/${dateRange.end.year}';
  
  // Return appropriate display text
  if (duration == 1) {
    return startFormatted; // Single day
  } else if (duration <= 7) {
    return '$duration days ($startFormatted - $endFormatted)';
  } else {
    return '$startFormatted - $endFormatted';
  }
});

/// Provider that checks if the current range is the default 7-day range
final isDefaultRangeProvider = Provider<bool>((ref) {
  final duration = ref.watch(dateRangeDurationProvider);
  final includesTo = ref.watch(incluesTodayProvider);
  
  return duration == 8 && includesTo; // 7 days + today = 8 total days
});

/// Provider that creates preset date ranges for quick selection
final presetDateRangesProvider = Provider<Map<String, DateTimeRange>>((ref) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  
  return {
    'Today': DateTimeRange(start: today, end: today),
    'Yesterday': DateTimeRange(
      start: today.subtract(const Duration(days: 1)),
      end: today.subtract(const Duration(days: 1)),
    ),
    'Last 7 days': DateTimeRange(
      start: today.subtract(const Duration(days: 7)),
      end: today,
    ),
    'Last 30 days': DateTimeRange(
      start: today.subtract(const Duration(days: 30)),
      end: today,
    ),
    'This month': DateTimeRange(
      start: DateTime(now.year, now.month, 1),
      end: today,
    ),
    'Last month': DateTimeRange(
      start: DateTime(now.year, now.month - 1, 1),
      end: DateTime(now.year, now.month, 0), // Last day of previous month
    ),
  };
});