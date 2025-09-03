import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'favourites_page.dart';
import 'history_page.dart';
import 'home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    print('Could not load .env file: $e');
  }

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
    // Try to load from .env file first
    String? apiKey = dotenv.env['GEMINI_API_KEY'];

    // Fallback to dart-define
    if (apiKey == null || apiKey.isEmpty) {
      const envApiKey = String.fromEnvironment('GEMINI_API_KEY');
      if (envApiKey.isNotEmpty) {
        apiKey = envApiKey;
      }
    }

    if (apiKey == null || apiKey.isEmpty) {
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
          selectedItemColor: Colors.deepPurple.shade300,
          unselectedItemColor: Colors.grey.shade500,
          selectedFontSize: 14,
          unselectedFontSize: 12,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
          items: [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.home_rounded,
                color: _currentIndex == 0
                    ? Colors.deepPurple.shade300
                    : Colors.grey.shade500,
              ),
              activeIcon: Icon(Icons.home, color: Colors.deepPurple.shade300),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite_border_rounded,
                color: _currentIndex == 1
                    ? Colors.deepPurple.shade300
                    : Colors.grey.shade500,
              ),
              activeIcon: Icon(
                Icons.favorite,
                color: Colors.deepPurple.shade300,
              ),
              label: 'Favorites',
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.history_rounded,
                color: _currentIndex == 2
                    ? Colors.deepPurple.shade300
                    : Colors.grey.shade500,
              ),
              activeIcon: Icon(
                Icons.history,
                color: Colors.deepPurple.shade300,
              ),
              label: 'History',
            ),
          ],
        ),
      ),
    );
  }
}
