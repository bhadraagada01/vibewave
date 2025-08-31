import 'dart:convert';

class Song {
  final String title;
  final String artist;
  final String url;

  Song({required this.title, required this.artist, required this.url});

  // Convert Song to JSON
  Map<String, dynamic> toJson() {
    return {'title': title, 'artist': artist, 'url': url};
  }

  // Create Song from JSON
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      title: json['title'] ?? '',
      artist: json['artist'] ?? '',
      url: json['url'] ?? '',
    );
  }

  // Convert list of Songs to JSON string
  static String listToJson(List<Song> songs) {
    return jsonEncode(songs.map((song) => song.toJson()).toList());
  }

  // Convert JSON string to list of Songs
  static List<Song> listFromJson(String jsonString) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Song.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing songs JSON: $e');
      return [];
    }
  }

  @override
  String toString() {
    return 'Song(title: $title, artist: $artist, url: $url)';
  }
}

class Playlist {
  final String id;
  final String name;
  final String mood;
  final String description;
  final List<Song> songs;
  final DateTime createdAt;

  Playlist({
    required this.id,
    required this.name,
    required this.mood,
    required this.description,
    required this.songs,
    required this.createdAt,
  });

  // Convert Playlist to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'mood': mood,
      'description': description,
      'songs': songs.map((song) => song.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  // Create Playlist from JSON
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      mood: json['mood'] ?? '',
      description: json['description'] ?? '',
      songs:
          (json['songs'] as List<dynamic>?)
              ?.map((songJson) => Song.fromJson(songJson))
              .toList() ??
          [],
      createdAt: DateTime.tryParse(json['createdAt'] ?? '') ?? DateTime.now(),
    );
  }

  // Convert list of Playlists to JSON string
  static String listToJson(List<Playlist> playlists) {
    return jsonEncode(playlists.map((playlist) => playlist.toJson()).toList());
  }

  // Convert JSON string to list of Playlists
  static List<Playlist> listFromJson(String jsonString) {
    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.map((json) => Playlist.fromJson(json)).toList();
    } catch (e) {
      print('Error parsing playlists JSON: $e');
      return [];
    }
  }
}
