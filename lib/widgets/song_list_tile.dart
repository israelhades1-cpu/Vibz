import 'package:flutter/material.dart';
import '../models/song.dart';

class SongListTile extends StatefulWidget {
  final Song song;
  final VoidCallback? onTap;
  final VoidCallback? onFavoriteToggle;

  const SongListTile({
    Key? key,
    required this.song,
    this.onTap,
    this.onFavoriteToggle,
  }) : super(key: key);

  @override
  State<SongListTile> createState() => _SongListTileState();
}

class _SongListTileState extends State<SongListTile> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      onTap: widget.onTap,
      leading: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: const Color(0xFF2A2A2A),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: widget.song.albumArt != null
              ? Image.asset(
                  widget.song.albumArt!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _buildPlaceholder();
                  },
                )
              : _buildPlaceholder(),
        ),
      ),
      title: Text(
        widget.song.title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        widget.song.artist,
        style: const TextStyle(
          color: Color(0xFFB3B3B3),
          fontSize: 14,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Duration
          Text(
            widget.song.duration,
            style: const TextStyle(
              color: Color(0xFFB3B3B3),
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 16),
          // Favorite button
          IconButton(
            icon: Icon(
              widget.song.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: widget.song.isFavorite
                  ? const Color(0xFF00D9FF)
                  : const Color(0xFFB3B3B3),
            ),
            onPressed: () {
              setState(() {
                widget.song.isFavorite = !widget.song.isFavorite;
              });
              widget.onFavoriteToggle?.call();
            },
          ),
          // More options
          IconButton(
            icon: const Icon(
              Icons.more_vert,
              color: Color(0xFFB3B3B3),
            ),
            onPressed: () {
              // TODO: Show options menu
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: const Center(
        child: Icon(
          Icons.music_note,
          color: Color(0xFF00D9FF),
          size: 24,
        ),
      ),
    );
  }
}