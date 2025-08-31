import 'package:google_generative_ai/google_generative_ai.dart';

import '../models/song.dart';

class GeminiService {
  final GenerativeModel _model;

  GeminiService(String apiKey)
    : _model = GenerativeModel(model: 'gemini-1.5-flash', apiKey: apiKey);

  Future<List<Song>> fetchPlaylist({
    required String moodEmoji,
    required String description,
    required int count,
    String genre = 'Any',
  }) async {
    final genreText = genre != 'Any' ? ' in the $genre genre' : '';
    final prompt =
        '''
You are a music expert. Generate $count real, popular songs that perfectly match this mood$genreText:

Emoji: $moodEmoji
Description: "$description"

For each song, provide the exact song title and artist name that exists on YouTube.

Mood meanings:
- 😊 Happy: Upbeat, joyful, feel-good songs
- 😔 Sad: Melancholic, emotional, slower songs  
- 🧊 Chill: Relaxing, ambient, lo-fi, calm vibes
- ⚡ Energetic: High-energy, workout, pump-up songs
- 💭 Nostalgic: Throwback, retro, memory-inducing songs
- 🌙 Late Night: Moody, atmospheric, late-night vibes

Return ONLY a valid JSON array in this exact format:
[
  {
    "title": "Exact Song Title",
    "artist": "Artist Name",
    "url": "https://www.youtube.com/results?search_query=Artist+Name+Exact+Song+Title"
  }
]

Requirements:
- Use real song titles and artist names
- Songs must be popular and well-known
- Format URLs as YouTube search queries (replace spaces with +)
- Return only the JSON array, no other text
- Match the mood exactly
${genreText.isNotEmpty ? '- Focus specifically on $genre music' : ''}
''';

    try {
      final res = await _model.generateContent([Content.text(prompt)]);
      final responseText = res.text ?? '[]';

      // Clean the response text to extract JSON
      String cleanedJson = _extractJsonFromResponse(responseText);

      print('Gemini Response: $cleanedJson');
      List<Song> songs = Song.listFromJson(cleanedJson);

      // Enhance URLs to be proper YouTube search queries
      songs = songs
          .map(
            (song) => Song(
              title: song.title,
              artist: song.artist,
              url: _createYouTubeSearchUrl(song.artist, song.title),
            ),
          )
          .toList();

      return songs.isNotEmpty ? songs : _getFallbackPlaylist(moodEmoji, count);
    } catch (e) {
      print('Error fetching playlist from Gemini: $e');
      // Return a fallback playlist if Gemini fails
      return _getFallbackPlaylist(moodEmoji, count);
    }
  }

  String _createYouTubeSearchUrl(String artist, String title) {
    // Create a proper YouTube search URL
    String searchQuery = '$artist $title'
        .replaceAll(' ', '+')
        .replaceAll('&', 'and');
    return 'https://www.youtube.com/results?search_query=$searchQuery';
  }

  String _extractJsonFromResponse(String response) {
    // Remove any markdown formatting or extra text
    String cleaned = response.trim();

    // Find JSON array start and end
    int startIndex = cleaned.indexOf('[');
    int endIndex = cleaned.lastIndexOf(']');

    if (startIndex != -1 && endIndex != -1 && endIndex > startIndex) {
      return cleaned.substring(startIndex, endIndex + 1);
    }

    return '[]';
  }

