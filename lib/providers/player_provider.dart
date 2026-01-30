import 'package:flutter/foundation.dart';
import '../models/song.dart';
import '../services/database_service.dart';

enum PlayerState {
  stopped,
  playing,
  paused,
  loading,
}

enum RepeatMode {
  off,    // Pas de répétition
  one,    // Répéter une chanson
  all,    // Répéter toute la file d'attente
}

class PlayerProvider extends ChangeNotifier {
  final DatabaseService _databaseService = DatabaseService();

  // État du lecteur
  Song? _currentSong;
  List<Song> _queue = [];
  int _currentIndex = 0;
  PlayerState _playerState = PlayerState.stopped;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  bool _isShuffleOn = false;
  RepeatMode _repeatMode = RepeatMode.off;

  // Getters
  Song? get currentSong => _currentSong;
  List<Song> get queue => _queue;
  int get currentIndex => _currentIndex;
  PlayerState get playerState => _playerState;
  Duration get position => _position;
  Duration get duration => _duration;
  bool get isShuffleOn => _isShuffleOn;
  RepeatMode get repeatMode => _repeatMode;
  
  bool get isPlaying => _playerState == PlayerState.playing;
  bool get isPaused => _playerState == PlayerState.paused;
  bool get isLoading => _playerState == PlayerState.loading;
  
  double get progress {
    if (_duration.inMilliseconds == 0) return 0.0;
    return _position.inMilliseconds / _duration.inMilliseconds;
  }

  // ===== PLAYBACK CONTROLS =====

  /// Jouer une chanson
  Future<void> playSong(Song song, {List<Song>? queue}) async {
    try {
      _currentSong = song;
      
      // Définir la file d'attente
      if (queue != null && queue.isNotEmpty) {
        _queue = queue;
        _currentIndex = queue.indexOf(song);
        if (_currentIndex == -1) {
          _queue.insert(0, song);
          _currentIndex = 0;
        }
      } else {
        _queue = [song];
        _currentIndex = 0;
      }

      _playerState = PlayerState.playing;
      notifyListeners();

      // TODO: Phase 2 - Implémenter just_audio ici
      print('▶️ Lecture: ${song.title}');

      // Ajouter à l'historique après 30 secondes (simulé pour l'instant)
      // TODO: Phase 2 - Implémenter la vraie logique avec just_audio
      Future.delayed(const Duration(seconds: 30), () {
        _addToHistory(song.id);
      });

    } catch (e) {
      print('❌ Erreur lecture: $e');
      _playerState = PlayerState.stopped;
      notifyListeners();
    }
  }

  /// Pause
  void pause() {
    if (_playerState == PlayerState.playing) {
      _playerState = PlayerState.paused;
      notifyListeners();
      print('⏸️ Pause');
      
      // TODO: Phase 2 - Appeler just_audio.pause()
    }
  }

  /// Resume
  void resume() {
    if (_playerState == PlayerState.paused && _currentSong != null) {
      _playerState = PlayerState.playing;
      notifyListeners();
      print('▶️ Resume');
      
      // TODO: Phase 2 - Appeler just_audio.play()
    }
  }

  /// Stop
  void stop() {
    _playerState = PlayerState.stopped;
    _position = Duration.zero;
    notifyListeners();
    print('⏹️ Stop');
    
    // TODO: Phase 2 - Appeler just_audio.stop()
  }

  /// Toggle play/pause
  void togglePlayPause() {
    if (_playerState == PlayerState.playing) {
      pause();
    } else if (_playerState == PlayerState.paused) {
      resume();
    } else if (_currentSong != null) {
      resume();
    }
  }

  /// Chanson suivante
  Future<void> next() async {
    if (_queue.isEmpty) return;

    if (_repeatMode == RepeatMode.one) {
      // Rejouer la même chanson
      await playSong(_currentSong!, queue: _queue);
      return;
    }

    int nextIndex = _currentIndex + 1;
    
    if (nextIndex >= _queue.length) {
      if (_repeatMode == RepeatMode.all) {
        nextIndex = 0; // Retour au début
      } else {
        stop();
        return;
      }
    }

    _currentIndex = nextIndex;
    await playSong(_queue[_currentIndex], queue: _queue);
  }

