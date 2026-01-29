import 'package:flutter/material.dart';
import '../models/song.dart';

class MiniPlayer extends StatefulWidget {
  final Song? currentSong;
  final bool isPlaying;
  final VoidCallback? onPlayPause;
  final VoidCallback? onTap;

  const MiniPlayer({
    Key? key,
    this.currentSong,
    this.isPlaying = false,
    this.onPlayPause,
    this.onTap,
  }) : super(key: key);

  @override
  State<MiniPlayer> createState() => _MiniPlayerState();
}

class _MiniPlayerState extends State<MiniPlayer> {
  @override
  Widget build(BuildContext context) {
    if (widget.currentSong == null) {
      return const SizedBox.shrink();
    }

    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        height: 72,
        decoration: BoxDecoration(
          color: const Color(0xFF2A2A2A),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Progress indicator (thin line at top)
            Container(
              height: 2,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF00D9FF),
                    const Color(0xFF00D9FF).withOpacity(0.3),
                  ],
                  stops: const [0.3, 0.3], // 30% progress example
                ),
              ),
            ),
            // Main player content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    // Album art
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: const Color(0xFF1F1F1F),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: widget.currentSong!.albumArt != null
                            ? Image.asset(
                                widget.currentSong!.albumArt!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return _buildPlaceholder();
                                },
                              )
                            : _buildPlaceholder(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Song info
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.currentSong!.title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            widget.currentSong!.artist,
                            style: const TextStyle(
                              color: Color(0xFFB3B3B3),
                              fontSize: 12,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Play/Pause button
                    IconButton(
                      icon: Icon(
                        widget.isPlaying ? Icons.pause : Icons.play_arrow,
                        color: const Color(0xFF00D9FF),
                        size: 32,
                      ),
                      onPressed: widget.onPlayPause,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF1F1F1F),
      child: const Center(
        child: Icon(
          Icons.music_note,
          color: Color(0xFF00D9FF),
          size: 20,
        ),
      ),
    );
  }
}