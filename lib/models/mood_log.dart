// lib/models/mood_log.dart
import 'mood.dart';

class MoodLog {
  final String id; // Unique identifier
  final Mood mood;
  final DateTime date;
  final String? note; // Optional note
  final DateTime timestamp; // When the log was created
  final String? context; // Context like 'Work', 'Family', etc.

  const MoodLog({
    required this.id,
    required this.mood,
    required this.date,
    this.note,
    required this.timestamp,
    this.context,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mood': mood.toJson(),
      'date': date.toIso8601String(),
      'note': note,
      'timestamp': timestamp.toIso8601String(),
      'context': context,
    };
  }

  // Create from JSON
  factory MoodLog.fromJson(Map<String, dynamic> json) {
    return MoodLog(
      id: json['id'] as String,
      mood: Mood.fromJson(json['mood'] as Map<String, dynamic>),
      date: DateTime.parse(json['date'] as String),
      note: json['note'] as String?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      context: json['context'] as String?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is MoodLog &&
        other.id == id &&
        other.mood == mood &&
        other.date == date &&
        other.note == note &&
        other.timestamp == timestamp &&
        other.context == context;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        mood.hashCode ^
        date.hashCode ^
        note.hashCode ^
        timestamp.hashCode ^
        context.hashCode;
  }

  @override
  String toString() {
    return 'MoodLog(id: $id, mood: $mood, date: $date, note: $note, timestamp: $timestamp, context: $context)';
  }

  // Create a copy with modified fields
  MoodLog copyWith({
    String? id,
    Mood? mood,
    DateTime? date,
    String? note,
    DateTime? timestamp,
    String? context,
  }) {
    return MoodLog(
      id: id ?? this.id,
      mood: mood ?? this.mood,
      date: date ?? this.date,
      note: note ?? this.note,
      timestamp: timestamp ?? this.timestamp,
      context: context ?? this.context,
    );
  }

  // Helper method to get date without time
  DateTime get dateOnly {
    return DateTime(date.year, date.month, date.day);
  }

  // Helper method to check if log is from today
  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return dateOnly == today;
  }

  // Helper method to check if log is from this week
  bool get isThisWeek {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final startOfWeekDate = DateTime(startOfWeek.year, startOfWeek.month, startOfWeek.day);
    return dateOnly.isAfter(startOfWeekDate.subtract(const Duration(days: 1)));
  }
}