import 'package:flutter/material.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_text_styles.dart';

class FoodQAppLogo extends StatelessWidget {
  final double size;
  final bool showText;

  const FoodQAppLogo({
    super.key,
    this.size = 80,
    this.showText = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Logo Icon
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 16,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Polka dot pattern background
              CustomPaint(
                size: Size(size, size),
                painter: _PolkaDotPainter(),
              ),
              // Main icon
              Icon(
                Icons.restaurant,
                color: AppColors.onPrimary,
                size: size * 0.4,
              ),
              // Discount badge
              Positioned(
                top: size * 0.15,
                right: size * 0.15,
                child: Container(
                  width: size * 0.25,
                  height: size * 0.25,
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.onPrimary,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '%',
                      style: TextStyle(
                        color: AppColors.onSecondary,
                        fontSize: size * 0.12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        if (showText) ...[
          const SizedBox(height: 16),
          // App Name
          Text(
            'FoodQ',
            style: AppTextStyles.headlineMedium.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 4),
          // Tagline
          Text(
            'Save Money • Reduce Waste',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.onSurfaceVariant,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _PolkaDotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.polkaDotPrimary
      ..style = PaintingStyle.fill;

    final dotRadius = size.width * 0.08;
    final spacing = size.width * 0.2;

    // Create polka dot pattern
    for (double x = -dotRadius; x < size.width + dotRadius; x += spacing) {
      for (double y = -dotRadius; y < size.height + dotRadius; y += spacing) {
        // Offset alternate rows
        final xOffset = (y / spacing) % 2 == 0 ? 0.0 : spacing / 2;
        canvas.drawCircle(
          Offset(x + xOffset, y),
          dotRadius,
          paint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}