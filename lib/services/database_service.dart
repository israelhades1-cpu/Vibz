import 'package:hive_flutter/hive_flutter.dart';
import '../models/hive/song_adapter.dart';
import '../models/hive/playlist_adapter.dart';
import '../models/hive/history_adapter.dart';
import '../models/song.dart';

class DatabaseService {
  // Noms des boxes Hive
  static const String _favoritesBox = 'favorites';
  static const String _playlistsBox = 'playlists';
  static const String _historyBox = 'history';
  static const String _settingsBox = 'settings';

  // Boxes
  late Box<SongHive> _favorites;
  late Box<PlaylistHive> _playlists;
  late Box<HistoryEntryHive> _history;
  late Box<dynamic> _settings;

  // Singleton
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  // Initialiser Hive
  Future<void> initialize() async {
    try {
      // Initialiser Hive Flutter
      await Hive.initFlutter();

      // Enregistrer les adapters
      if (!Hive.isAdapterRegistered(0)) {
        Hive.registerAdapter(SongHiveAdapter());
      }
      if (!Hive.isAdapterRegistered(1)) {
        Hive.registerAdapter(PlaylistHiveAdapter());
      }
      if (!Hive.isAdapterRegistered(2)) {
        Hive.registerAdapter(HistoryEntryHiveAdapter());
      }

      // Ouvrir les boxes
      _favorites = await Hive.openBox<SongHive>(_favoritesBox);
      _playlists = await Hive.openBox<PlaylistHive>(_playlistsBox);
      _history = await Hive.openBox<HistoryEntryHive>(_historyBox);
      _settings = await Hive.openBox(_settingsBox);

      print('✅ Hive initialisé avec succès');
    } catch (e) {
      print('❌ Erreur lors de l\'initialisation de Hive: $e');
      rethrow;
    }
  }

  // ===== FAVORIS =====

  /// Ajouter aux favoris
  Future<void> addFavorite(Song song) async {
    try {
      final songHive = SongHive.fromSong(song);
      await _favorites.put(song.id, songHive);
      print('⭐ Ajouté aux favoris: ${song.title}');
    } catch (e) {
      print('❌ Erreur ajout favori: $e');
    }
  }

  /// Retirer des favoris
  Future<void> removeFavorite(String songId) async {
    try {
      await _favorites.delete(songId);
      print('🗑️ Retiré des favoris: $songId');
    } catch (e) {
      print('❌ Erreur suppression favori: $e');
    }
  }

  /// Vérifier si une chanson est favorite
  bool isFavorite(String songId) {
    return _favorites.containsKey(songId);
  }

  /// Obtenir tous les favoris
  List<Song> getAllFavorites() {
    try {
      return _favorites.values.map((songHive) => songHive.toSong()).toList();
    } catch (e) {
      print('❌ Erreur récupération favoris: $e');
      return [];
    }
  }

  /// Toggle favori
  Future<bool> toggleFavorite(Song song) async {
    if (isFavorite(song.id)) {
      await removeFavorite(song.id);
      return false;
    } else {
      await addFavorite(song);
      return true;
    }
  }

  // ===== PLAYLISTS =====

  /// Créer une playlist
  Future<void> createPlaylist(Playlist playlist) async {
    try {
      final playlistHive = playlist.toHive();
      await _playlists.put(playlist.id, playlistHive);
      print('📁 Playlist créée: ${playlist.name}');
    } catch (e) {
      print('❌ Erreur création playlist: $e');
    }
  }

  /// Supprimer une playlist
  Future<void> deletePlaylist(String playlistId) async {
    try {
      await _playlists.delete(playlistId);
      print('🗑️ Playlist supprimée: $playlistId');
    } catch (e) {
      print('❌ Erreur suppression playlist: $e');
    }
  }

  /// Mettre à jour une playlist
  Future<void> updatePlaylist(Playlist playlist) async {
    try {
      final playlistHive = playlist.toHive();
      await _playlists.put(playlist.id, playlistHive);
      print('✏️ Playlist mise à jour: ${playlist.name}');
    } catch (e) {
      print('❌ Erreur mise à jour playlist: $e');
    }
  }

  /// Obtenir toutes les playlists
  List<Playlist> getAllPlaylists() {
    try {
      return _playlists.values
          .map((playlistHive) => Playlist.fromHive(playlistHive))
          .toList();
    } catch (e) {
      print('❌ Erreur récupération playlists: $e');
      return [];
    }
  }

  /// Obtenir une playlist par ID
  Playlist? getPlaylist(String playlistId) {
    try {
      final playlistHive = _playlists.get(playlistId);
      if (playlistHive != null) {
        return Playlist.fromHive(playlistHive);
      }
      return null;
    } catch (e) {
      print('❌ Erreur récupération playlist: $e');
      return null;
    }
  }

