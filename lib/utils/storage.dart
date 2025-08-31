import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/song.dart';

class StorageService {
  static const String _favoritesKey = 'favorite_playlists';
  static const String _recentPlaylistsKey = 'recent_playlists';
  static const String _playlistHistoryKey = 'playlist_history';
  static const String _userStatsKey = 'user_stats';

  // Save a playlist to favorites
  static Future<void> saveFavoritePlaylist(Playlist playlist) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Playlist> favorites = await getFavoritePlaylists();

      // Check if playlist already exists (by ID)
      bool exists = favorites.any((p) => p.id == playlist.id);
      if (!exists) {
        favorites.add(playlist);
        String jsonString = Playlist.listToJson(favorites);
        await prefs.setString(_favoritesKey, jsonString);
      }
    } catch (e) {
      print('Error saving favorite playlist: $e');
    }
  }

  // Remove a playlist from favorites
  static Future<void> removeFavoritePlaylist(String playlistId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Playlist> favorites = await getFavoritePlaylists();

      favorites.removeWhere((playlist) => playlist.id == playlistId);
      String jsonString = Playlist.listToJson(favorites);
      await prefs.setString(_favoritesKey, jsonString);
    } catch (e) {
      print('Error removing favorite playlist: $e');
    }
  }

  // Get all favorite playlists
  static Future<List<Playlist>> getFavoritePlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_favoritesKey);

      if (jsonString != null) {
        return Playlist.listFromJson(jsonString);
      }
      return [];
    } catch (e) {
      print('Error getting favorite playlists: $e');
      return [];
    }
  }

  // Check if a playlist is favorite
  static Future<bool> isPlaylistFavorite(String playlistId) async {
    try {
      List<Playlist> favorites = await getFavoritePlaylists();
      return favorites.any((playlist) => playlist.id == playlistId);
    } catch (e) {
      print('Error checking if playlist is favorite: $e');
      return false;
    }
  }

  // Clear all favorites
  static Future<void> clearAllFavorites() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_favoritesKey);
    } catch (e) {
      print('Error clearing favorites: $e');
    }
  }

  // Save to recent playlists (max 10)
  static Future<void> saveRecentPlaylist(Playlist playlist) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Playlist> recent = await getRecentPlaylists();

      // Remove if already exists
      recent.removeWhere((p) => p.id == playlist.id);

      // Add to beginning
      recent.insert(0, playlist);

      // Keep only last 10
      if (recent.length > 10) {
        recent = recent.take(10).toList();
      }

      String jsonString = Playlist.listToJson(recent);
      await prefs.setString(_recentPlaylistsKey, jsonString);

      // Also save to history
      await saveToHistory(playlist);
    } catch (e) {
      print('Error saving recent playlist: $e');
    }
  }

  // Save to complete history
  static Future<void> saveToHistory(Playlist playlist) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      List<Playlist> history = await getPlaylistHistory();

      // Remove if already exists
      history.removeWhere((p) => p.id == playlist.id);

      // Add to beginning
      history.insert(0, playlist);

      String jsonString = Playlist.listToJson(history);
      await prefs.setString(_playlistHistoryKey, jsonString);
    } catch (e) {
      print('Error saving to history: $e');
    }
  }

  // Get recent playlists
  static Future<List<Playlist>> getRecentPlaylists() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_recentPlaylistsKey);

      if (jsonString != null) {
        return Playlist.listFromJson(jsonString);
      }
      return [];
    } catch (e) {
      print('Error getting recent playlists: $e');
      return [];
    }
  }

  // Get playlist history
  static Future<List<Playlist>> getPlaylistHistory() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_playlistHistoryKey);

      if (jsonString != null) {
        return Playlist.listFromJson(jsonString);
      }
      return [];
    } catch (e) {
      print('Error getting playlist history: $e');
      return [];
    }
  }

  // User statistics
  static Future<Map<String, dynamic>> getUserStats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      String? jsonString = prefs.getString(_userStatsKey);

      if (jsonString != null) {
        return Map<String, dynamic>.from(jsonDecode(jsonString));
      }
      return {
        'totalPlaylists': 0,
        'favoriteGenres': <String, int>{},
        'moodUsage': <String, int>{},
        'totalSongs': 0,
      };
    } catch (e) {
      print('Error getting user stats: $e');
      return {};
    }
  }

  // Update user statistics
  static Future<void> updateUserStats(Playlist playlist) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      Map<String, dynamic> stats = await getUserStats();

      stats['totalPlaylists'] = (stats['totalPlaylists'] ?? 0) + 1;
      stats['totalSongs'] = (stats['totalSongs'] ?? 0) + playlist.songs.length;

      // Track mood usage
      Map<String, dynamic> moodUsage = Map<String, dynamic>.from(
        stats['moodUsage'] ?? {},
      );
      moodUsage[playlist.mood] = (moodUsage[playlist.mood] ?? 0) + 1;
      stats['moodUsage'] = moodUsage;

      await prefs.setString(_userStatsKey, jsonEncode(stats));
    } catch (e) {
      print('Error updating user stats: $e');
    }
  }
}
