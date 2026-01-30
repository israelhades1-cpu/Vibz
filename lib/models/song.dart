import 'dart:typed_data';

class Song {
  final String id;
  final String title;
  final String artist;
  final String? albumArt;
  final String duration;
  bool isFavorite;
  
  // Propriétés additionnelles pour le lecteur audio
  final String? albumName;
  final String? filePath;
  final int? albumId;
  Uint8List? artworkBytes; // Pour stocker l'artwork en mémoire

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.albumArt,
    required this.duration,
    this.isFavorite = false,
    this.albumName,
    this.filePath,
    this.albumId,
    this.artworkBytes,
  });

  // Format duration from seconds to mm:ss
  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  // Convertir en Map pour Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'artist': artist,
      'albumArt': albumArt,
      'duration': duration,
      'isFavorite': isFavorite,
      'albumName': albumName,
      'filePath': filePath,
      'albumId': albumId,
    };
  }

  // Créer depuis Map
  factory Song.fromMap(Map<String, dynamic> map) {
    return Song(
      id: map['id'] as String,
      title: map['title'] as String,
      artist: map['artist'] as String,
      albumArt: map['albumArt'] as String?,
      duration: map['duration'] as String,
      isFavorite: map['isFavorite'] as bool? ?? false,
      albumName: map['albumName'] as String?,
      filePath: map['filePath'] as String?,
      albumId: map['albumId'] as int?,
    );
  }

  // Créer une copie avec modifications
  Song copyWith({
    String? id,
    String? title,
    String? artist,
    String? albumArt,
    String? duration,
    bool? isFavorite,
    String? albumName,
    String? filePath,
    int? albumId,
    Uint8List? artworkBytes,
  }) {
    return Song(
      id: id ?? this.id,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumArt: albumArt ?? this.albumArt,
      duration: duration ?? this.duration,
      isFavorite: isFavorite ?? this.isFavorite,
      albumName: albumName ?? this.albumName,
      filePath: filePath ?? this.filePath,
      albumId: albumId ?? this.albumId,
      artworkBytes: artworkBytes ?? this.artworkBytes,
    );
  }
}

class Album {
  final String id;
  final String name;
  final String? artworkUrl;
  final List<Song> songs;
  Uint8List? artworkBytes; // Pour stocker l'artwork en mémoire

  Album({
    required this.id,
    required this.name,
    this.artworkUrl,
    required this.songs,
    this.artworkBytes,
  });

  // Nombre de chansons dans l'album
  int get songCount => songs.length;

  // Durée totale de l'album en secondes
  int get totalDuration {
    return songs.fold(0, (sum, song) {
      // Convertir mm:ss en secondes
      List<String> parts = song.duration.split(':');
      if (parts.length == 2) {
        int minutes = int.tryParse(parts[0]) ?? 0;
        int seconds = int.tryParse(parts[1]) ?? 0;
        return sum + (minutes * 60) + seconds;
      }
      return sum;
    });
  }

  // Durée totale formatée
  String get formattedDuration {
    return Song.formatDuration(totalDuration);
  }

  // Convertir en Map pour Hive
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'artworkUrl': artworkUrl,
      'songs': songs.map((s) => s.toMap()).toList(),
    };
  }

  // Créer depuis Map
  factory Album.fromMap(Map<String, dynamic> map) {
    return Album(
      id: map['id'] as String,
      name: map['name'] as String,
      artworkUrl: map['artworkUrl'] as String?,
      songs: (map['songs'] as List<dynamic>)
          .map((s) => Song.fromMap(s as Map<String, dynamic>))
          .toList(),
    );
  }
}