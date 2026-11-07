import 'package:flutter/material.dart';

import '../theme/ss_shop_colors.dart';

/// 本地矢量插画占位（不依赖网络图）。
class SSDemoProductArt extends StatelessWidget {
  const SSDemoProductArt({
    super.key,
    required this.artKey,
    this.size = 72,
    this.borderRadius = 10,
  });

  final String artKey;
  final double size;
  final double borderRadius;

  @override
  Widget build(BuildContext context) {
    final palette = _paletteForKey(artKey);
    final child = CustomPaint(
      painter: _SSDemoProductArtPainter(
        gradient: palette,
        icon: _iconForKey(artKey),
      ),
    );
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: size.isFinite
          ? SizedBox(width: size, height: size, child: child)
          : SizedBox.expand(child: child),
    );
  }

  static LinearGradient _paletteForKey(String key) {
    return switch (key) {
      'phone' => const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E88E5), Color(0xFF0D47A1)],
        ),
      'earphone' => const LinearGradient(
          colors: [Color(0xFF5C6BC0), Color(0xFF3949AB)],
        ),
      'apparel' => const LinearGradient(
          colors: [Color(0xFF81D4FA), Color(0xFF4FC3F7)],
        ),
      'cup' => const LinearGradient(
          colors: [Color(0xFFFFCC80), Color(0xFFFFB74D)],
        ),
      'beauty' => const LinearGradient(
          colors: [Color(0xFFF48FB1), Color(0xFFEC407A)],
        ),
      'powerbank' => const LinearGradient(
          colors: [Color(0xFF80CBC4), Color(0xFF26A69A)],
        ),
      _ => const LinearGradient(
          colors: [Color(0xFFCFD8DC), Color(0xFF90A4AE)],
        ),
    };
  }

  static IconData _iconForKey(String key) {
    return switch (key) {
      'phone' => Icons.smartphone,
      'earphone' => Icons.headphones,
      'apparel' => Icons.checkroom_outlined,
      'cup' => Icons.local_cafe_outlined,
      'beauty' => Icons.spa_outlined,
      'powerbank' => Icons.battery_charging_full,
      _ => Icons.shopping_bag_outlined,
    };
  }
}

class _SSDemoProductArtPainter extends CustomPainter {
  _SSDemoProductArtPainter({required this.gradient, required this.icon});

  final LinearGradient gradient;
  final IconData icon;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()..shader = gradient.createShader(rect);
    canvas.drawRect(rect, paint);
    final tp = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(icon.codePoint),
        style: TextStyle(
          fontSize: size.width * 0.38,
          fontFamily: icon.fontFamily,
          package: icon.fontPackage,
          color: Colors.white.withValues(alpha: 0.92),
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    tp.paint(
      canvas,
      Offset((size.width - tp.width) / 2, (size.height - tp.height) / 2),
    );
    final highlight = Paint()..color = Colors.white.withValues(alpha: 0.12);
    canvas.drawCircle(
      Offset(size.width * 0.78, size.height * 0.22),
      size.width * 0.22,
      highlight,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// 价格文案（红色 ¥）。
class SSPriceText extends StatelessWidget {
  const SSPriceText({
    super.key,
    required this.cents,
    this.fontSize = 16,
    this.muted = false,
  });

  final int cents;
  final double fontSize;
  final bool muted;

  @override
  Widget build(BuildContext context) {
    final value = (cents / 100).toStringAsFixed(2);
    return Text.rich(
      TextSpan(
        children: [
          TextSpan(
            text: '¥',
            style: TextStyle(
              fontSize: fontSize * 0.75,
              fontWeight: FontWeight.w600,
              color: muted ? SSShopColors.textTertiary : SSShopColors.price,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              color: muted ? SSShopColors.textTertiary : SSShopColors.price,
            ),
          ),
        ],
      ),
    );
  }
}
