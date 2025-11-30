import 'package:flutter/material.dart';
import 'package:hamro_service/screens/login_screen.dart';

class Onboarding1Screen extends StatelessWidget {
  const Onboarding1Screen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Header with SKIP button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'onboarding1',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'SKIP',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Main image card
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 24),
              width: double.infinity,
              height: 280,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Center(
                child: CustomPaint(
                  size: const Size(200, 200),
                  painter: _ToolsIllustrationPainter(),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Indicator dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(isActive: true),
                const SizedBox(width: 8),
                _buildDot(isActive: false),
                const SizedBox(width: 8),
                _buildDot(isActive: false),
              ],
            ),

            const SizedBox(height: 40),

            // Title
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Quick service at your doorstep.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  height: 1.2,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Description
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                'Fast home help anywhere in Kathmandu.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.black54,
                  height: 1.4,
                ),
              ),
            ),

            const Spacer(),

            // NEXT button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushReplacement(
                      MaterialPageRoute(
                        builder: (context) => const Onboarding1Screen(),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2ECC71),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'NEXT',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDot({required bool isActive}) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isActive ? const Color(0xFF4A4A4A) : const Color(0xFFD0D0D0),
      ),
    );
  }
}

// Custom painter for the tools illustration
class _ToolsIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    final centerX = size.width / 2;
    final baseY = size.height * 0.7;

    // Draw three stick figures with tools
    // Left figure with hammer
    _drawStickFigure(canvas, centerX - 60, baseY, paint);
    _drawHammer(canvas, centerX - 60, baseY - 20, paint);

    // Middle figure with wrench
    _drawStickFigure(canvas, centerX, baseY, paint);
    _drawWrench(canvas, centerX, baseY - 20, paint);

    // Right figure with screwdriver
    _drawStickFigure(canvas, centerX + 60, baseY, paint);
    _drawScrewdriver(canvas, centerX + 60, baseY - 20, paint);

    // Draw ground
    paint.color = const Color(0xFFE0E0E0);
    canvas.drawLine(
      Offset(0, baseY + 15),
      Offset(size.width, baseY + 15),
      paint,
    );
  }

  void _drawStickFigure(Canvas canvas, double x, double y, Paint paint) {
    paint.color = Colors.black87;

    // Head (circle)
    canvas.drawCircle(Offset(x, y - 50), 12, paint);

    // Body (line)
    canvas.drawLine(Offset(x, y - 38), Offset(x, y - 10), paint);

    // Arms
    canvas.drawLine(Offset(x, y - 30), Offset(x - 12, y - 20), paint);
    canvas.drawLine(Offset(x, y - 30), Offset(x + 12, y - 20), paint);

    // Legs
    canvas.drawLine(Offset(x, y - 10), Offset(x - 10, y + 5), paint);
    canvas.drawLine(Offset(x, y - 10), Offset(x + 10, y + 5), paint);
  }

  void _drawHammer(Canvas canvas, double x, double y, Paint paint) {
    // Hammer head (silver/grey)
    paint.color = const Color(0xFF9E9E9E);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(x + 8, y - 15), width: 16, height: 8),
        const Radius.circular(2),
      ),
      paint,
    );

    // Hammer handle (blue)
    paint.color = const Color(0xFF2196F3);
    canvas.drawLine(
      Offset(x + 8, y - 15),
      Offset(x + 12, y),
      paint..strokeWidth = 4,
    );
  }

  void _drawWrench(Canvas canvas, double x, double y, Paint paint) {
    // Wrench (silver/grey)
    paint.color = const Color(0xFF9E9E9E);
    paint.strokeWidth = 4;
    paint.strokeCap = StrokeCap.round;

    // Wrench head (curved)
    final path = Path()
      ..moveTo(x - 5, y - 10)
      ..quadraticBezierTo(x, y - 12, x + 5, y - 10)
      ..quadraticBezierTo(x + 6, y - 8, x + 5, y - 6)
      ..quadraticBezierTo(x, y - 8, x - 5, y - 6)
      ..quadraticBezierTo(x - 6, y - 8, x - 5, y - 10);

    canvas.drawPath(path, paint..style = PaintingStyle.stroke);

    // Wrench handle
    canvas.drawLine(
      Offset(x, y - 8),
      Offset(x, y + 2),
      paint..strokeCap = StrokeCap.round,
    );
  }

  void _drawScrewdriver(Canvas canvas, double x, double y, Paint paint) {
    // Screwdriver handle (red)
    paint.color = const Color(0xFFE53935);
    canvas.drawRect(
      Rect.fromCenter(center: Offset(x - 8, y - 12), width: 8, height: 8),
      paint,
    );

    // Screwdriver shaft (silver)
    paint.color = const Color(0xFF9E9E9E);
    canvas.drawLine(
      Offset(x - 4, y - 8),
      Offset(x - 4, y + 5),
      paint..strokeWidth = 3,
    );

    // Screwdriver tip
    canvas.drawLine(Offset(x - 4, y + 5), Offset(x - 6, y + 8), paint);
    canvas.drawLine(Offset(x - 4, y + 5), Offset(x - 2, y + 8), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
