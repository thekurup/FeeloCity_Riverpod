// lib/screens/stats_screen.dart
//
// This screen displays visual analytics and trends for mood tracking data.
// It provides users with insights into their emotional patterns through:
// - Date range summaries showing filtered periods
// - Mood distribution charts showing frequency of each emotion
// - Weekly trend analysis with mood score progression
// - Most common mood identification
// - Total activity metrics
//
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'dart:ui' as ui;

// Import providers for data access
import '../providers/mood_log_provider.dart';
import '../providers/emoji_provider.dart';
import '../providers/date_range_provider.dart';
import '../models/mood_log.dart';
import 'filter_screen.dart'; // Import the filter screen

// Computed provider that calculates emoji frequency distribution from filtered mood logs
final emojiFrequencyProvider = Provider<Map<String, int>>((ref) {
  // Get all mood logs and current filters
  final allLogs = ref.watch(moodLogProvider);
  final selectedEmoji = ref.watch(selectedEmojiProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  
  // Filter logs based on active filters
  List<MoodLog> filteredLogs = allLogs;
  
  // Apply emoji filter if not neutral (default state)
  if (selectedEmoji != '😐') {
    filteredLogs = filteredLogs.where((log) => log.mood.emoji == selectedEmoji).toList();
  }
  
  // Apply date range filter
  filteredLogs = filteredLogs.where((log) {
    final logDate = log.dateOnly;
    return (logDate.isAtSameMomentAs(dateRange.start) || logDate.isAfter(dateRange.start)) &&
           (logDate.isAtSameMomentAs(dateRange.end) || logDate.isBefore(dateRange.end.add(const Duration(days: 1))));
  }).toList();
  
  // Count frequency of each emoji in filtered logs
  final Map<String, int> frequency = {};
  for (final log in filteredLogs) {
    final emoji = log.mood.emoji;
    frequency[emoji] = (frequency[emoji] ?? 0) + 1;
  }
  
  return frequency;
});

// Computed provider that calculates weekly mood trend with daily averages
final weeklyMoodTrendProvider = Provider<List<Map<String, dynamic>>>((ref) {
  // Get filtered mood logs
  final allLogs = ref.watch(moodLogProvider);
  final selectedEmoji = ref.watch(selectedEmojiProvider);
  final dateRange = ref.watch(selectedDateRangeProvider);
  
  // Filter logs the same way as emoji frequency
  List<MoodLog> filteredLogs = allLogs;
  
  if (selectedEmoji != '😐') {
    filteredLogs = filteredLogs.where((log) => log.mood.emoji == selectedEmoji).toList();
  }
  
  filteredLogs = filteredLogs.where((log) {
    final logDate = log.dateOnly;
    return (logDate.isAtSameMomentAs(dateRange.start) || logDate.isAfter(dateRange.start)) &&
           (logDate.isAtSameMomentAs(dateRange.end) || logDate.isBefore(dateRange.end.add(const Duration(days: 1))));
  }).toList();
  
  // Group logs by date and calculate daily mood averages
  final Map<DateTime, List<MoodLog>> logsByDate = {};
  for (final log in filteredLogs) {
    final dateKey = log.dateOnly;
    logsByDate[dateKey] = [...(logsByDate[dateKey] ?? []), log];
  }
  
  // Create trend data for the last 7 days
  final List<Map<String, dynamic>> trendData = [];
  final now = DateTime.now();
  
  for (int i = 6; i >= 0; i--) {
    final date = DateTime(now.year, now.month, now.day).subtract(Duration(days: i));
    final dayLogs = logsByDate[date] ?? [];
    
    // Calculate average mood score for the day (convert emoji to numeric score)
    double dayScore = 3.0; // Default neutral score
    if (dayLogs.isNotEmpty) {
      final totalScore = dayLogs.fold<double>(0.0, (sum, log) {
        return sum + _emojiToScore(log.mood.emoji);
      });
      dayScore = totalScore / dayLogs.length;
    }
    
    trendData.add({
      'day': DateFormat('E').format(date), // Mon, Tue, etc.
      'score': dayScore,
      'date': date,
    });
  }
  
  return trendData;
});

// Computed provider that finds the most frequent mood from filtered data
final mostFrequentMoodProvider = Provider<MapEntry<String, int>?>((ref) {
  final frequency = ref.watch(emojiFrequencyProvider);
  
  if (frequency.isEmpty) return null;
  
  // Find the emoji with the highest frequency count
  return frequency.entries.reduce((a, b) => a.value > b.value ? a : b);
});

// Computed provider that calculates total filtered logs count
final filteredLogsCountProvider = Provider<int>((ref) {
  final frequency = ref.watch(emojiFrequencyProvider);
  // Sum all frequency counts to get total filtered logs
  return frequency.values.fold(0, (sum, count) => sum + count);
});

// Helper function to convert emoji to numeric mood score (1-5 scale)
double _emojiToScore(String emoji) {
  switch (emoji) {
    case '😢': return 1.0; // Very sad
    case '😠': return 2.0; // Angry  
    case '😐': return 3.0; // Neutral
    case '🙂': return 4.0; // Happy
    case '🤩': return 5.0; // Amazing
    default: return 3.0;   // Default neutral
  }
}

class StatsScreen extends ConsumerStatefulWidget {
  const StatsScreen({super.key});

  @override
  ConsumerState<StatsScreen> createState() => _StatsScreenState();
}

class _StatsScreenState extends ConsumerState<StatsScreen>
    with TickerProviderStateMixin {
  
  // Animation controllers for smooth chart transitions
  late AnimationController _fadeAnimationController;
  late AnimationController _slideAnimationController;
  
  // Animations
  late Animation<double> _fadeAnimation;
  late Animation<double> _slideAnimation;

  @override
  void initState() {
    super.initState();
    
    // Initialize animation controllers
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    
    _slideAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Initialize animations
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeAnimationController,
      curve: Curves.easeOut,
    ));

    _slideAnimation = Tween<double>(
      begin: 30.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _slideAnimationController,
      curve: Curves.easeOutCubic,
    ));

    // Start animations
    _fadeAnimationController.forward();
    _slideAnimationController.forward();
  }

  @override
  void dispose() {
    _fadeAnimationController.dispose();
    _slideAnimationController.dispose();
    super.dispose();
  }

  // Navigate to filter screen when user taps the filter icon
  void _navigateToFilter() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const FilterScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    
    // Watch all computed providers for reactive UI updates
    final emojiFrequency = ref.watch(emojiFrequencyProvider);
    final weeklyTrend = ref.watch(weeklyMoodTrendProvider);
    final mostFrequent = ref.watch(mostFrequentMoodProvider);
    final totalLogs = ref.watch(filteredLogsCountProvider);
    final dateRange = ref.watch(selectedDateRangeProvider);
    final selectedEmoji = ref.watch(selectedEmojiProvider);
    
    // Check if any filters are active
    final hasActiveFilters = selectedEmoji != '😐';
    
    return Scaffold(
      // AppBar with clean title and functional filter action
      appBar: AppBar(
        title: const Text(
          'Mood Stats',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
          ),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? Colors.grey[900] : Colors.white,
        foregroundColor: isDark ? Colors.white : const Color(0xFF2D3748),
        actions: [
          // Filter button to open filter screen
          IconButton(
            onPressed: _navigateToFilter,
            icon: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: hasActiveFilters 
                    ? const Color(0xFF6366F1) 
                    : const Color(0xFF6366F1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Icon(
                    Icons.filter_list,
                    color: hasActiveFilters 
                        ? Colors.white 
                        : const Color(0xFF6366F1),
                    size: 20,
                  ),
                  // Show indicator dot when filters are active
                  if (hasActiveFilters)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 6,
                        height: 6,
                        decoration: BoxDecoration(
                          color: Colors.orange,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
        ],
      ),
      
      // Main body with statistics cards
      body: Container(
        color: isDark ? Colors.grey[900] : const Color(0xFFF8F9FA),
        child: AnimatedBuilder(
          animation: _slideAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _slideAnimation.value),
              child: AnimatedBuilder(
                animation: _fadeAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity: _fadeAnimation.value,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Show active filters indicator if any filters are applied
                          if (hasActiveFilters) ...[
                            _buildActiveFiltersCard(isDark, selectedEmoji),
                            const SizedBox(height: 16),
                          ],
                          
                          // Section 1: Date range summary card
                          _buildDateSummaryCard(isDark, dateRange),
                          
                          const SizedBox(height: 24),
                          
                          // Section 2: Mood distribution chart
                          _buildMoodDistributionCard(isDark, emojiFrequency),
                          
                          const SizedBox(height: 24),
                          
                          // Section 3: Weekly mood trend
                          _buildWeeklyTrendCard(isDark, weeklyTrend),
                          
                          const SizedBox(height: 24),
                          
                          // Section 4: Most common mood highlight
                          _buildMostCommonMoodCard(isDark, mostFrequent),
                          
                          const SizedBox(height: 24),
                          
                          // Section 5: Total logs summary
                          _buildTotalLogsSummary(isDark, totalLogs),
                          
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  // Active filters indicator card - shows when filters are applied
  Widget _buildActiveFiltersCard(bool isDark, String selectedEmoji) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF6366F1).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF6366F1).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_list,
            color: const Color(0xFF6366F1),
            size: 18,
          ),
          const SizedBox(width: 8),
          Text(
            'Active Filter: ',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF6366F1),
            ),
          ),
          if (selectedEmoji != '😐') ...[
            Text(
              selectedEmoji,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 4),
            Text(
              _getMoodLabel(selectedEmoji),
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF6366F1),
              ),
            ),
          ],
          const Spacer(),
          GestureDetector(
            onTap: () {
              // Clear filters and return to all moods view
              ref.read(selectedEmojiProvider.notifier).state = '😐';
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF6366F1).withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Clear',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF6366F1),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section 1: Date range summary showing current filter period
  // This section displays the active date range from dateFilterProvider
  Widget _buildDateSummaryCard(bool isDark, DateTimeRange dateRange) {
    final totalDays = dateRange.duration.inDays + 1;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF6366F1).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.date_range,
                  color: Color(0xFF6366F1),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Analysis Period',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isDark ? Colors.grey[300] : const Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${DateFormat('MMM d').format(dateRange.start)} - ${DateFormat('MMM d, y').format(dateRange.end)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: isDark ? Colors.white : const Color(0xFF2D3748),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$totalDays ${totalDays == 1 ? 'day' : 'days'} of mood tracking',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF10B981),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Section 2: Mood distribution showing frequency of each emotion
  // This section shows the pie chart of emoji counts from mood logs
  // We calculate percentages and display horizontal progress bars
  Widget _buildMoodDistributionCard(bool isDark, Map<String, int> emojiFrequency) {
    // Calculate total moods for percentage calculations
    final totalMoods = emojiFrequency.values.fold(0, (sum, count) => sum + count);
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.pie_chart,
                  color: Color(0xFFEC4899),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Mood Distribution',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Show message if no data available
          if (emojiFrequency.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Icon(
                    Icons.mood_bad,
                    size: 48,
                    color: isDark ? Colors.grey[600] : Colors.grey[400],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No mood data for selected period',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.grey[400] : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            )
          else
            // Horizontal bar chart representation using real data
            ...emojiFrequency.entries.map((entry) {
              final emoji = entry.key;
              final count = entry.value;
              final percentage = totalMoods > 0 ? (count / totalMoods * 100).round() : 0;
              
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Text(
                          emoji,
                          style: const TextStyle(fontSize: 24),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _getMoodLabel(emoji),
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.grey[300] : const Color(0xFF64748B),
                                    ),
                                  ),
                                  Text(
                                    '$count ${count == 1 ? 'time' : 'times'} ($percentage%)',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              LinearProgressIndicator(
                                value: totalMoods > 0 ? count / totalMoods : 0.0,
                                backgroundColor: isDark ? Colors.grey[700] : Colors.grey[200],
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  _getMoodColor(emoji),
                                ),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  // Section 3: Weekly mood trend showing progression over time
  // This section calculates daily mood averages and displays them in a line chart
  // We group logs by date and convert emojis to numeric scores for trending
  Widget _buildWeeklyTrendCard(bool isDark, List<Map<String, dynamic>> weeklyTrend) {
    // Calculate trend improvement percentage
    double trendPercentage = 0.0;
    if (weeklyTrend.length >= 2) {
      final firstScore = weeklyTrend.first['score'] as double;
      final lastScore = weeklyTrend.last['score'] as double;
      if (firstScore > 0) {
        trendPercentage = ((lastScore - firstScore) / firstScore * 100);
      }
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.trending_up,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Weekly Trend',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 20),
          
          // Show message if no trend data
          if (weeklyTrend.isEmpty)
            Container(
              height: 200, // Increased height to accommodate labels
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.show_chart,
                      size: 48,
                      color: isDark ? Colors.grey[600] : Colors.grey[400],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'No trend data available',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            // Line chart with real weekly trend data - Fixed container
            Container(
              height: 200, // Increased from 180 to 200 to accommodate day labels
              child: CustomPaint(
                size: const Size(double.infinity, 200), // Match container height
                painter: LineChartPainter(
                  data: weeklyTrend,
                  isDark: isDark,
                ),
              ),
            ),
          
          const SizedBox(height: 16),
          
          // Trend summary with calculated percentage
          if (weeklyTrend.isNotEmpty)
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: trendPercentage >= 0 
                    ? const Color(0xFF10B981).withOpacity(0.1)
                    : const Color(0xFFEF4444).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    trendPercentage >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                    color: trendPercentage >= 0 
                        ? const Color(0xFF10B981) 
                        : const Color(0xFFEF4444),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Flexible( // Added Flexible to prevent text overflow
                    child: Text(
                      trendPercentage >= 0 
                          ? 'Your mood has improved by ${trendPercentage.abs().toStringAsFixed(1)}% this week!'
                          : 'Your mood has decreased by ${trendPercentage.abs().toStringAsFixed(1)}% this week.',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: trendPercentage >= 0 
                            ? const Color(0xFF10B981) 
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // Section 4: Most common mood highlighting the dominant emotion
  // We calculate the most common mood by checking the max frequency from filtered data
 Widget _buildMostCommonMoodCard(bool isDark, MapEntry<String, int>? mostFrequent) {
    // Show placeholder if no data
    if (mostFrequent == null) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
              blurRadius: 10,
              spreadRadius: 2,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Icon(
              Icons.emoji_emotions_outlined,
              size: 48,
              color: isDark ? Colors.grey[600] : Colors.grey[400],
            ),
            const SizedBox(height: 12),
            Text(
              'No mood data available',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.grey[400] : Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            _getMoodColor(mostFrequent.key).withOpacity(0.1),
            _getMoodColor(mostFrequent.key).withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _getMoodColor(mostFrequent.key).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getMoodColor(mostFrequent.key).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.emoji_emotions,
                  color: _getMoodColor(mostFrequent.key),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Text(
                'Most Common Mood',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : const Color(0xFF2D3748),
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 24),
          
          // Large emoji display
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: _getMoodColor(mostFrequent.key).withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: _getMoodColor(mostFrequent.key).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Center(
              child: Text(
                mostFrequent.key,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Text(
            _getMoodLabel(mostFrequent.key),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: _getMoodColor(mostFrequent.key),
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            'Logged ${mostFrequent.value} ${mostFrequent.value == 1 ? 'time' : 'times'} this period',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.grey[300] : const Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  // Section 5: Total logs summary showing activity metrics
  // This section displays the total count of filtered mood logs and daily average
  Widget _buildTotalLogsSummary(bool isDark, int totalLogs) {
    // Calculate daily average based on the selected date range
    final dateRange = ref.watch(selectedDateRangeProvider);
    final totalDays = dateRange.duration.inDays + 1;
    final dailyAverage = totalDays > 0 ? totalLogs / totalDays : 0.0;
    
    return Row(
      children: [
        // Total logs card with real data
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8B5CF6).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.analytics,
                    color: Color(0xFF8B5CF6),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '$totalLogs',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Total Logs',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
        
        const SizedBox(width: 16),
        
        // Daily average card with calculated average
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.grey[800] : Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: (isDark ? Colors.black : Colors.grey).withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF59E0B).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.today,
                    color: Color(0xFFF59E0B),
                    size: 24,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  dailyAverage.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : const Color(0xFF2D3748),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Daily Avg',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.grey[400] : const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // Helper method to get mood label from emoji
  String _getMoodLabel(String emoji) {
    switch (emoji) {
      case '😢': return 'Very Sad';
      case '😠': return 'Angry';
      case '😐': return 'Neutral';
      case '🙂': return 'Happy';
      case '🤩': return 'Amazing';
      default: return 'Unknown';
    }
  }

  // Helper method to get mood color from emoji
  Color _getMoodColor(String emoji) {
    switch (emoji) {
      case '😢': return const Color(0xFFE57373);
      case '😠': return const Color(0xFFFFB74D);
      case '😐': return const Color(0xFF90A4AE);
      case '🙂': return const Color(0xFF81C784);
      case '🤩': return const Color(0xFF66BB6A);
      default: return const Color(0xFF90A4AE);
    }
  }
}

// Custom painter for line chart visualization with real data
class LineChartPainter extends CustomPainter {
  final List<Map<String, dynamic>> data;
  final bool isDark;

  LineChartPainter({required this.data, required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    // Reserve space for labels at the bottom
    final chartHeight = size.height - 30; // Reserve 30px for day labels
    
    final paint = Paint()
      ..color = const Color(0xFF10B981)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = const Color(0xFF10B981)
      ..style = PaintingStyle.fill;

    final gridPaint = Paint()
      ..color = (isDark ? Colors.grey[700]! : Colors.grey[300]!)
      ..strokeWidth = 1.0;

    // Draw grid lines - only in chart area
    for (int i = 0; i <= 4; i++) {
      final y = chartHeight * (i / 4);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        gridPaint,
      );
    }

    if (data.isEmpty) return;

    // Calculate points from real data
    final points = <Offset>[];
    for (int i = 0; i < data.length; i++) {
      final x = size.width * (i / (data.length - 1).clamp(1, double.infinity));
      final score = data[i]['score'] as double;
      final y = chartHeight - (chartHeight * (score / 5.0)); // Normalize to 0-5 scale
      points.add(Offset(x, y));
    }

    // Draw line connecting all points
    if (points.length > 1) {
      final path = Path();
      path.moveTo(points[0].dx, points[0].dy);
      
      for (int i = 1; i < points.length; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      
      canvas.drawPath(path, paint);
    }

    // Draw data points
    for (final point in points) {
      canvas.drawCircle(point, 6, pointPaint);
      canvas.drawCircle(point, 6, Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2);
    }

    // Draw day labels - positioned properly within reserved space
    final textPainter = TextPainter(
      textDirection: ui.TextDirection.ltr,
    );

    for (int i = 0; i < data.length; i++) {
      final x = size.width * (i / (data.length - 1).clamp(1, double.infinity));
      textPainter.text = TextSpan(
        text: data[i]['day'],
        style: TextStyle(
          color: isDark ? Colors.grey[400] : Colors.grey[600],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      );
      textPainter.layout();
      
      // Position labels within the reserved space
      final labelY = chartHeight + 8; // 8px below the chart
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, labelY),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}