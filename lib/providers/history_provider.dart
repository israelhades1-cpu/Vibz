import 'package:flutter/foundation.dart';
import '../models/hive/history_adapter.dart';
import '../services/database_service.dart';

class HistoryProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  List<HistoryEntry> _history = [];
  bool _isLoading = false;

  // Getters
  List<HistoryEntry> get history => _history;
  bool get isLoading => _isLoading;

  /// Initialiser - Charger l'historique depuis Hive
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      _history = _databaseService.getHistory();

      _isLoading = false;
      notifyListeners();

      print('✅ ${_history.length} entrées d\'historique chargées');
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('❌ Erreur chargement historique: $e');
    }
  }

  /// Ajouter une chanson à l'historique
  Future<void> addToHistory(String songId, {int? duration}) async {
    try {
      await _databaseService.addToHistory(songId, duration: duration);
      
      // Recharger l'historique
      _history = _databaseService.getHistory();
      notifyListeners();

      print('📝 Ajouté à l\'historique: $songId');
    } catch (e) {
      print('❌ Erreur ajout historique: $e');
    }
  }

  /// Effacer tout l'historique
  Future<void> clearHistory() async {
    try {
      await _databaseService.clearHistory();
      _history.clear();
      notifyListeners();

      print('🗑️ Historique effacé');
    } catch (e) {
      print('❌ Erreur effacement historique: $e');
    }
  }

  /// Obtenir les chansons les plus écoutées
  List<String> getMostPlayedSongIds({int limit = 10}) {
    final songPlayCounts = <String, int>{};

    for (var entry in _history) {
      songPlayCounts[entry.songId] = (songPlayCounts[entry.songId] ?? 0) + 1;
    }

    final sortedEntries = songPlayCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedEntries.take(limit).map((e) => e.key).toList();
  }

  /// Obtenir le nombre d'écoutes d'une chanson
  int getPlayCount(String songId) {
    return _history.where((entry) => entry.songId == songId).length;
  }

  /// Obtenir l'historique des X derniers jours
  List<HistoryEntry> getRecentHistory({int days = 7}) {
    final cutoffDate = DateTime.now().subtract(Duration(days: days));
    return _history.where((entry) => entry.playedAt.isAfter(cutoffDate)).toList();
  }

  /// Statistiques d'écoute
  Map<String, dynamic> getStats() {
    if (_history.isEmpty) {
      return {
        'totalPlays': 0,
        'uniqueSongs': 0,
        'averagePlaysPerDay': 0.0,
        'lastPlayedAt': null,
      };
    }

    final uniqueSongs = _history.map((e) => e.songId).toSet().length;
    final oldestEntry = _history.last;
    final daysSinceOldest = DateTime.now().difference(oldestEntry.playedAt).inDays;
    final avgPlaysPerDay = daysSinceOldest > 0 
        ? _history.length / daysSinceOldest 
        : _history.length.toDouble();

    return {
      'totalPlays': _history.length,
      'uniqueSongs': uniqueSongs,
      'averagePlaysPerDay': avgPlaysPerDay.toStringAsFixed(1),
      'lastPlayedAt': _history.first.playedAt,
    };
  }

  /// Obtenir l'historique groupé par jour
  Map<DateTime, List<HistoryEntry>> getHistoryByDay() {
    final Map<DateTime, List<HistoryEntry>> grouped = {};

    for (var entry in _history) {
      final date = DateTime(
        entry.playedAt.year,
        entry.playedAt.month,
        entry.playedAt.day,
      );

      if (!grouped.containsKey(date)) {
        grouped[date] = [];
      }
      grouped[date]!.add(entry);
    }

    return grouped;
  }
}