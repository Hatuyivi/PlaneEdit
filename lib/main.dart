import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const FloorPlanApp());
}

class FloorPlanApp extends StatelessWidget {
  const FloorPlanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Floor Plan AI',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFF4F8EF7),
          surface: const Color(0xFF1A1D27),
        ),
      ),
      home: const ApiKeyGate(),
    );
  }
}

/// Simple screen to enter the Gemini API key (stored in memory only)
class ApiKeyGate extends StatefulWidget {
  const ApiKeyGate({super.key});

  @override
  State<ApiKeyGate> createState() => _ApiKeyGateState();
}

class _ApiKeyGateState extends State<ApiKeyGate> {
  final _controller = TextEditingController();
  String? _key;

  @override
  Widget build(BuildContext context) {
    if (_key != null) {
      return HomeScreen(apiKey: _key!);
    }

    return Scaffold(
      backgroundColor: const Color(0xFF0F1117),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.key, size: 48, color: Color(0xFF4F8EF7)),
              const SizedBox(height: 24),
              const Text(
                'Enter Gemini API Key',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Get a free key at aistudio.google.com',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white38, fontSize: 13),
              ),
              const SizedBox(height: 28),
              TextField(
                controller: _controller,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'AIza...',
                  hintStyle: const TextStyle(color: Colors.white24),
                  filled: true,
                  fillColor: Colors.white10,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  final key = _controller.text.trim();
                  if (key.isNotEmpty) setState(() => _key = key);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4F8EF7),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Continue',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