  /// Ajouter une chanson à une playlist
  Future<void> addSongToPlaylist(String playlistId, String songId) async {
    try {
      final playlist = getPlaylist(playlistId);
      if (playlist != null) {
        final updatedSongIds = List<String>.from(playlist.songIds);
        if (!updatedSongIds.contains(songId)) {
          updatedSongIds.add(songId);
          final updatedPlaylist = playlist.copyWith(
            songIds: updatedSongIds,
            updatedAt: DateTime.now(),
          );
          await updatePlaylist(updatedPlaylist);
          print('➕ Chanson ajoutée à la playlist');
        }
      }
    } catch (e) {
      print('❌ Erreur ajout chanson à playlist: $e');
    }
  }

  /// Retirer une chanson d'une playlist
  Future<void> removeSongFromPlaylist(String playlistId, String songId) async {
    try {
      final playlist = getPlaylist(playlistId);
      if (playlist != null) {
        final updatedSongIds = List<String>.from(playlist.songIds);
        updatedSongIds.remove(songId);
        final updatedPlaylist = playlist.copyWith(
          songIds: updatedSongIds,
          updatedAt: DateTime.now(),
        );
        await updatePlaylist(updatedPlaylist);
        print('➖ Chanson retirée de la playlist');
      }
    } catch (e) {
      print('❌ Erreur retrait chanson de playlist: $e');
    }
  }

  // ===== HISTORIQUE =====

  /// Ajouter une entrée à l'historique
  Future<void> addToHistory(String songId, {int? duration}) async {
    try {
      final entry = HistoryEntry(
        songId: songId,
        playedAt: DateTime.now(),
        duration: duration,
      );
      final entryHive = entry.toHive();
      
      // Utiliser un timestamp comme clé pour éviter les doublons
      final key = DateTime.now().millisecondsSinceEpoch.toString();
      await _history.put(key, entryHive);

      // Limiter l'historique à 50 entrées (selon le cahier des charges)
      if (_history.length > 50) {
        final oldestKey = _history.keys.first;
        await _history.delete(oldestKey);
      }

      print('📝 Ajouté à l\'historique: $songId');
    } catch (e) {
      print('❌ Erreur ajout historique: $e');
    }
  }

  /// Obtenir l'historique
  List<HistoryEntry> getHistory({int limit = 50}) {
    try {
      final entries = _history.values
          .map((entryHive) => HistoryEntry.fromHive(entryHive))
          .toList();

      // Trier par date décroissante (plus récent en premier)
      entries.sort((a, b) => b.playedAt.compareTo(a.playedAt));

      // Limiter le nombre d'entrées
      return entries.take(limit).toList();
    } catch (e) {
      print('❌ Erreur récupération historique: $e');
      return [];
    }
  }

  /// Effacer l'historique
  Future<void> clearHistory() async {
    try {
      await _history.clear();
      print('🗑️ Historique effacé');
    } catch (e) {
      print('❌ Erreur effacement historique: $e');
    }
  }

  // ===== PARAMÈTRES =====

  /// Sauvegarder un paramètre
  Future<void> saveSetting(String key, dynamic value) async {
    try {
      await _settings.put(key, value);
      print('⚙️ Paramètre sauvegardé: $key');
    } catch (e) {
      print('❌ Erreur sauvegarde paramètre: $e');
    }
  }

  /// Obtenir un paramètre
  T? getSetting<T>(String key, {T? defaultValue}) {
    try {
      return _settings.get(key, defaultValue: defaultValue) as T?;
    } catch (e) {
      print('❌ Erreur récupération paramètre: $e');
      return defaultValue;
    }
  }

  // ===== UTILITAIRES =====

  /// Obtenir les statistiques
  Map<String, int> getStats() {
    return {
      'favorites': _favorites.length,
      'playlists': _playlists.length,
      'history': _history.length,
    };
  }

  /// Fermer toutes les boxes (à appeler à la fermeture de l'app)
  Future<void> close() async {
    try {
      await _favorites.close();
      await _playlists.close();
      await _history.close();
      await _settings.close();
      print('✅ Boxes Hive fermées');
    } catch (e) {
      print('❌ Erreur fermeture boxes: $e');
    }
  }

  /// Reset complet (pour debug)
  Future<void> resetAll() async {
    try {
      await _favorites.clear();
      await _playlists.clear();
      await _history.clear();
      await _settings.clear();
      print('🗑️ Toutes les données effacées');
    } catch (e) {
      print('❌ Erreur reset: $e');
    }
  }
}