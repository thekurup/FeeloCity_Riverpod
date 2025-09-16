// lib/models/mood.dart
import 'package:flutter/material.dart';

class Mood {
  final String emoji;
  final String label;
  final Color color;

  const Mood({
    required this.emoji,
    required this.label,
    required this.color,
  });

  // Convert to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'emoji': emoji,
      'label': label,
      'color': color.value, // Store color as int value
    };
  }

  // Create from JSON
  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      emoji: json['emoji'] as String,
      label: json['label'] as String,
      color: Color(json['color'] as int),
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Mood &&
        other.emoji == emoji &&
        other.label == label &&
        other.color == color;
  }

  @override
  int get hashCode => emoji.hashCode ^ label.hashCode ^ color.hashCode;

  @override
  String toString() {
    return 'Mood(emoji: $emoji, label: $label, color: $color)';
  }

  // Create a copy with modified fields
  Mood copyWith({
    String? emoji,
    String? label,
    Color? color,
  }) {
    return Mood(
      emoji: emoji ?? this.emoji,
      label: label ?? this.label,
      color: color ?? this.color,
    );
  }
}