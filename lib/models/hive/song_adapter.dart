import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../song.dart';

part 'song_adapter.g.dart';
@HiveType(typeId: 0)
class SongHive extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String title;

  @HiveField(2)
  late String artist;

  @HiveField(3)
  String? albumArt;

  @HiveField(4)
  late String duration;

  @HiveField(5)
  late bool isFavorite;

  @HiveField(6)
  String? albumName;

  @HiveField(7)
  String? filePath;

  @HiveField(8)
  int? albumId;

  @HiveField(9)
  DateTime? lastPlayed;

  @HiveField(10)
  int playCount;

  SongHive({
    required this.id,
    required this.title,
    required this.artist,
    this.albumArt,
    required this.duration,
    this.isFavorite = false,
    this.albumName,
    this.filePath,
    this.albumId,
    this.lastPlayed,
    this.playCount = 0,
  });

  // Convertir Song vers SongHive
  factory SongHive.fromSong(Song song) {
    return SongHive(
      id: song.id,
      title: song.title,
      artist: song.artist,
      albumArt: song.albumArt,
      duration: song.duration,
      isFavorite: song.isFavorite,
      albumName: song.albumName,
      filePath: song.filePath,
      albumId: song.albumId,
    );
  }

  // Convertir SongHive vers Song
  Song toSong() {
    return Song(
      id: id,
      title: title,
      artist: artist,
      albumArt: albumArt,
      duration: duration,
      isFavorite: isFavorite,
      albumName: albumName,
      filePath: filePath,
      albumId: albumId,
    );
  }
}
