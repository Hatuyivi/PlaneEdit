import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:file_selector/file_selector.dart';
import '../models/room.dart';
import '../services/gemini_service.dart';
import '../widgets/floor_plan_painter.dart';

class HomeScreen extends StatefulWidget {
  final String apiKey;
  const HomeScreen({super.key, required this.apiKey});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  File? _imageFile;
  ui.Image? _uiImage;
  List<Room> _rooms = [];
  bool _loading = false;
  String? _error;
  int? _selectedIndex;
  bool _showLabels = true;
  double _smoothing = 3.0;

  Future<void> _pickImage() async {
    const typeGroup = XTypeGroup(label: 'images', extensions: ['jpg', 'jpeg', 'png']);
    final file = await openFile(acceptedTypeGroups: [typeGroup]);
    if (file == null) return;
    final ioFile = File(file.path);
    final bytes = await ioFile.readAsBytes();
    final codec = await ui.instantiateImageCodec(bytes);
    final frame = await codec.getNextFrame();
    setState(() {
      _imageFile = ioFile;
      _uiImage = frame.image;
      _rooms = [];
      _error = null;
      _selectedIndex = null;
    });
  }

  Future<void> _analyze() async {
    if (_imageFile == null || _uiImage == null) return;
    setState(() { _loading = true; _error = null; _rooms = []; _selectedIndex = null; });
    try {
      final service = GeminiService(apiKey: widget.apiKey);
      final rooms = await service.detectRooms(
        imageFile: _imageFile!,
        imageWidth: _uiImage!.width,
        imageHeight: _uiImage!.height,
        smoothingEpsilon: _smoothing,
      );
      setState(() => _rooms = rooms);
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1D27),
        title: const Text('Floor Plan AI', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
        actions: [
          if (_rooms.isNotEmpty)
            IconButton(
              icon: Icon(_showLabels ? Icons.label : Icons.label_off, color: Colors.white70),
              onPressed: () => setState(() => _showLabels = !_showLabels),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _uiImage == null
                ? Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.architecture, size: 72, color: Color(0x1FFFFFFF)),
                    const SizedBox(height: 16),
                    const Text('Load a floor plan to get started', style: TextStyle(color: Color(0x61FFFFFF), fontSize: 16)),
                  ]))
                : Container(
                    margin: const EdgeInsets.all(12),
                    decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.4), blurRadius: 16)]),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: CustomPaint(
                        painter: FloorPlanPainter(image: _uiImage!, rooms: _rooms, selectedIndex: _selectedIndex, showLabels: _showLabels),
                        child: AspectRatio(aspectRatio: _uiImage!.width / _uiImage!.height),
                      ),
                    ),
                  ),
          ),
          Container(
            color: const Color(0xFF1A1D27),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (_uiImage != null) ...[
                  Row(children: [
                    const Text('Smoothing', style: TextStyle(color: Color(0x8AFFFFFF), fontSize: 13)),
                    Expanded(child: Slider(value: _smoothing, min: 0.5, max: 10.0, divisions: 19, activeColor: const Color(0xFF4F8EF7), inactiveColor: Colors.white12, onChanged: (v) => setState(() => _smoothing = v))),
                    Text(_smoothing.toStringAsFixed(1), style: const TextStyle(color: Color(0x8AFFFFFF), fontSize: 13)),
                  ]),
                  const SizedBox(height: 8),
                ],
                if (_rooms.isNotEmpty) ...[
                  SizedBox(
                    height: 36,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: _rooms.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (ctx, i) {
                        final selected = _selectedIndex == i;
                        return GestureDetector(
                          onTap: () => setState(() => _selectedIndex = selected ? null : i),
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: selected ? const Color(0xFF4F8EF7) : Colors.white10,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: selected ? const Color(0xFF4F8EF7) : Colors.white12),
                            ),
                            child: Text(_rooms[i].name, style: TextStyle(color: selected ? Colors.white : Colors.white60, fontSize: 13, fontWeight: selected ? FontWeight.w600 : FontWeight.normal)),
                          ),
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                if (_error != null) ...[
                  Container(
                    padding: const EdgeInsets.all(10),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(color: Colors.red.withOpacity(0.15), borderRadius: BorderRadius.circular(8), border: Border.all(color: Colors.red.withOpacity(0.3))),
                    child: Text(_error!, style: const TextStyle(color: Colors.redAccent, fontSize: 12)),
                  ),
                ],
                Row(children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: _loading ? null : _pickImage,
                      icon: const Icon(Icons.photo_library_outlined, size: 18),
                      label: const Text('Choose Image'),
                      style: OutlinedButton.styleFrom(foregroundColor: Colors.white70, side: const BorderSide(color: Colors.white24), padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                    ),
                  ),
                  if (_uiImage != null) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton.icon(
                        onPressed: _loading ? null : _analyze,
                        icon: _loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.auto_fix_high, size: 18),
                        label: Text(_loading ? 'Analyzing...' : 'Detect Rooms'),
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF4F8EF7), foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                      ),
                    ),
                  ],
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
