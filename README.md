# Feelocity - Flutter Advanced State Management Learning Project

> **Week 4 Learning Goal:** Advanced State Management with Riverpod in Flutter

## Project Overview

This project was built as **Week 4** of my Flutter learning journey to practice **Advanced State Management** with Riverpod. Feelocity is a mood tracking app that demonstrates complex provider patterns, state composition, and reactive programming.

## Why I Built This

- **Week 4 Focus:** Advanced State Management with Riverpod
- **Learning Goals:** Complex provider patterns, state composition, reactive architecture
- **Teaching Goal:** Create beginner-friendly examples of advanced Flutter state management concepts
- **Skills Applied:** Provider dependencies, computed state, complex data flows

## Concept Focus - Advanced State Management

This **Week 4 project** demonstrates these **advanced Riverpod concepts**:

### Basic State Management
```dart
// Simple state holder
final selectedEmojiProvider = StateProvider<String>((ref) {
  return '😐'; // Default neutral emoji
});
```

### Complex State with StateNotifier
```dart
// Managing list of mood logs with CRUD operations
final moodLogProvider = StateNotifierProvider<MoodLogNotifier, List<MoodLog>>((ref) => MoodLogNotifier());
```

### Computed/Derived State
```dart
// Automatically calculates filtered data when dependencies change
final filteredMoodLogsProvider = Provider<List<MoodLog>>((ref) {
  final allLogs = ref.watch(moodLogProvider);
  final selectedEmoji = ref.watch(selectedEmojiProvider);
  // Filter logic here...
});
```

### Provider Dependencies & Composition
```dart
// Complex provider chains - one provider depends on multiple others
final filteredMoodLogsProvider = Provider<List<MoodLog>>((ref) {
  final allLogs = ref.watch(moodLogProvider);
  final selectedEmoji = ref.watch(selectedEmojiProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  // Advanced filtering logic combining multiple state sources
});

// Statistics computed from filtered data
final emojiFrequencyProvider = Provider<Map<String, int>>((ref) {
  final filteredLogs = ref.watch(filteredMoodLogsProvider);
  return _calculateFrequency(filteredLogs);
});
```

## Features

- **Mood Logging:** Interactive slider with 5 emotion types (sad to excited)
- **Context Selection:** Tag moods with context (Work, Family, Friends, etc.)
- **Smart Filtering:** Filter by emoji type and date ranges
- **Visual Analytics:** Charts showing mood trends and distributions
- **Data Persistence:** Uses Hive database for local storage
- **Animations:** Lottie animations and custom painted widgets
- **Responsive Design:** Dark/light theme support

## Tech Stack

- **Framework:** Flutter 3.8.1
- **State Management:** Riverpod 2.6.1
- **Database:** Hive (local storage)
- **Charts:** FL Chart 1.0.0  
- **Animations:** Lottie 3.3.1
- **Date Handling:** Intl 0.20.2

## Installation Guide (Step-by-Step for Beginners)

### Step 1: Clone the Repository
```bash
git clone https://github.com/yourusername/feelocity.git
cd feelocity
```

### Step 2: Install Flutter Dependencies
```bash
flutter pub get
```

### Step 3: Run the App
```bash
flutter run
```

Note: Make sure you have Flutter installed and an emulator/device connected!

## Usage Instructions

### 1. Log Your Mood
- Open the app (starts on Home screen)
- Swipe along the curved mood slider
- Select context (Work, Family, etc.) - optional
- Add a note about your feeling - optional  
- Tap "Continue" to save

### 2. View Your Stats
- Tap the floating chart button
- See mood distribution, weekly trends
- Check your most common mood
- View total activity summary

### 3. Filter Your Data
- From Stats screen, tap the filter icon
- Choose specific emoji to filter by
- Select date ranges (Today, This Week, Custom)
- Apply filters to see targeted insights

## File/Folder Explanation

### Models (Data Structure)
```
lib/models/
├── mood.dart          # Single mood type (emoji, label, color)
├── mood_log.dart      # Individual mood entry with date/notes  
└── mood_stats.dart    # Analytics and frequency calculations
```

### Providers (State Management)
```
lib/providers/
├── mood_log_provider.dart      # Main mood data storage (StateNotifier)
├── emoji_provider.dart         # Current selected emoji (StateProvider)
├── date_range_provider.dart    # Filter date ranges (StateProvider)
├── filtered_mood_provider.dart # Computed filtered results (Provider)
├── mood_filter_provider.dart   # Filter UI state (StateProvider)
└── tab_index_provider.dart     # Navigation state (StateProvider)
```

### Screens (UI Pages)
```
lib/screens/
├── home_screen.dart       # Main mood logging interface
├── add_mood_screen.dart   # Detailed mood entry form
├── stats_screen.dart      # Analytics dashboard with charts
└── filter_screen.dart     # Multi-criteria filtering options
```

### Widgets (Reusable Components)
```
lib/widgets/
├── context_tags.dart           # Mood context selection chips
└── swipeable_mood_picker.dart  # Advanced mood selection widget
```

## Screenshots / Demo

*Add screenshots of your app here when available*

## Key Learnings from Week 4

### Advanced State Management Concepts Mastered:
1. **Complex Provider Architecture:** Multi-layered provider dependencies
2. **State Composition:** Combining multiple state sources into computed values
3. **Reactive Programming:** Advanced provider watching and dependency patterns
4. **Data Flow Management:** Complex filtering and transformation logic
5. **Provider Types:** StateProvider, StateNotifierProvider, Provider combinations
6. **Business Logic Separation:** Clean separation of state logic from UI

### Advanced Riverpod Patterns:
- Multiple provider dependencies in computed providers
- StateNotifier with complex CRUD operations  
- Reactive data filtering and transformation
- Provider composition for analytics and statistics
- Complex state interactions between multiple screens

### UI Skills Practiced:
- Custom painting (mood slider, charts)
- Complex animations and gestures
- Form handling and validation
- Date picker integration
- Chart creation and data visualization

## Future Scope

**Next learning goals for this project:**
- Add user authentication (Firebase Auth)
- Implement cloud sync (Firestore)
- Add mood reminders/notifications
- Export data to CSV
- Add more chart types
- Implement mood prediction ML
- Add social features (share moods)

## Beginner Tips

### Understanding Providers:
- **StateProvider:** For simple values (like selected emoji)
- **StateNotifierProvider:** For complex state with methods (like mood logs list)  
- **Provider:** For computed values that depend on other providers

### Key Pattern:
```dart
// 1. Read state in UI with Consumer
Consumer(builder: (context, ref, child) {
  final moods = ref.watch(moodLogProvider);
  return Text('Total: ${moods.length}');
})

// 2. Update state with ref.read()
ref.read(selectedEmojiProvider.notifier).state = '😊';

// 3. Add to complex state
ref.read(moodLogProvider.notifier).addLog(newMoodLog);
```

## Testing

Basic widget test included in `test/widget_test.dart`. 

**To run tests:**
```bash
flutter test
```

## Conclusion

This project successfully demonstrates **Advanced State Management** concepts through a real-world mood tracking application. The combination of multiple provider types, reactive dependencies, and complex state composition provides a solid foundation for understanding Flutter's most powerful state management solution.

**Perfect for:** Flutter developers learning advanced Riverpod patterns, students practicing complex state management, anyone building data-driven Flutter apps.

---

**Built for learning and teaching Flutter + Riverpod**

*This is part of my weekly Flutter learning journey - Week 4 focused on mastering advanced state management patterns with Riverpod.*