  /// Chanson précédente
  Future<void> previous() async {
    if (_queue.isEmpty) return;

    // Si on est à plus de 3 secondes, recommencer la chanson
    if (_position.inSeconds > 3) {
      seek(Duration.zero);
      return;
    }

    int prevIndex = _currentIndex - 1;
    
    if (prevIndex < 0) {
      if (_repeatMode == RepeatMode.all) {
        prevIndex = _queue.length - 1; // Aller à la fin
      } else {
        prevIndex = 0; // Rester à la première
      }
    }

    _currentIndex = prevIndex;
    await playSong(_queue[_currentIndex], queue: _queue);
  }

  /// Seek (avancer/reculer dans la chanson)
  void seek(Duration position) {
    _position = position;
    notifyListeners();
    
    // TODO: Phase 2 - Appeler just_audio.seek(position)
    print('⏩ Seek: ${position.inSeconds}s');
  }

  // ===== MODES DE LECTURE =====

  /// Toggle shuffle
  void toggleShuffle() {
    _isShuffleOn = !_isShuffleOn;
    
    if (_isShuffleOn) {
      // Mélanger la file d'attente (sauf la chanson courante)
      final currentSong = _queue[_currentIndex];
      final remainingSongs = List<Song>.from(_queue);
      remainingSongs.removeAt(_currentIndex);
      remainingSongs.shuffle();
      
      _queue = [currentSong, ...remainingSongs];
      _currentIndex = 0;
      
      print('🔀 Shuffle activé');
    } else {
      print('🔀 Shuffle désactivé');
    }
    
    notifyListeners();
  }

  /// Changer le mode repeat
  void toggleRepeatMode() {
    switch (_repeatMode) {
      case RepeatMode.off:
        _repeatMode = RepeatMode.all;
        print('🔁 Repeat All');
        break;
      case RepeatMode.all:
        _repeatMode = RepeatMode.one;
        print('🔂 Repeat One');
        break;
      case RepeatMode.one:
        _repeatMode = RepeatMode.off;
        print('➡️ Repeat Off');
        break;
    }
    notifyListeners();
  }

  // ===== QUEUE MANAGEMENT =====

  /// Ajouter à la file d'attente
  void addToQueue(Song song) {
    _queue.add(song);
    notifyListeners();
    print('➕ Ajouté à la file: ${song.title}');
  }

  /// Jouer ensuite (insérer après la chanson courante)
  void playNext(Song song) {
    _queue.insert(_currentIndex + 1, song);
    notifyListeners();
    print('⏭️ Jouer ensuite: ${song.title}');
  }

  /// Vider la file d'attente
  void clearQueue() {
    _queue.clear();
    _currentIndex = 0;
    notifyListeners();
    print('🗑️ File d\'attente vidée');
  }

  /// Retirer une chanson de la file
  void removeFromQueue(int index) {
    if (index < _queue.length) {
      final song = _queue.removeAt(index);
      
      // Ajuster l'index courant si nécessaire
      if (index < _currentIndex) {
        _currentIndex--;
      } else if (index == _currentIndex) {
        // Si on retire la chanson courante, passer à la suivante
        if (_queue.isNotEmpty) {
          next();
        } else {
          stop();
        }
      }
      
      notifyListeners();
      print('➖ Retiré de la file: ${song.title}');
    }
  }

  // ===== HISTORIQUE =====

  /// Ajouter à l'historique
  Future<void> _addToHistory(String songId) async {
    try {
      await _databaseService.addToHistory(songId);
      print('📝 Ajouté à l\'historique');
    } catch (e) {
      print('❌ Erreur ajout historique: $e');
    }
  }

  // ===== SIMULATION (pour Phase 1) =====

  /// Simuler la progression de la lecture (pour tester l'UI)
  void simulatePlayback(Duration songDuration) {
    _duration = songDuration;
    _position = Duration.zero;
    notifyListeners();

    // Simuler la progression
    // TODO: Phase 2 - Remplacer par les streams de just_audio
    Future.doWhile(() async {
      if (_playerState != PlayerState.playing) return false;
      
      await Future.delayed(const Duration(seconds: 1));
      
      if (_position.inSeconds < _duration.inSeconds) {
        _position = Duration(seconds: _position.inSeconds + 1);
        notifyListeners();
        return true;
      } else {
        // Fin de la chanson
        await next();
        return false;
      }
    });
  }

  /// Update position (appelé par le simulateur ou just_audio)
  void updatePosition(Duration position) {
    _position = position;
    notifyListeners();
  }

  /// Update duration
  void updateDuration(Duration duration) {
    _duration = duration;
    notifyListeners();
  }
}