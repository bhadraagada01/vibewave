import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models/song.dart';
import 'playlist_page.dart';
import 'services/gemini_service.dart';
import 'utils/storage.dart';

class HomePage extends StatefulWidget {
  final String geminiApiKey;

  const HomePage({super.key, required this.geminiApiKey});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  String selectedMood = '😊';
  String selectedGenre = 'Any';
  final TextEditingController _descriptionController = TextEditingController();
  int selectedCount = 10;
  bool isLoading = false;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  final Map<String, Map<String, dynamic>> moodOptions = {
    '😊': {
      'label': 'Happy',
      'color': Colors.orange,
      'gradient': [Colors.orange.shade300, Colors.yellow.shade300],
    },
    '😔': {
      'label': 'Sad',
      'color': Colors.blue,
      'gradient': [Colors.blue.shade300, Colors.indigo.shade300],
    },
    '🧊': {
      'label': 'Chill',
      'color': Colors.teal,
      'gradient': [Colors.teal.shade300, Colors.cyan.shade300],
    },
    '⚡': {
      'label': 'Energetic',
      'color': Colors.red,
      'gradient': [Colors.red.shade300, Colors.pink.shade300],
    },
    '💭': {
      'label': 'Nostalgic',
      'color': Colors.purple,
      'gradient': [Colors.purple.shade300, Colors.deepPurple.shade300],
    },
    '🌙': {
      'label': 'Late Night',
      'color': Colors.indigo,
      'gradient': [Colors.indigo.shade400, Colors.blue.shade900],
    },
  };

  final List<String> genreOptions = [
    'Any',
    'Pop',
    'Rock',
    'Hip Hop',
    'Electronic',
    'Jazz',
    'Classical',
    'Country',
    'R&B',
    'Indie',
    'Alternative',
    'Folk',
    'Reggae',
    'Blues',
    'Metal',
  ];

