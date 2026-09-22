import 'package:flutter/material.dart';

class DalailArchClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    final w = size.width;
    final h = size.height;

    // Start at bottom left
    path.moveTo(0, h * 0.9);
    
    // Bottom curve to bottom right
    path.quadraticBezierTo(0, h, w * 0.1, h);
    path.lineTo(w * 0.9, h);
    path.quadraticBezierTo(w, h, w, h * 0.9);

    // Right edge going up
    path.lineTo(w, h * 0.35);

    // Right arch shoulder
    path.quadraticBezierTo(w, h * 0.18, w * 0.7, h * 0.12);

    // Pointed top dome arch (Mihrab tip)
    path.quadraticBezierTo(w * 0.5, h * 0.08, w * 0.5, 0);

    // Left arch shoulder from tip
    path.quadraticBezierTo(w * 0.5, h * 0.08, w * 0.3, h * 0.12);
    path.quadraticBezierTo(0, h * 0.18, 0, h * 0.35);

    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

class DalailArchBorderPainter extends CustomPainter {
  final Color borderColor;
  final double strokeWidth;

  DalailArchBorderPainter({
    required this.borderColor,
    this.strokeWidth = 2.5,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final innerPaint = Paint()
      ..color = borderColor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0;

    final clipper = DalailArchClipper();
    final path = clipper.getClip(size);

    canvas.drawPath(path, paint);

    // Scale slightly inward for double-border effect
    canvas.save();
    canvas.translate(size.width * 0.03, size.height * 0.03);
    canvas.scale(0.94, 0.94);
    final innerPath = clipper.getClip(size);
    canvas.drawPath(innerPath, innerPaint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DalailArchCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final bool isIntro;

  const DalailArchCard({
    super.key,
    required this.title,
    this.subtitle,
    required this.onTap,
    this.isIntro = false,
  });

  @override
  Widget build(BuildContext context) {
    const goldBorder = Color(0xFF8B6B3E);
    const goldBgStart = Color(0xFFFAF6EE);
    const goldBgEnd = Color(0xFFECE0C8);

    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          // Background Arch Shadow & Fill
          ClipPath(
            clipper: DalailArchClipper(),
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [goldBgStart, goldBgEnd],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 6,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 12),
                      if (isIntro) ...[
                        // Decorative icon/calligraphy for Intro
                        const Icon(
                          Icons.menu_book_rounded,
                          color: Color(0xFF6B4E28),
                          size: 24,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Color(0xFF4A3419),
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ] else ...[
                        Text(
                          title,
                          style: const TextStyle(
                            fontFamily: 'Amiri',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF4A3419),
                            height: 1.2,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (subtitle != null && subtitle!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF8B6B3E).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(
                                color: const Color(0xFF8B6B3E).withOpacity(0.3),
                                width: 0.8,
                              ),
                            ),
                            child: Text(
                              subtitle!,
                              style: const TextStyle(
                                fontFamily: 'Amiri',
                                fontWeight: FontWeight.w600,
                                fontSize: 11,
                                color: Color(0xFF5A4122),
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Arch Border Outline Overlay
          Positioned.fill(
            child: CustomPaint(
              painter: DalailArchBorderPainter(
                borderColor: goldBorder,
                strokeWidth: 2.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
