import 'package:flutter/material.dart';

class ScythesIcon extends StatelessWidget {
  final double size;
  final Color color;

  const ScythesIcon({
    super.key,
    this.size = 24.0,
    this.color = Colors.white,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(size, size),
      painter: _ScythesPainter(color),
    );
  }
}

class _ScythesPainter extends CustomPainter {
  final Color color;

  _ScythesPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final double w = size.width;
    final double h = size.height;

    // Draw first scythe (top-left to bottom-right)
    _drawScythe(canvas, paint, w, h, isMirrored: false);
    
    // Draw second scythe (top-right to bottom-left)
    _drawScythe(canvas, paint, w, h, isMirrored: true);
  }

  void _drawScythe(Canvas canvas, Paint paint, double w, double h, {required bool isMirrored}) {
    canvas.save();
    if (isMirrored) {
      canvas.translate(w, 0);
      canvas.scale(-1, 1);
    }

    // Shaft (slightly curved)
    final Path shaftPath = Path()
      ..moveTo(w * 0.2, h * 0.1)
      ..quadraticBezierTo(w * 0.4, h * 0.5, w * 0.8, h * 0.9);
    canvas.drawPath(shaftPath, paint);

    // Blade (sharp curve)
    final Paint bladePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final Path bladePath = Path()
      ..moveTo(w * 0.2, h * 0.1)
      ..quadraticBezierTo(w * 0.1, h * 0.05, 0, h * 0.05) // Tip
      ..quadraticBezierTo(w * 0.4, h * 0.2, w * 0.35, h * 0.35) // Curve back
      ..lineTo(w * 0.2, h * 0.1)
      ..close();
    canvas.drawPath(bladePath, bladePaint);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
