// lib/providers/emoji_provider.dart

/*
 * EMOJI PROVIDER - State Management for Emoji Selection
 * 
 This provider will:

     Store the currently selected emoji (like 😄, 😢, 😠 etc.)

     Update when the user swipes/selects a new emoji on the mood picker

     Help the UI know which emoji is selected at any time
 */

import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateProvider that manages the currently selected emoji
// Defaults to neutral face emoji as the initial state
final selectedEmojiProvider = StateProvider<String>((ref) {
  return '😐'; // Neutral emoji as default
});

// Additional computed providers for common use cases

/// Provider that checks if an emoji has been selected (not default)
final hasSelectedEmojiProvider = Provider<bool>((ref) {
  final emoji = ref.watch(selectedEmojiProvider);
  return emoji != '😐'; // Returns true if user changed from default
});

/// Provider that returns emoji with a fallback for null safety
final safeEmojiProvider = Provider<String>((ref) {
  final emoji = ref.watch(selectedEmojiProvider);
  return emoji.isEmpty ? '😐' : emoji;
});

/// Provider that checks if the current emoji represents a positive mood
final isPositiveMoodProvider = Provider<bool>((ref) {
  final emoji = ref.watch(selectedEmojiProvider);
  const positiveMoods = ['🙂', '😊', '😄', '😁', '🤩', '😍', '🥰'];
  return positiveMoods.contains(emoji);
});

/// Provider that checks if the current emoji represents a negative mood
final isNegativeMoodProvider = Provider<bool>((ref) {
  final emoji = ref.watch(selectedEmojiProvider);
  const negativeMoods = ['😢', '😭', '😠', '😡', '😞', '😔', '🙁'];
  return negativeMoods.contains(emoji);
});

/// Provider that checks if the current emoji represents a neutral mood
final isNeutralMoodProvider = Provider<bool>((ref) {
  final emoji = ref.watch(selectedEmojiProvider);
  const neutralMoods = ['😐', '😑', '🤔', '😶'];
  return neutralMoods.contains(emoji);
});