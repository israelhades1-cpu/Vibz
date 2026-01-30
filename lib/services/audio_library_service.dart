import 'dart:typed_data';

import 'package:on_audio_query/on_audio_query.dart';
import '../models/song.dart';

class AudioLibraryService {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  
  // Instance singleton
  static final AudioLibraryService _instance = AudioLibraryService._internal();
  factory AudioLibraryService() => _instance;
  AudioLibraryService._internal();

  /// Scanner tous les fichiers audio du device
  Future<List<Song>> scanAudioFiles() async {
    try {
      // Vérifier si on a la permission
      bool hasPermission = await _audioQuery.checkAndRequest();
      
      if (!hasPermission) {
        throw Exception('Permission refusée pour accéder aux fichiers audio');
      }

      // Scanner tous les fichiers audio (MP3, M4A, WAV, FLAC)
      List<SongModel> audioFiles = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      // Filtrer les fichiers valides et convertir vers notre modèle Song
      List<Song> songs = [];
      
      for (SongModel audioFile in audioFiles) {
        // Filtrer les fichiers invalides (durée 0 ou titre vide)
        if (audioFile.duration != null && 
            audioFile.duration! > 0 && 
            audioFile.title.isNotEmpty) {
          
          songs.add(_convertToSong(audioFile));
        }
      }

      return songs;
    } catch (e) {
      print('Erreur lors du scan audio: $e');
      rethrow;
    }
  }

  /// Scanner les albums
  Future<List<Album>> scanAlbums() async {
    try {
      bool hasPermission = await _audioQuery.checkAndRequest();
      
      if (!hasPermission) {
        throw Exception('Permission refusée pour accéder aux fichiers audio');
      }

      List<AlbumModel> albumModels = await _audioQuery.queryAlbums(
        sortType: AlbumSortType.ALBUM,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      List<Album> albums = [];
      
      for (AlbumModel albumModel in albumModels) {
        // Récupérer les chansons de cet album
        List<SongModel> albumSongs = await _audioQuery.queryAudiosFrom(
          AudiosFromType.ALBUM_ID,
          albumModel.id,
        );

        // Convertir les chansons
        List<Song> songs = albumSongs
            .where((s) => s.duration != null && s.duration! > 0)
            .map((s) => _convertToSong(s))
            .toList();

        if (songs.isNotEmpty) {
          albums.add(Album(
            id: albumModel.id.toString(),
            name: albumModel.album,
            artworkUrl: null, // Sera géré par l'artwork query
            songs: songs,
          ));
        }
      }

      return albums;
    } catch (e) {
      print('Erreur lors du scan des albums: $e');
      rethrow;
    }
  }

  /// Récupérer l'artwork d'une chanson
  Future<Uint8List?> getSongArtwork(int songId) async {
    try {
      return await _audioQuery.queryArtwork(
        songId,
        ArtworkType.AUDIO,
        size: 200,
        quality: 100,
      );
    } catch (e) {
      print('Erreur lors de la récupération de l\'artwork: $e');
      return null;
    }
  }

  /// Récupérer l'artwork d'un album
  Future<Uint8List?> getAlbumArtwork(int albumId) async {
    try {
      return await _audioQuery.queryArtwork(
        albumId,
        ArtworkType.ALBUM,
        size: 300,
        quality: 100,
      );
    } catch (e) {
      print('Erreur lors de la récupération de l\'artwork de l\'album: $e');
      return null;
    }
  }

  /// Rechercher des chansons par titre ou artiste
  Future<List<Song>> searchSongs(String query) async {
    try {
      if (query.isEmpty) {
        return await scanAudioFiles();
      }

      List<SongModel> results = await _audioQuery.querySongs(
        sortType: SongSortType.TITLE,
        orderType: OrderType.ASC_OR_SMALLER,
        uriType: UriType.EXTERNAL,
        ignoreCase: true,
      );

      // Filtrer par titre ou artiste
      String searchLower = query.toLowerCase();
      List<Song> filteredSongs = results
          .where((song) =>
              song.title.toLowerCase().contains(searchLower) ||
              (song.artist?.toLowerCase().contains(searchLower) ?? false))
          .where((song) => song.duration != null && song.duration! > 0)
          .map((song) => _convertToSong(song))
          .toList();

      return filteredSongs;
    } catch (e) {
      print('Erreur lors de la recherche: $e');
      return [];
    }
  }

  /// Récupérer les informations d'une chanson par son ID
  Future<Song?> getSongById(String id) async {
    try {
      int songId = int.parse(id);
      List<SongModel> songs = await _audioQuery.querySongs(
        sortType: null,
        orderType: null,
        uriType: UriType.EXTERNAL,
      );

      SongModel? songModel = songs.where((s) => s.id == songId).firstOrNull;
      
      if (songModel != null) {
        return _convertToSong(songModel);
      }
      
      return null;
    } catch (e) {
      print('Erreur lors de la récupération de la chanson: $e');
      return null;
    }
  }

  /// Obtenir le chemin du fichier audio
  Future<String?> getSongPath(int songId) async {
    try {
      List<SongModel> songs = await _audioQuery.querySongs();
      SongModel? song = songs.where((s) => s.id == songId).firstOrNull;
      return song?.data;
    } catch (e) {
      print('Erreur lors de la récupération du chemin: $e');
      return null;
    }
  }

  /// Convertir SongModel (on_audio_query) vers Song (notre modèle)
  Song _convertToSong(SongModel songModel) {
    return Song(
      id: songModel.id.toString(),
      title: songModel.title,
      artist: songModel.artist ?? 'Artiste Inconnu',
      albumArt: null, // L'artwork sera chargé séparément pour économiser la mémoire
      duration: Song.formatDuration(
        (songModel.duration ?? 0) ~/ 1000, // Convertir ms en secondes
      ),
      isFavorite: false, // Sera géré par Hive
    );
  }

  /// Obtenir les statistiques de la bibliothèque
  Future<Map<String, int>> getLibraryStats() async {
    try {
      List<SongModel> songs = await _audioQuery.querySongs();
      List<AlbumModel> albums = await _audioQuery.queryAlbums();
      List<ArtistModel> artists = await _audioQuery.queryArtists();

      return {
        'totalSongs': songs.where((s) => s.duration != null && s.duration! > 0).length,
        'totalAlbums': albums.length,
        'totalArtists': artists.length,
      };
    } catch (e) {
      print('Erreur lors de la récupération des stats: $e');
      return {
        'totalSongs': 0,
        'totalAlbums': 0,
        'totalArtists': 0,
      };
    }
  }

  /// Vérifier si la permission est accordée
  Future<bool> hasPermission() async {
    return await _audioQuery.permissionsStatus();
  }

  /// Demander la permission
  Future<bool> requestPermission() async {
    return await _audioQuery.permissionsRequest();
  }
}