import 'package:flutter/material.dart';

/// Converts Western Arabic numerals (0-9) to Eastern Arabic-Indic numerals (٠-٩)
String toArabicDigits(int number) {
  const english = ['0', '1', '2', '3', '4', '5', '6', '7', '8', '9'];
  const arabic = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  String res = number.toString();
  for (int i = 0; i < english.length; i++) {
    res = res.replaceAll(english[i], arabic[i]);
  }
  return res;
}

/// A widget that renders a full-page authentic Medina Mushaf frame (إطار مصحف المدينة المنورة)
/// with decorative Islamic border, top header (Surah name & Juz), bottom footer (Page & Hizb),
/// and corner-to-corner layout.
class MedinaMushafFrame extends StatelessWidget {
  final int pageNumber;
  final String surahName;
  final int juzNumber;
  final String? hizbText;
  final Widget child;

  const MedinaMushafFrame({
    super.key,
    required this.pageNumber,
    required this.surahName,
    required this.juzNumber,
    this.hizbText,
    required this.child,
  });

  bool get isOpeningPage => pageNumber == 1 || pageNumber == 2;

  @override
  Widget build(BuildContext context) {
    const goldColor = Color(0xFFB58A38);
    const darkGold = Color(0xFF7A5818);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SizedBox(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: CustomPaint(
            size: Size(constraints.maxWidth, constraints.maxHeight),
            painter: MedinaFramePainter(
              isOpeningPage: isOpeningPage,
              primaryGold: goldColor,
              darkGold: darkGold,
            ),
            child: Column(
              children: [
                // 1. Top Ribbon Header (Surah name on one side, Juz on the other)
                if (!isOpeningPage)
                  Container(
                    height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Right: Surah Name
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.star, size: 8, color: goldColor),
                          const SizedBox(width: 4),
                          Text(
                            'سُورَةُ $surahName',
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: darkGold,
                            ),
                          ),
                        ],
                      ),
                      // Left: Juz Number
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'الجُزْءُ ${toArabicDigits(juzNumber)}',
                            style: const TextStyle(
                              fontFamily: 'Amiri',
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                              color: darkGold,
                            ),
                          ),
                          const SizedBox(width: 4),
                          const Icon(Icons.star, size: 8, color: goldColor),
                        ],
                      ),
                    ],
                  ),
                )
              else
                const SizedBox(height: 32),

              // 2. Middle Content: The 15 Lines of Quran Text
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: isOpeningPage ? 28.0 : 16.0,
                    vertical: isOpeningPage ? 16.0 : 4.0,
                  ),
                  child: child,
                ),
              ),

              // 3. Bottom Ribbon Footer (Medallion with Arabic Page Number & Hizb)
              Container(
                height: 34,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                alignment: Alignment.center,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Optional Hizb text on side
                    if (hizbText != null && hizbText!.isNotEmpty && !isOpeningPage)
                      Align(
                        alignment: Alignment.centerRight,
                        child: Text(
                          hizbText!,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontSize: 11,
                            color: darkGold,
                          ),
                        ),
                      ),
                    // Centered Decorative Page Number Medallion
                    Container(
                      width: 32,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        border: Border.all(color: goldColor, width: 1.2),
                        borderRadius: BorderRadius.circular(12),
                        color: const Color(0xFFF9F6EE),
                      ),
                      child: Text(
                        toArabicDigits(pageNumber),
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: darkGold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  }
}

/// Custom painter for rendering the authentic Medina Mushaf ornamental frame
class MedinaFramePainter extends CustomPainter {
  final bool isOpeningPage;
  final Color primaryGold;
  final Color darkGold;
  final Color accentGold;

  MedinaFramePainter({
    this.isOpeningPage = false,
    this.primaryGold = const Color(0xFFB58A38),
    this.darkGold = const Color(0xFF7A5818),
    this.accentGold = const Color(0xFFE2C478),
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final outerPaint = Paint()
      ..color = primaryGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;

    final innerPaint = Paint()
      ..color = darkGold.withValues(alpha: 0.6)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;

    final fillHeaderPaint = Paint()
      ..color = primaryGold.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    const marginOuter = 3.0;
    const marginInner = 7.0;

    // 1. Outer Border
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        marginOuter,
        marginOuter,
        size.width - (marginOuter * 2),
        size.height - (marginOuter * 2),
      ),
      const Radius.circular(6),
    );
    canvas.drawRRect(outerRect, outerPaint);

    // 2. Inner Border
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        marginInner,
        marginInner,
        size.width - (marginInner * 2),
        size.height - (marginInner * 2),
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(innerRect, innerPaint);

