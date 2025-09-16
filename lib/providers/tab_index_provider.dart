

// This provider helps:

// Track the current selected tab on the main screen (Home, Stats, Profile, etc.)

// Update the selected tab when the user taps on a new one

// Control the navigation between different sections of the app
import 'package:flutter_riverpod/flutter_riverpod.dart';

// StateProvider that manages the currently selected bottom navigation tab index
// Defaults to index 0 (first tab) as the initial state
final selectedTabIndexProvider = StateProvider<int>((ref) {
  return 0; // Start with the first tab (usually Home)
});

// Additional computed providers for common navigation use cases

/// Provider that checks if the Home tab is currently selected (index 0)
final isHomeTabSelectedProvider = Provider<bool>((ref) {
  final tabIndex = ref.watch(selectedTabIndexProvider);
  return tabIndex == 0;
});

/// Provider that checks if the Analytics tab is currently selected (index 1)
final isAnalyticsTabSelectedProvider = Provider<bool>((ref) {
  final tabIndex = ref.watch(selectedTabIndexProvider);
  return tabIndex == 1;
});

/// Provider that checks if the History tab is currently selected (index 2)
final isHistoryTabSelectedProvider = Provider<bool>((ref) {
  final tabIndex = ref.watch(selectedTabIndexProvider);
  return tabIndex == 2;
});

/// Provider that checks if the Settings tab is currently selected (index 3)
final isSettingsTabSelectedProvider = Provider<bool>((ref) {
  final tabIndex = ref.watch(selectedTabIndexProvider);
  return tabIndex == 3;
});

/// Provider that validates if the current tab index is within valid range
final isValidTabIndexProvider = Provider<bool>((ref) {
  final tabIndex = ref.watch(selectedTabIndexProvider);
  return tabIndex >= 0 && tabIndex < 4; // Assuming 4 tabs total
});

/// Provider that returns the previous tab index for navigation history
final previousTabIndexProvider = StateProvider<int>((ref) {
  return 0; // Initialize with first tab
});