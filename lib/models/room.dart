import 'dart:ui';

class Room {
  final String name;
  final List<Offset> polygon; // raw points from Gemini
  final List<Offset> smoothedPolygon; // after Douglas-Peucker

  const Room({
    required this.name,
    required this.polygon,
    required this.smoothedPolygon,
  });
}
