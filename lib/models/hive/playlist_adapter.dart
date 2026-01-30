import 'package:hive/hive.dart';

part 'playlist_adapter.g.dart';

@HiveType(typeId: 1)
class PlaylistHive extends HiveObject {
  @HiveField(0)
  late String id;

  @HiveField(1)
  late String name;

  @HiveField(2)
  late List<String> songIds; // Liste des IDs de chansons

  @HiveField(3)
  late DateTime createdAt;

  @HiveField(4)
  late DateTime updatedAt;

  @HiveField(5)
  String? description;

  PlaylistHive({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });
}

// Modèle Playlist pour l'app
class Playlist {
  final String id;
  final String name;
  final List<String> songIds;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? description;

  Playlist({
    required this.id,
    required this.name,
    required this.songIds,
    required this.createdAt,
    required this.updatedAt,
    this.description,
  });

  // Convertir vers PlaylistHive
  PlaylistHive toHive() {
    return PlaylistHive(
      id: id,
      name: name,
      songIds: songIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
      description: description,
    );
  }

  // Créer depuis PlaylistHive
  factory Playlist.fromHive(PlaylistHive hive) {
    return Playlist(
      id: hive.id,
      name: hive.name,
      songIds: hive.songIds,
      createdAt: hive.createdAt,
      updatedAt: hive.updatedAt,
      description: hive.description,
    );
  }

  // Copie avec modifications
  Playlist copyWith({
    String? id,
    String? name,
    List<String>? songIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? description,
  }) {
    return Playlist(
      id: id ?? this.id,
      name: name ?? this.name,
      songIds: songIds ?? this.songIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      description: description ?? this.description,
    );
  }
}