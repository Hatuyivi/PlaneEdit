import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../models/room.dart';

class FloorPlanPainter extends CustomPainter {
  final ui.Image image;
  final List<Room> rooms;
  final int? selectedIndex;
  final bool showLabels;

  static const List<Color> _palette = [
    Color(0x554CAF50),
    Color(0x552196F3),
    Color(0x55FF9800),
    Color(0x55E91E63),
    Color(0x559C27B0),
    Color(0x5500BCD4),
    Color(0x55FF5722),
    Color(0x55607D8B),
  ];

  static const List<Color> _paletteBorder = [
    Color(0xFF4CAF50),
    Color(0xFF2196F3),
    Color(0xFFFF9800),
    Color(0xFFE91E63),
    Color(0xFF9C27B0),
    Color(0xFF00BCD4),
    Color(0xFFFF5722),
    Color(0xFF607D8B),
  ];

  FloorPlanPainter({
    required this.image,
    required this.rooms,
    this.selectedIndex,
    this.showLabels = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Draw the floor plan image scaled to fit
    final src = Rect.fromLTWH(0, 0, image.width.toDouble(), image.height.toDouble());
    final dst = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawImageRect(image, src, dst, Paint());

    final scaleX = size.width / image.width;
    final scaleY = size.height / image.height;

    for (int i = 0; i < rooms.length; i++) {
      final room = rooms[i];
      final points = room.smoothedPolygon;
      if (points.length < 3) continue;

      final isSelected = selectedIndex == i;
      final color = _palette[i % _palette.length];
      final borderColor = _paletteBorder[i % _paletteBorder.length];

      final path = Path();
      path.moveTo(points[0].dx * scaleX, points[0].dy * scaleY);
      for (int j = 1; j < points.length; j++) {
        path.lineTo(points[j].dx * scaleX, points[j].dy * scaleY);
      }
      path.close();

      // Fill
      canvas.drawPath(
        path,
        Paint()
          ..color = isSelected ? color.withOpacity(0.75) : color
          ..style = PaintingStyle.fill,
      );

      // Border
      canvas.drawPath(
        path,
        Paint()
          ..color = borderColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 3.0 : 1.5,
      );

      // Label
      if (showLabels) {
        final center = _polygonCenter(points, scaleX, scaleY);
        _drawLabel(canvas, room.name, center, borderColor);
      }
    }
  }

  Offset _polygonCenter(List<Offset> points, double scaleX, double scaleY) {
    double cx = 0, cy = 0;
    for (final p in points) {
      cx += p.dx * scaleX;
      cy += p.dy * scaleY;
    }
    return Offset(cx / points.length, cy / points.length);
  }

  void _drawLabel(Canvas canvas, String text, Offset center, Color color) {
    final span = TextSpan(
      text: text,
      style: TextStyle(
        color: Colors.white,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        shadows: [Shadow(color: Colors.black87, blurRadius: 3)],
      ),
    );
    final tp = TextPainter(text: span, textDirection: TextDirection.ltr);
    tp.layout();

    // Background pill
    final rect = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: center,
        width: tp.width + 10,
        height: tp.height + 6,
      ),
      const Radius.circular(4),
    );
    canvas.drawRRect(rect, Paint()..color = color.withOpacity(0.85));

    tp.paint(canvas, center - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(FloorPlanPainter old) =>
      old.image != image ||
      old.rooms != rooms ||
      old.selectedIndex != selectedIndex ||
      old.showLabels != showLabels;
}
