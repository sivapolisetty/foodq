import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

/// Advanced animation system designed specifically for food apps
/// Focuses on appetite psychology and emotional engagement
class FoodAnimations {
  
  /// Appetite-inducing entrance animation
  /// Creates anticipation and hunger through elastic growth
  static AnimationController createHungerGrowController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: vsync,
    );
  }
  
  static Animation<double> hungerGrow(AnimationController controller) {
    return Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.elasticOut,
    ));
  }
  
  /// Satisfaction pulse for completed actions
  /// Creates positive reinforcement through gentle pulsing
  static AnimationController createSatisfactionController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );
  }
  
  static Animation<Color?> satisfactionPulse(AnimationController controller) {
    return ColorTween(
      begin: Colors.transparent,
      end: AppColors.satisfiedGreen.withOpacity(0.3),
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }
  
  /// Savings celebration animation
  /// Creates excitement for deals through bouncy scaling
  static AnimationController createSavingsController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: vsync,
    );
  }
  
  static Animation<double> savingsPop(AnimationController controller) {
    return Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.bounceOut,
    ));
  }
  
  /// FOMO urgency pulse
  /// Creates tension and urgency through rapid pulsing
  static AnimationController createUrgencyController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: vsync,
    )..repeat(reverse: true);
  }
  
  static Animation<double> urgencyPulse(AnimationController controller) {
    return Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }
  
  /// Missed opportunity fade
  /// Creates regret through desaturation and opacity
  static AnimationController createMissedController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: vsync,
    );
  }
  
  static Animation<double> missedFade(AnimationController controller) {
    return Tween<double>(
      begin: 1.0,
      end: 0.6,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeOut,
    ));
  }
  
  /// Loading animation for food items
  /// Creates anticipation through shimmer effect
  static AnimationController createLoadingController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: vsync,
    )..repeat();
  }
  
  static Animation<double> loadingShimmer(AnimationController controller) {
    return Tween<double>(
      begin: -1.0,
      end: 2.0,
    ).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }
  
  /// Cart addition animation
  /// Creates satisfaction through successful completion
  static AnimationController createCartController(TickerProvider vsync) {
    return AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: vsync,
    );
  }
  
  static Animation<double> cartScale(AnimationController controller) {
    return TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.3),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.3, end: 1.0),
        weight: 50,
      ),
    ]).animate(CurvedAnimation(
      parent: controller,
      curve: Curves.easeInOut,
    ));
  }
  
  /// Page transition animations
  static SlideTransition slideFromBottom(
    Animation<double> animation,
    Widget child,
  ) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(
        parent: animation,
        curve: Curves.easeOut,
      )),
      child: child,
    );
  }
  
  static FadeTransition hungerFade(
    Animation<double> animation,
    Widget child,
  ) {
    return FadeTransition(
      opacity: CurvedAnimation(
        parent: animation,
        curve: Curves.easeIn,
      ),
      child: child,
    );
  }
}

/// Interactive feedback system for user actions
class InteractionFeedback {
  
  /// Show savings celebration with haptic feedback
  static void showSavingsCelebration(
    BuildContext context, 
    double amount, {
    VoidCallback? onComplete,
  }) {
    HapticFeedback.lightImpact();
    
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.transparent,
      builder: (context) => SavingsCelebrationDialog(
        amount: amount,
        onComplete: onComplete,
      ),
    );
  }
  
  /// Show hunger pulse with haptic feedback
  static void showHungerPulse(GlobalKey widgetKey) {
    HapticFeedback.selectionClick();
    
    final RenderBox? renderBox = 
        widgetKey.currentContext?.findRenderObject() as RenderBox?;
    
    if (renderBox != null) {
      final position = renderBox.localToGlobal(Offset.zero);
      // Create hunger pulse overlay at widget position
      // Implementation depends on overlay requirements
    }
  }
  
  /// Provide tactile feedback for different actions
  static void provideFeedback(FeedbackType type) {
    switch (type) {
      case FeedbackType.success:
        HapticFeedback.lightImpact();
        break;
      case FeedbackType.error:
        HapticFeedback.vibrate();
        break;
      case FeedbackType.selection:
        HapticFeedback.selectionClick();
        break;
      case FeedbackType.urgency:
        HapticFeedback.heavyImpact();
        break;
    }
  }
}

enum FeedbackType {
  success,
  error,
  selection,
  urgency,
}

/// Savings celebration dialog with animation
class SavingsCelebrationDialog extends StatefulWidget {
  final double amount;
  final VoidCallback? onComplete;
  
  const SavingsCelebrationDialog({
    super.key,
    required this.amount,
    this.onComplete,
  });
  
  @override
  State<SavingsCelebrationDialog> createState() => _SavingsCelebrationDialogState();
}

class _SavingsCelebrationDialogState extends State<SavingsCelebrationDialog>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.7, 1.0, curve: Curves.easeIn),
    ));
    
    _controller.forward().then((_) {
      if (mounted) {
        Navigator.of(context).pop();
        widget.onComplete?.call();
      }
    });
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
                decoration: BoxDecoration(
                  color: AppColors.premiumGold,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.premiumGold.withOpacity(0.3),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.savings,
                      color: AppColors.onPrimary,
                      size: 48,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'You Saved!',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '\$${widget.amount.toStringAsFixed(2)}',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.onPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}