  final List<int> countOptions = [5, 10, 15, 20, 25, 30];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _generatePlaylist() async {
    if (isLoading) return;

    setState(() {
      isLoading = true;
    });

    try {
      final geminiService = GeminiService(widget.geminiApiKey);
      final songs = await geminiService.fetchPlaylist(
        moodEmoji: selectedMood,
        description: _descriptionController.text.trim(),
        count: selectedCount,
        genre: selectedGenre,
      );

      if (songs.isNotEmpty) {
        // Create playlist object
        final playlist = Playlist(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          name: '${moodOptions[selectedMood]!['label']} Playlist',
          mood: selectedMood,
          description: _descriptionController.text.trim(),
          songs: songs,
          createdAt: DateTime.now(),
        );

        // Save to recent playlists
        await StorageService.saveRecentPlaylist(playlist);

        // Update user stats
        await StorageService.updateUserStats(playlist);

        // Navigate to playlist page
        if (mounted) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PlaylistPage(playlist: playlist),
            ),
          );
        }
      } else {
        _showErrorDialog('No songs were generated. Please try again.');
      }
    } catch (e) {
      _showErrorDialog('Failed to generate playlist: $e');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _generateRandomMood() {
    final randomMood = moodOptions.keys.elementAt(
      DateTime.now().millisecond % moodOptions.length,
    );
    HapticFeedback.mediumImpact();
    setState(() {
      selectedMood = randomMood;
    });
  }

  void _generateSurpriseMe() async {
    final surpriseDescriptions = [
      'Take me on a musical journey',
      'Something I\'ve never heard before',
      'Hidden gems and rare finds',
      'Mix of old and new classics',
      'International vibes',
      'Underground favorites',
    ];

    final randomDescription =
        surpriseDescriptions[DateTime.now().millisecond %
            surpriseDescriptions.length];

    _descriptionController.text = randomDescription;
    _generateRandomMood();
    await Future.delayed(const Duration(milliseconds: 500));
    _generatePlaylist();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'MoodBeats Lite',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            onPressed: _generateSurpriseMe,
            icon: const Icon(Icons.shuffle),
            tooltip: 'Surprise Me!',
          ),
          IconButton(
            onPressed: _generateRandomMood,
            icon: const Icon(Icons.casino),
            tooltip: 'Random Mood',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Welcome section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.1),
                      Theme.of(context).primaryColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  children: [
                    const Text('🎵', style: TextStyle(fontSize: 48)),
                    const SizedBox(height: 8),
                    const Text(
                      'How are you feeling?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Let AI create the perfect playlist for your mood',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Mood selection grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1.8,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                ),
                itemCount: moodOptions.length,
                itemBuilder: (context, index) {
                  final mood = moodOptions.keys.elementAt(index);
                  final moodData = moodOptions[mood]!;
                  final label = moodData['label'] as String;
                  final color = moodData['color'] as Color;
                  final gradient = moodData['gradient'] as List<Color>;
                  final isSelected = selectedMood == mood;

                  return GestureDetector(
                    onTap: () {
                      HapticFeedback.lightImpact();
                      setState(() {
                        selectedMood = mood;
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        gradient: isSelected
                            ? LinearGradient(
                                colors: gradient,
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              )
                            : null,
                        color: isSelected ? null : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? color
                              : Colors.grey.withOpacity(0.3),
                          width: isSelected ? 3 : 1,
                        ),
                        boxShadow: isSelected
                            ? [
                                BoxShadow(
                                  color: color.withOpacity(0.3),
                                  blurRadius: 8,
                                  offset: const Offset(0, 4),
                                ),
                              ]
                            : null,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: TextStyle(fontSize: isSelected ? 36 : 32),
                            child: Text(mood),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            label,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(
                                      context,
                                    ).textTheme.bodyMedium?.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 28),

              // Description text field with better styling
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _descriptionController,
                  decoration: InputDecoration(
                    labelText: 'Describe your mood (optional)',
                    hintText:
                        'E.g., feeling nostalgic, need motivation, working out...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.transparent,
                    prefixIcon: const Icon(Icons.edit_note_rounded),
                  ),
                  maxLines: 3,
                  minLines: 1,
                ),
              ),

              const SizedBox(height: 24),

              // Genre selection
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.library_music_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Music Genre:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      value: selectedGenre,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade600),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: Colors.grey.shade600),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      dropdownColor: Colors.grey.shade800,
                      style: const TextStyle(color: Colors.white),
                      items: genreOptions.map((genre) {
                        return DropdownMenuItem<String>(
                          value: genre,
                          child: Text(
                            genre,
                            style: const TextStyle(color: Colors.white),
                          ),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedGenre = value!;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              // Song count selection with better UI
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  color: Theme.of(context).cardColor,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.queue_music_rounded, color: Colors.white),
                        SizedBox(width: 8),
                        Text(
                          'Number of songs:',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: countOptions.map((count) {
                        final isSelected = selectedCount == count;
                        return GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            setState(() {
                              selectedCount = count;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.deepPurple.shade400
                                  : Colors.grey.shade700,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? Colors.deepPurple.shade300
                                    : Colors.grey.shade500,
                                width: isSelected ? 2 : 1,
                              ),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: Colors.deepPurple.shade300
                                            .withOpacity(0.3),
                                        blurRadius: 8,
                                        offset: const Offset(0, 2),
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Text(
                              '$count',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: isSelected
                                    ? Colors.white
                                    : Colors.grey.shade300,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Enhanced generate button
              Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    colors: isLoading
                        ? [Colors.grey.shade400, Colors.grey.shade500]
                        : (moodOptions[selectedMood]!['gradient']
                              as List<Color>),
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: isLoading
                      ? null
                      : [
                          BoxShadow(
                            color:
                                (moodOptions[selectedMood]!['color'] as Color)
                                    .withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ],
                ),
                child: ElevatedButton(
                  onPressed: isLoading ? null : _generatePlaylist,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Generating...',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.auto_awesome_rounded,
                              color: Colors.white,
                              size: 24,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Generate My Playlist',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
