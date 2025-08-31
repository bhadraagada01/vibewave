import 'package:flutter/material.dart';

import 'favourites_page.dart';
import 'history_page.dart';
import 'home_page.dart';

void main() {
  runApp(const MoodBeatsApp());
}

class MoodBeatsApp extends StatelessWidget {
  const MoodBeatsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MoodBeats Lite',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFF0D1117),
        cardColor: const Color(0xFF161B22),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161B22),
          elevation: 0,
        ),
      ),
      themeMode: ThemeMode.dark, // Default to dark mode
      home: const MainScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  String? _geminiApiKey;

  @override
  void initState() {
    super.initState();
    _checkApiKey();
  }

  void _checkApiKey() {
    // For development, you can set a default key or use --dart-define
    const String? apiKey = String.fromEnvironment('GEMINI_API_KEY');

    if (apiKey.isEmpty) {
      // Show dialog to enter API key
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showApiKeyDialog();
      });
    } else {
      _geminiApiKey = apiKey;
    }
  }

  void _showApiKeyDialog() {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Gemini API Key Required'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Please enter your Gemini API key to use the playlist generator:',
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                decoration: const InputDecoration(
                  labelText: 'API Key',
                  hintText: 'Your Gemini API key',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 8),
              const Text(
                'Get your free API key from: https://ai.google.dev/',
                style: TextStyle(fontSize: 12, color: Colors.blue),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (controller.text.trim().isNotEmpty) {
                  setState(() {
                    _geminiApiKey = controller.text.trim();
                  });
                  Navigator.of(context).pop();
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> get _pages {
    if (_geminiApiKey == null) {
      return [
        const Center(child: CircularProgressIndicator()),
        const FavouritesPage(),
        const HistoryPage(),
      ];
    }

    return [
      HomePage(geminiApiKey: _geminiApiKey!),
      const FavouritesPage(),
      const HistoryPage(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          selectedItemColor: Theme.of(context).primaryColor,
          unselectedItemColor: Colors.grey,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.favorite_border_rounded),
              activeIcon: Icon(Icons.favorite),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              activeIcon: Icon(Icons.history),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
