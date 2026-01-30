import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../services/audio_library_service.dart';
import '../services/database_service.dart';

class LibraryProvider extends ChangeNotifier {
  final AudioLibraryService _libraryService = AudioLibraryService();
  final DatabaseService _databaseService = DatabaseService();

  // État
  List<Song> _allSongs = [];
  List<Album> _albums = [];
  List<Song> _favoriteSongs = [];
  bool _isLoading = false;
  String? _errorMessage;
  Map<String, int> _libraryStats = {};

  // Getters
  List<Song> get allSongs => _allSongs;
  List<Album> get albums => _albums;
  List<Song> get favoriteSongs => _favoriteSongs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Map<String, int> get libraryStats => _libraryStats;

  /// Initialiser la bibliothèque
  Future<void> initialize() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Scanner les fichiers audio
      _allSongs = await _libraryService.scanAudioFiles();

      // Charger les favoris depuis Hive
      await _loadFavorites();

      // Récupérer les statistiques
      _libraryStats = await _libraryService.getLibraryStats();

      _isLoading = false;
      notifyListeners();

      print('✅ Bibliothèque initialisée: ${_allSongs.length} chansons');
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      print('❌ Erreur initialisation bibliothèque: $e');
    }
  }

  /// Charger les albums
  Future<void> loadAlbums() async {
    try {
      _albums = await _libraryService.scanAlbums();
      notifyListeners();
      print('📁 ${_albums.length} albums chargés');
    } catch (e) {
      print('❌ Erreur chargement albums: $e');
    }
  }

  /// Rafraîchir la bibliothèque
  Future<void> refresh() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      _allSongs = await _libraryService.scanAudioFiles();
      await _loadFavorites();
      _libraryStats = await _libraryService.getLibraryStats();

      _isLoading = false;
      notifyListeners();

      print('🔄 Bibliothèque rafraîchie');
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      print('❌ Erreur rafraîchissement: $e');
    }
  }

  /// Charger les favoris depuis Hive
  Future<void> _loadFavorites() async {
    try {
      final favorites = _databaseService.getAllFavorites();
      
      // Mettre à jour le statut favori des chansons
      for (var song in _allSongs) {
        song.isFavorite = _databaseService.isFavorite(song.id);
      }

      _favoriteSongs = _allSongs.where((song) => song.isFavorite).toList();
      
      print('⭐ ${_favoriteSongs.length} favoris chargés');
    } catch (e) {
      print('❌ Erreur chargement favoris: $e');
    }
  }

  /// Toggle favori
  Future<void> toggleFavorite(Song song) async {
    try {
      final isFavorite = await _databaseService.toggleFavorite(song);
      song.isFavorite = isFavorite;

      // Mettre à jour la liste des favoris
      if (isFavorite) {
        if (!_favoriteSongs.contains(song)) {
          _favoriteSongs.add(song);
        }
      } else {
        _favoriteSongs.remove(song);
      }

      notifyListeners();
      print(isFavorite ? '⭐ Ajouté aux favoris' : '🗑️ Retiré des favoris');
    } catch (e) {
      print('❌ Erreur toggle favori: $e');
    }
  }

  /// Rechercher des chansons
  List<Song> searchSongs(String query) {
    if (query.isEmpty) {
      return _allSongs;
    }

    final queryLower = query.toLowerCase();
    return _allSongs.where((song) {
      return song.title.toLowerCase().contains(queryLower) ||
             song.artist.toLowerCase().contains(queryLower) ||
             (song.albumName?.toLowerCase().contains(queryLower) ?? false);
    }).toList();
  }

  /// Obtenir une chanson par ID
  Song? getSongById(String id) {
    try {
      return _allSongs.firstWhere((song) => song.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Obtenir les chansons d'un album
  List<Song> getSongsByAlbum(String albumId) {
    return _allSongs
        .where((song) => song.albumId?.toString() == albumId)
        .toList();
  }

  /// Obtenir les chansons d'un artiste
  List<Song> getSongsByArtist(String artist) {
    return _allSongs
        .where((song) => song.artist.toLowerCase() == artist.toLowerCase())
        .toList();
  }

  /// Statistiques avancées
  Map<String, dynamic> getAdvancedStats() {
    return {
      'totalSongs': _allSongs.length,
      'totalAlbums': _albums.length,
      'totalFavorites': _favoriteSongs.length,
      'totalArtists': _allSongs.map((s) => s.artist).toSet().length,
    };
  }

  /// Obtenir les artistes uniques
  List<String> getUniqueArtists() {
    return _allSongs.map((song) => song.artist).toSet().toList()..sort();
  }

  /// Obtenir les albums uniques
  List<String> getUniqueAlbums() {
    return _allSongs
        .where((song) => song.albumName != null)
        .map((song) => song.albumName!)
        .toSet()
        .toList()
      ..sort();
  }
}