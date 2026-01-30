import 'package:hive/hive.dart';


@HiveType(typeId: 2)
class HistoryEntryHive extends HiveObject {
  @HiveField(0)
  late String songId;

  @HiveField(1)
  late DateTime playedAt;

  @HiveField(2)
  int? duration; // Durée d'écoute en secondes (optionnel)

  HistoryEntryHive({
    required this.songId,
    required this.playedAt,
    this.duration,
  });
}

// Modèle HistoryEntry pour l'app
class HistoryEntry {
  final String songId;
  final DateTime playedAt;
  final int? duration;

  HistoryEntry({
    required this.songId,
    required this.playedAt,
    this.duration,
  });

  // Convertir vers HistoryEntryHive
  HistoryEntryHive toHive() {
    return HistoryEntryHive(
      songId: songId,
      playedAt: playedAt,
      duration: duration,
    );
  }

  // Créer depuis HistoryEntryHive
  factory HistoryEntry.fromHive(HistoryEntryHive hive) {
    return HistoryEntry(
      songId: hive.songId,
      playedAt: hive.playedAt,
      duration: hive.duration,
    );
  }
}