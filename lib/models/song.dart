class Song {
  final String id;
  final String title;
  final String artist;
  final String? albumArt;
  final String duration;
  bool isFavorite;

  Song({
    required this.id,
    required this.title,
    required this.artist,
    this.albumArt,
    required this.duration,
    this.isFavorite = false,
  });

  // Format duration from seconds to mm:ss
  static String formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '$minutes:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}

class Album {
  final String id;
  final String name;
  final String? artworkUrl;
  final List<Song> songs;

  Album({
    required this.id,
    required this.name,
    this.artworkUrl,
    required this.songs,
  });
}