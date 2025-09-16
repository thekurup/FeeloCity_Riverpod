// lib/models/mood_stats.dart
import 'mood.dart';
import 'mood_log.dart';

class MoodStats {
  final Map<String, int> moodFrequency; // emoji -> count
  final Map<String, int> contextFrequency; // context -> count
  final DateTime startDate;
  final DateTime endDate;
  final int totalLogs;
  final Mood? dominantMood; // Most frequent mood
  final String? dominantContext; // Most frequent context

  const MoodStats({
    required this.moodFrequency,
    required this.contextFrequency,
    required this.startDate,
    required this.endDate,
    required this.totalLogs,
    this.dominantMood,
    this.dominantContext,
  });

  // Create empty stats
  factory MoodStats.empty() {
    final now = DateTime.now();
    return MoodStats(
      moodFrequency: {},
      contextFrequency: {},
      startDate: now,
      endDate: now,
      totalLogs: 0,
    );
  }

  // Generate stats from a list of mood logs
  factory MoodStats.fromLogs(List<MoodLog> logs, {DateTime? start, DateTime? end}) {
    if (logs.isEmpty) {
      return MoodStats.empty();
    }

    // Filter logs by date range if provided
    final filteredLogs = logs.where((log) {
      if (start != null && log.dateOnly.isBefore(start)) return false;
      if (end != null && log.dateOnly.isAfter(end)) return false;
      return true;
    }).toList();

    if (filteredLogs.isEmpty) {
      return MoodStats.empty();
    }

    // Calculate mood frequency
    final Map<String, int> moodFreq = {};
    final Map<String, int> contextFreq = {};
    final Map<String, Mood> emojiToMood = {}; // To track mood objects

    for (final log in filteredLogs) {
      // Count mood frequency
      moodFreq[log.mood.emoji] = (moodFreq[log.mood.emoji] ?? 0) + 1;
      emojiToMood[log.mood.emoji] = log.mood;

      // Count context frequency
      if (log.context != null) {
        contextFreq[log.context!] = (contextFreq[log.context!] ?? 0) + 1;
      }
    }

    // Find dominant mood and context
    String? dominantMoodEmoji;
    String? dominantContext;
    int maxMoodCount = 0;
    int maxContextCount = 0;

    moodFreq.forEach((emoji, count) {
      if (count > maxMoodCount) {
        maxMoodCount = count;
        dominantMoodEmoji = emoji;
      }
    });

    contextFreq.forEach((context, count) {
      if (count > maxContextCount) {
        maxContextCount = count;
        dominantContext = context;
      }
    });

    // Determine date range
    final dates = filteredLogs.map((log) => log.dateOnly).toList();
    dates.sort();

    return MoodStats(
      moodFrequency: moodFreq,
      contextFrequency: contextFreq,
      startDate: start ?? dates.first,
      endDate: end ?? dates.last,
      totalLogs: filteredLogs.length,
      dominantMood: dominantMoodEmoji != null ? emojiToMood[dominantMoodEmoji] : null,
      dominantContext: dominantContext,
    );
  }

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'moodFrequency': moodFrequency,
      'contextFrequency': contextFrequency,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'totalLogs': totalLogs,
      'dominantMood': dominantMood?.toJson(),
      'dominantContext': dominantContext,
    };
  }

  // Create from JSON
  factory MoodStats.fromJson(Map<String, dynamic> json) {
    return MoodStats(
      moodFrequency: Map<String, int>.from(json['moodFrequency'] as Map),
      contextFrequency: Map<String, int>.from(json['contextFrequency'] as Map),
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      totalLogs: json['totalLogs'] as int,
      dominantMood: json['dominantMood'] != null 
          ? Mood.fromJson(json['dominantMood'] as Map<String, dynamic>)
          : null,
      dominantContext: json['dominantContext'] as String?,
    );
  }

  @override
  String toString() {
    return 'MoodStats(totalLogs: $totalLogs, dominantMood: $dominantMood, dominantContext: $dominantContext)';
  }

  // Helper methods for UI
  List<MapEntry<String, int>> get sortedMoodFrequency {
    final entries = moodFrequency.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  List<MapEntry<String, int>> get sortedContextFrequency {
    final entries = contextFrequency.entries.toList();
    entries.sort((a, b) => b.value.compareTo(a.value));
    return entries;
  }

  // Get percentage for a specific mood
  double getMoodPercentage(String emoji) {
    if (totalLogs == 0) return 0.0;
    final count = moodFrequency[emoji] ?? 0;
    return (count / totalLogs) * 100;
  }

  // Get percentage for a specific context
  double getContextPercentage(String context) {
    if (totalLogs == 0) return 0.0;
    final count = contextFrequency[context] ?? 0;
    return (count / totalLogs) * 100;
  }

  // Check if stats are empty
  bool get isEmpty => totalLogs == 0;

  // Get duration in days
  int get durationInDays {
    return endDate.difference(startDate).inDays + 1;
  }
}