  List<Song> _getFallbackPlaylist(String moodEmoji, int count) {
    // Fallback playlists based on mood
    final Map<String, List<Song>> fallbackSongs = {
      '😊': [
        Song(
          title: 'Happy',
          artist: 'Pharrell Williams',
          url: _createYouTubeSearchUrl('Pharrell Williams', 'Happy'),
        ),
        Song(
          title: 'Good as Hell',
          artist: 'Lizzo',
          url: _createYouTubeSearchUrl('Lizzo', 'Good as Hell'),
        ),
        Song(
          title: 'Walking on Sunshine',
          artist: 'Katrina and the Waves',
          url: _createYouTubeSearchUrl(
            'Katrina and the Waves',
            'Walking on Sunshine',
          ),
        ),
        Song(
          title: 'Can\'t Stop the Feeling!',
          artist: 'Justin Timberlake',
          url: _createYouTubeSearchUrl(
            'Justin Timberlake',
            'Can\'t Stop the Feeling!',
          ),
        ),
        Song(
          title: 'Uptown Funk',
          artist: 'Mark Ronson ft. Bruno Mars',
          url: _createYouTubeSearchUrl('Mark Ronson Bruno Mars', 'Uptown Funk'),
        ),
      ],
      '😔': [
        Song(
          title: 'Someone Like You',
          artist: 'Adele',
          url: _createYouTubeSearchUrl('Adele', 'Someone Like You'),
        ),
        Song(
          title: 'Mad World',
          artist: 'Gary Jules',
          url: _createYouTubeSearchUrl('Gary Jules', 'Mad World'),
        ),
        Song(
          title: 'Hurt',
          artist: 'Johnny Cash',
          url: _createYouTubeSearchUrl('Johnny Cash', 'Hurt'),
        ),
        Song(
          title: 'Black',
          artist: 'Pearl Jam',
          url: _createYouTubeSearchUrl('Pearl Jam', 'Black'),
        ),
        Song(
          title: 'Tears in Heaven',
          artist: 'Eric Clapton',
          url: _createYouTubeSearchUrl('Eric Clapton', 'Tears in Heaven'),
        ),
      ],
      '🧊': [
        Song(
          title: 'Weightless',
          artist: 'Marconi Union',
          url: _createYouTubeSearchUrl('Marconi Union', 'Weightless'),
        ),
        Song(
          title: 'Clair de Lune',
          artist: 'Claude Debussy',
          url: _createYouTubeSearchUrl('Claude Debussy', 'Clair de Lune'),
        ),
        Song(
          title: 'Sunset Lover',
          artist: 'Petit Biscuit',
          url: _createYouTubeSearchUrl('Petit Biscuit', 'Sunset Lover'),
        ),
        Song(
          title: 'Porcelain',
          artist: 'Moby',
          url: _createYouTubeSearchUrl('Moby', 'Porcelain'),
        ),
        Song(
          title: 'Holocene',
          artist: 'Bon Iver',
          url: _createYouTubeSearchUrl('Bon Iver', 'Holocene'),
        ),
      ],
      '⚡': [
        Song(
          title: 'Eye of the Tiger',
          artist: 'Survivor',
          url: _createYouTubeSearchUrl('Survivor', 'Eye of the Tiger'),
        ),
        Song(
          title: 'Thunder',
          artist: 'Imagine Dragons',
          url: _createYouTubeSearchUrl('Imagine Dragons', 'Thunder'),
        ),
        Song(
          title: 'Pump It',
          artist: 'The Black Eyed Peas',
          url: _createYouTubeSearchUrl('The Black Eyed Peas', 'Pump It'),
        ),
        Song(
          title: 'Till I Collapse',
          artist: 'Eminem',
          url: _createYouTubeSearchUrl('Eminem', 'Till I Collapse'),
        ),
        Song(
          title: 'Stronger',
          artist: 'Kelly Clarkson',
          url: _createYouTubeSearchUrl('Kelly Clarkson', 'Stronger'),
        ),
      ],
      '💭': [
        Song(
          title: 'Sweet Caroline',
          artist: 'Neil Diamond',
          url: _createYouTubeSearchUrl('Neil Diamond', 'Sweet Caroline'),
        ),
        Song(
          title: 'Don\'t Stop Believin\'',
          artist: 'Journey',
          url: _createYouTubeSearchUrl('Journey', 'Don\'t Stop Believin\''),
        ),
        Song(
          title: 'Take On Me',
          artist: 'a-ha',
          url: _createYouTubeSearchUrl('a-ha', 'Take On Me'),
        ),
        Song(
          title: 'Africa',
          artist: 'Toto',
          url: _createYouTubeSearchUrl('Toto', 'Africa'),
        ),
        Song(
          title: 'Bohemian Rhapsody',
          artist: 'Queen',
          url: _createYouTubeSearchUrl('Queen', 'Bohemian Rhapsody'),
        ),
      ],
      '🌙': [
        Song(
          title: 'Nightcall',
          artist: 'Kavinsky',
          url: _createYouTubeSearchUrl('Kavinsky', 'Nightcall'),
        ),
        Song(
          title: 'Midnight City',
          artist: 'M83',
          url: _createYouTubeSearchUrl('M83', 'Midnight City'),
        ),
        Song(
          title: 'The Night We Met',
          artist: 'Lord Huron',
          url: _createYouTubeSearchUrl('Lord Huron', 'The Night We Met'),
        ),
        Song(
          title: 'Blinding Lights',
          artist: 'The Weeknd',
          url: _createYouTubeSearchUrl('The Weeknd', 'Blinding Lights'),
        ),
        Song(
          title: 'Electric Feel',
          artist: 'MGMT',
          url: _createYouTubeSearchUrl('MGMT', 'Electric Feel'),
        ),
      ],
    };

    final moodSongs = fallbackSongs[moodEmoji] ?? fallbackSongs['😊']!;
    return moodSongs.take(count).toList();
  }
}
