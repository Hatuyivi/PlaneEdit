import 'dart:math';
import 'dart:ui';

class DouglasPeucker {
  /// Simplifies a polygon using the Douglas-Peucker algorithm.
  /// [epsilon] — max allowed deviation in pixels (higher = smoother, less detail)
  static List<Offset> simplify(List<Offset> points, double epsilon) {
    if (points.length < 3) return points;

    double maxDist = 0;
    int maxIndex = 0;

    for (int i = 1; i < points.length - 1; i++) {
      double dist = _perpendicularDistance(
        points[i],
        points.first,
        points.last,
      );
      if (dist > maxDist) {
        maxDist = dist;
        maxIndex = i;
      }
    }

    if (maxDist > epsilon) {
      final left = simplify(points.sublist(0, maxIndex + 1), epsilon);
      final right = simplify(points.sublist(maxIndex), epsilon);
      return [...left.sublist(0, left.length - 1), ...right];
    } else {
      return [points.first, points.last];
    }
  }

  static double _perpendicularDistance(Offset point, Offset lineStart, Offset lineEnd) {
    final dx = lineEnd.dx - lineStart.dx;
    final dy = lineEnd.dy - lineStart.dy;

    if (dx == 0 && dy == 0) {
      return sqrt(pow(point.dx - lineStart.dx, 2) + pow(point.dy - lineStart.dy, 2));
    }

    final t = ((point.dx - lineStart.dx) * dx + (point.dy - lineStart.dy) * dy) /
        (dx * dx + dy * dy);

    final nearest = Offset(lineStart.dx + t * dx, lineStart.dy + t * dy);
    return sqrt(pow(point.dx - nearest.dx, 2) + pow(point.dy - nearest.dy, 2));
  }
}
