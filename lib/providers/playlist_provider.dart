import 'package:flutter/foundation.dart';
import '../models/hive/playlist_adapter.dart';
import '../services/database_service.dart';
import 'package:uuid/uuid.dart';

class PlaylistProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();
  final Uuid _uuid = const Uuid();

  List<Playlist> _playlists = [];
  bool _isLoading = false;

  // Getters
  List<Playlist> get playlists => _playlists;
  bool get isLoading => _isLoading;

  /// Initialiser - Charger toutes les playlists depuis Hive
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      _playlists = _databaseService.getAllPlaylists();

      _isLoading = false;
      notifyListeners();

      print('✅ ${_playlists.length} playlists chargées');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('❌ Erreur chargement playlists: $e');
    }
  }

  /// Créer une nouvelle playlist
  Future<Playlist?> createPlaylist({
    required String name,
    String? description,
  }) async {
    try {
      final playlist = Playlist(
        id: _uuid.v4(),
        name: name,
        songIds: [],
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: description,
      );

      await _databaseService.createPlaylist(playlist);
      _playlists.add(playlist);
      notifyListeners();

      print('📁 Playlist créée: $name');
      return playlist;
    } catch (e) {
      print('❌ Erreur création playlist: $e');
      return null;
    }
  }

  /// Supprimer une playlist
  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _databaseService.deletePlaylist(playlistId);
      _playlists.removeWhere((p) => p.id == playlistId);
      notifyListeners();

      print('🗑️ Playlist supprimée');
    } catch (e) {
      print('❌ Erreur suppression playlist: $e');
    }
  }

  /// Renommer une playlist
  Future<void> renamePlaylist(String playlistId, String newName) async {
    try {
      final playlist = _playlists.firstWhere((p) => p.id == playlistId);
      final updatedPlaylist = playlist.copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updatePlaylist(updatedPlaylist);

      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        _playlists[index] = updatedPlaylist;
      }

      notifyListeners();
      print('✏️ Playlist renommée: $newName');
    } catch (e) {
      print('❌ Erreur renommage playlist: $e');
    }
  }

  /// Mettre à jour la description
  Future<void> updateDescription(String playlistId, String? description) async {
    try {
      final playlist = _playlists.firstWhere((p) => p.id == playlistId);
      final updatedPlaylist = playlist.copyWith(
        description: description,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updatePlaylist(updatedPlaylist);

      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        _playlists[index] = updatedPlaylist;
      }

      notifyListeners();
      print('✏️ Description mise à jour');
    } catch (e) {
      print('❌ Erreur mise à jour description: $e');
    }
  }

  /// Ajouter une chanson à une playlist
  Future<bool> addSongToPlaylist(String playlistId, String songId) async {
    try {
      await _databaseService.addSongToPlaylist(playlistId, songId);

      // Mettre à jour la liste locale
      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        final playlist = _playlists[index];
        if (!playlist.songIds.contains(songId)) {
          final updatedPlaylist = playlist.copyWith(
            songIds: [...playlist.songIds, songId],
            updatedAt: DateTime.now(),
          );
          _playlists[index] = updatedPlaylist;
          notifyListeners();
        }
      }

      print('➕ Chanson ajoutée à la playlist');
      return true;
    } catch (e) {
      print('❌ Erreur ajout chanson: $e');
      return false;
    }
  }

  /// Retirer une chanson d'une playlist
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      await _databaseService.removeSongFromPlaylist(playlistId, songId);

      // Mettre à jour la liste locale
      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        final playlist = _playlists[index];
        final updatedSongIds = List<String>.from(playlist.songIds);
        updatedSongIds.remove(songId);
        
        final updatedPlaylist = playlist.copyWith(
          songIds: updatedSongIds,
          updatedAt: DateTime.now(),
        );
        _playlists[index] = updatedPlaylist;
        notifyListeners();
      }

      print('➖ Chanson retirée de la playlist');
    } catch (e) {
      print('❌ Erreur retrait chanson: $e');
    }
  }

  /// Réorganiser les chansons dans une playlist (drag and drop)
  Future<void> reorderSongs(
    String playlistId,
    int oldIndex,
    int newIndex,
  ) async {
    try {
      final playlist = _playlists.firstWhere((p) => p.id == playlistId);
      final songIds = List<String>.from(playlist.songIds);

      // Ajuster l'index si nécessaire
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }

      final songId = songIds.removeAt(oldIndex);
      songIds.insert(newIndex, songId);

      final updatedPlaylist = playlist.copyWith(
        songIds: songIds,
        updatedAt: DateTime.now(),
      );

      await _databaseService.updatePlaylist(updatedPlaylist);

      final index = _playlists.indexWhere((p) => p.id == playlistId);
      if (index != -1) {
        _playlists[index] = updatedPlaylist;
      }

      notifyListeners();
      print('🔄 Ordre des chansons modifié');
    } catch (e) {
      print('❌ Erreur réorganisation: $e');
    }
  }

  /// Obtenir une playlist par ID
  Playlist? getPlaylistById(String playlistId) {
    try {
      return _playlists.firstWhere((p) => p.id == playlistId);
    } catch (e) {
      return null;
    }
  }

  /// Vérifier si une chanson est dans une playlist
  bool isSongInPlaylist(String playlistId, String songId) {
    try {
      final playlist = _playlists.firstWhere((p) => p.id == playlistId);
      return playlist.songIds.contains(songId);
    } catch (e) {
      return false;
    }
  }

  /// Obtenir toutes les playlists contenant une chanson
  List<Playlist> getPlaylistsContainingSong(String songId) {
    return _playlists.where((p) => p.songIds.contains(songId)).toList();
  }

  /// Dupliquer une playlist
  Future<Playlist?> duplicatePlaylist(String playlistId) async {
    try {
      final originalPlaylist = _playlists.firstWhere((p) => p.id == playlistId);
      
      final newPlaylist = Playlist(
        id: _uuid.v4(),
        name: '${originalPlaylist.name} (Copie)',
        songIds: List<String>.from(originalPlaylist.songIds),
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        description: originalPlaylist.description,
      );

      await _databaseService.createPlaylist(newPlaylist);
      _playlists.add(newPlaylist);
      notifyListeners();

      print('📋 Playlist dupliquée');
      return newPlaylist;
    } catch (e) {
      print('❌ Erreur duplication playlist: $e');
      return null;
    }
  }

  /// Obtenir le nombre de chansons dans une playlist
  int getSongCount(String playlistId) {
    try {
      final playlist = _playlists.firstWhere((p) => p.id == playlistId);
      return playlist.songIds.length;
    } catch (e) {
      return 0;
    }
  }

  /// Statistiques
  Map<String, dynamic> getStats() {
    int totalPlaylists = _playlists.length;
    int totalSongs = _playlists.fold(0, (sum, p) => sum + p.songIds.length);
    int avgSongsPerPlaylist = totalPlaylists > 0 ? (totalSongs / totalPlaylists).round() : 0;

    return {
      'totalPlaylists': totalPlaylists,
      'totalSongs': totalSongs,
      'averageSongsPerPlaylist': avgSongsPerPlaylist,
    };
  }
}