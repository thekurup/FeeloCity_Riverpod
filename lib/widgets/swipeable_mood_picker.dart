// lib/widgets/swipeable_mood_picker.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lottie/lottie.dart';
import 'dart:math' as math;

class SwipeableMoodPicker extends StatefulWidget {
  final String? selectedMood;
  final Function(String) onMoodSelected;

  const SwipeableMoodPicker({
    super.key,
    required this.selectedMood,
    required this.onMoodSelected,
  });

  @override
  State<SwipeableMoodPicker> createState() => _SwipeableMoodPickerState();
}

class _SwipeableMoodPickerState extends State<SwipeableMoodPicker>
    with TickerProviderStateMixin {
  late PageController _pageController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  int _currentIndex = 2; // Default to neutral (middle emoji)
  double _pageOffset = 2.0;
  
  // Mood data with Lottie file paths and colors
  static const List<Map<String, dynamic>> _moods = [
    {
      'emoji': '😢',
      'lottieAsset': 'assets/animations/emoji_sad.json',
      'label': 'Very Sad',
      'color': Color(0xFFE57373),
    },
    {
      'emoji': '😡',
      'lottieAsset': 'assets/animations/emoji_angry.json',
      'label': 'Angry', 
      'color': Color(0xFFFFB74D),
    },
    {
      'emoji': '😐',
      'lottieAsset': 'assets/animations/emoji_neutral.json',
      'label': 'Neutral',
      'color': Color(0xFF90A4AE),
    },
    {
      'emoji': '🙂',
      'lottieAsset': 'assets/animations/emoji_happy.json',
      'label': 'Good',
      'color': Color(0xFF81C784),
    },
    {
      'emoji': '🤩',
      'lottieAsset': 'assets/animations/emoji_excited.json',
      'label': 'Very Good',
      'color': Color(0xFF66BB6A),
    },
  ];

  @override
  void initState() {
    super.initState();
    
    // Set initial mood if provided
    if (widget.selectedMood != null) {
      final index = _moods.indexWhere((mood) => mood['emoji'] == widget.selectedMood);
      if (index != -1) {
        _currentIndex = index;
        _pageOffset = index.toDouble();
      }
    }
    
    _pageController = PageController(
      initialPage: _currentIndex,
      viewportFraction: 0.25,
    );
    
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.15,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    ));

    // Listen to page controller for smooth offset updates
    _pageController.addListener(() {
      setState(() {
        _pageOffset = _pageController.page ?? _currentIndex.toDouble();
      });
    });

    // Start fade animation
    _fadeController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onPageChanged(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });
      widget.onMoodSelected(_moods[index]['emoji']!);
      HapticFeedback.lightImpact();
      _scaleController.forward().then((_) {
        _scaleController.reverse();
      });
    }
  }

  // Calculate curved arc position for each emoji
  double _getArcOffset(int index) {
    final progress = index / (_moods.length - 1);
    // Create upward-curving arc (inverted parabola)
    final arcHeight = 25.0;
    final curveOffset = -arcHeight * math.sin(progress * math.pi);
    return curveOffset;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6A5ACD), // Slate Blue
            Color(0xFF8A2BE2), // Blue Violet
            Color(0xFF6495ED), // Cornflower Blue
          ],
        ),
      ),
      child: Column(
        children: [
          // Emoji arc picker
          SizedBox(
            height: 120,
            child: Stack(
              children: [
                // Curved path indicator
                Positioned.fill(
                  child: CustomPaint(
                    painter: ArcPathPainter(),
                  ),
                ),
                
                // Emoji carousel
                PageView.builder(
                  controller: _pageController,
                  onPageChanged: _onPageChanged,
                  itemCount: _moods.length,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    final mood = _moods[index];
                    
                    // Calculate distance from current page for scaling
                    final distance = (index - _pageOffset).abs();
                    final isCenter = distance < 0.5;
                    final scale = isCenter 
                        ? (1.0 + (0.3 * (1.0 - distance * 2))) 
                        : math.max(0.7, 1.0 - (distance * 0.2));
                    
                    // Calculate arc offset for vertical positioning
                    final arcOffset = _getArcOffset(index);
                    
                    return Transform.translate(
                      offset: Offset(0, arcOffset),
                      child: Transform.scale(
                        scale: scale,
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 6),
                          child: Center(
                            child: GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeOutCubic,
                                );
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                width: isCenter ? 80 : 60,
                                height: isCenter ? 80 : 60,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white.withOpacity(isCenter ? 0.95 : 0.7),
                                  boxShadow: isCenter
                                      ? [
                                          BoxShadow(
                                            color: mood['color'].withOpacity(0.4),
                                            blurRadius: 16,
                                            spreadRadius: 3,
                                            offset: const Offset(0, 8),
                                          ),
                                        ]
                                      : [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(0.1),
                                            blurRadius: 6,
                                            offset: const Offset(0, 3),
                                          ),
                                        ],
                                ),
                                child: Center(
                                  child: Lottie.asset(
                                    mood['lottieAsset']!,
                                    width: isCenter ? 60 : 45,
                                    height: isCenter ? 60 : 45,
                                    fit: BoxFit.contain,
                                    repeat: true,
                                    animate: true,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 32),
          
          // Swipe helper text
          FadeTransition(
            opacity: _fadeAnimation,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swipe_outlined,
                  size: 18,
                  color: Colors.white.withOpacity(0.8),
                ),
                const SizedBox(width: 8),
                Text(
                  'Swipe to select your mood',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom painter for the curved arc path
class ArcPathPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.3)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    final path = Path();
    final centerY = size.height / 2;
    final arcHeight = 25.0;
    
    // Create curved arc path
    path.moveTo(0, centerY);
    
    for (double x = 0; x <= size.width; x += 2) {
      final progress = x / size.width;
      final curveOffset = -arcHeight * math.sin(progress * math.pi);
      path.lineTo(x, centerY + curveOffset);
    }
    
    canvas.drawPath(path, paint);
    
    // Add subtle glow effect
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
      
    canvas.drawPath(path, glowPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}