import 'dart:convert';
import 'dart:io';
import 'dart:ui';
import 'package:http/http.dart' as http;
import '../models/room.dart';
import '../utils/douglas_peucker.dart';

class GeminiService {
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';

  final String apiKey;

  GeminiService({required this.apiKey});

  Future<List<Room>> detectRooms({
    required File imageFile,
    required int imageWidth,
    required int imageHeight,
    double smoothingEpsilon = 3.0,
  }) async {
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);
    final ext = imageFile.path.split('.').last.toLowerCase();
    final mimeType = ext == 'png' ? 'image/png' : 'image/jpeg';

    final prompt = '''
You are analyzing a floor plan image of size ${imageWidth}x${imageHeight} pixels.

Find ALL rooms and enclosed spaces in this floor plan.
For each room, return a polygon that traces its boundary as accurately as possible.
Use actual pixel coordinates from the image (0,0 is top-left).

Return ONLY a valid JSON object with no extra text, no markdown, no backticks:
{
  "rooms": [
    {
      "name": "Room name (e.g. Bedroom, Kitchen, Bathroom, Living Room, Hallway)",
      "polygon": [[x1,y1],[x2,y2],[x3,y3],...]
    }
  ]
}

Rules:
- Polygon points must follow the actual walls of the room
- Include at least 4 points per room, more for complex shapes
- Coordinates must be within 0-${imageWidth} for x and 0-${imageHeight} for y
- Close each polygon (last point connects back to first)
- Do not include furniture, only room boundaries
''';

    final body = jsonEncode({
      'contents': [
        {
          'parts': [
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              }
            },
            {'text': prompt},
          ]
        }
      ],
      'generationConfig': {
        'temperature': 0.1,
        'maxOutputTokens': 4096,
      }
    });

    final response = await http.post(
      Uri.parse('$_baseUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    if (response.statusCode != 200) {
      throw Exception('Gemini API error ${response.statusCode}: ${response.body}');
    }

    final data = jsonDecode(response.body);
    final text = data['candidates'][0]['content']['parts'][0]['text'] as String;

    // Strip possible markdown fences
    final cleaned = text
        .replaceAll('```json', '')
        .replaceAll('```', '')
        .trim();

    final parsed = jsonDecode(cleaned);
    final roomsJson = parsed['rooms'] as List<dynamic>;

    return roomsJson.map((r) {
      final name = r['name'] as String;
      final rawPoints = (r['polygon'] as List<dynamic>)
          .map((p) => Offset((p[0] as num).toDouble(), (p[1] as num).toDouble()))
          .toList();

      final smoothed = DouglasPeucker.simplify(rawPoints, smoothingEpsilon);

      return Room(name: name, polygon: rawPoints, smoothedPolygon: smoothed);
    }).toList();
  }
}