    // 3. Corner Ornaments (Islamic corner brackets in all 4 corners)
    _drawCornerOrnaments(canvas, size, marginInner);

    // 4. Header & Footer dividers (for standard pages)
    if (!isOpeningPage) {
      const headerY = 38.0;
      final footerY = size.height - 36.0;

      // Header top ribbon background
      final headerRect = Rect.fromLTWH(
        marginInner + 2,
        marginInner + 2,
        size.width - (marginInner * 2) - 4,
        headerY - marginInner - 2,
      );
      canvas.drawRect(headerRect, fillHeaderPaint);

      // Header divider line
      canvas.drawLine(
        Offset(marginInner, headerY),
        Offset(size.width - marginInner, headerY),
        innerPaint,
      );
      canvas.drawLine(
        Offset(marginInner, headerY + 2),
        Offset(size.width - marginInner, headerY + 2),
        Paint()
          ..color = accentGold.withValues(alpha: 0.4)
          ..strokeWidth = 0.5,
      );

      // Footer divider line
      canvas.drawLine(
        Offset(marginInner, footerY),
        Offset(size.width - marginInner, footerY),
        innerPaint,
      );
      canvas.drawLine(
        Offset(marginInner, footerY - 2),
        Offset(size.width - marginInner, footerY - 2),
        Paint()
          ..color = accentGold.withValues(alpha: 0.4)
          ..strokeWidth = 0.5,
      );
    } else {
      // Opening Page (Al-Fatiha & Al-Baqarah start) Special Illumination Arch
      _drawOpeningPageArch(canvas, size, marginInner);
    }
  }

  void _drawCornerOrnaments(Canvas canvas, Size size, double margin) {
    final cornerPaint = Paint()
      ..color = primaryGold
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    const cornerSize = 14.0;

    // Top-Left
    canvas.drawLine(
      Offset(margin, margin + cornerSize),
      Offset(margin + cornerSize, margin),
      cornerPaint,
    );
    canvas.drawCircle(
      Offset(margin + 5, margin + 5),
      2,
      Paint()..color = darkGold..style = PaintingStyle.fill,
    );

    // Top-Right
    canvas.drawLine(
      Offset(size.width - margin, margin + cornerSize),
      Offset(size.width - margin - cornerSize, margin),
      cornerPaint,
    );
    canvas.drawCircle(
      Offset(size.width - margin - 5, margin + 5),
      2,
      Paint()..color = darkGold..style = PaintingStyle.fill,
    );

    // Bottom-Left
    canvas.drawLine(
      Offset(margin, size.height - margin - cornerSize),
      Offset(margin + cornerSize, size.height - margin),
      cornerPaint,
    );
    canvas.drawCircle(
      Offset(margin + 5, size.height - margin - 5),
      2,
      Paint()..color = darkGold..style = PaintingStyle.fill,
    );

    // Bottom-Right
    canvas.drawLine(
      Offset(size.width - margin, size.height - margin - cornerSize),
      Offset(size.width - margin - cornerSize, size.height - margin),
      cornerPaint,
    );
    canvas.drawCircle(
      Offset(size.width - margin - 5, size.height - margin - 5),
      2,
      Paint()..color = darkGold..style = PaintingStyle.fill,
    );
  }

  void _drawOpeningPageArch(Canvas canvas, Size size, double margin) {
    final archPaint = Paint()
      ..color = primaryGold.withValues(alpha: 0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.8;

    final fillPaint = Paint()
      ..color = primaryGold.withValues(alpha: 0.08)
      ..style = PaintingStyle.fill;

    final topArchPath = Path();
    final centerX = size.width / 2;
    final topY = margin + 12;

    topArchPath.moveTo(margin + 16, topY + 28);
    topArchPath.quadraticBezierTo(
      centerX,
      topY - 8,
      size.width - margin - 16,
      topY + 28,
    );
    canvas.drawPath(topArchPath, fillPaint);
    canvas.drawPath(topArchPath, archPaint);

    final bottomArchPath = Path();
    final bottomY = size.height - margin - 12;
    bottomArchPath.moveTo(margin + 16, bottomY - 28);
    bottomArchPath.quadraticBezierTo(
      centerX,
      bottomY + 8,
      size.width - margin - 16,
      bottomY - 28,
    );
    canvas.drawPath(bottomArchPath, fillPaint);
    canvas.drawPath(bottomArchPath, archPaint);
  }

  @override
  bool shouldRepaint(covariant MedinaFramePainter oldDelegate) {
    return oldDelegate.isOpeningPage != isOpeningPage ||
        oldDelegate.primaryGold != primaryGold;
  }
}
