import 'package:flutter/material.dart';
import '../models/song.dart';
import '../widgets/album_card.dart';
import '../widgets/song_list_tile.dart';
import '../widgets/mini_player.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTabIndex = 0;
  bool _isPlaying = false;

  // Mock data - replace with real data from your providers
  final List<Album> _recentAlbums = [
    Album(
      id: '1',
      name: 'Album 1',
      artworkUrl: null, // Add your asset path
      songs: [],
    ),
    Album(
      id: '2',
      name: 'Album 2',
      artworkUrl: null,
      songs: [],
    ),
    Album(
      id: '3',
      name: 'Album 3',
      artworkUrl: null,
      songs: [],
    ),
  ];

  final List<Song> _allSongs = [
    Song(
      id: '1',
      title: 'Song Title One',
      artist: 'Artist A',
      duration: '1:21',
      albumArt: null,
    ),
    Song(
      id: '2',
      title: 'Longer Song Title Two',
      artist: 'Artist B',
      duration: '2:10',
      albumArt: null,
    ),
  ];

  Song? _currentSong;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    // Set first song as current
    if (_allSongs.isNotEmpty) {
      _currentSong = _allSongs[0];
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: SafeArea(
        child: Column(
          children: [
            // Header with logo and title
            _buildHeader(),
            
            // Tabs
            _buildTabs(),
            
            // Content
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildRecentsTab(),
                  _buildPlaylistsTab(),
                  _buildFavoritesTab(),
                  _buildHistoryTab(),
                ],
              ),
            ),
            
            // Mini Player
            MiniPlayer(
              currentSong: _currentSong,
              isPlaying: _isPlaying,
              onPlayPause: () {
                setState(() {
                  _isPlaying = !_isPlaying;
                });
              },
              onTap: () {
                // TODO: Navigate to full player screen
                print('Open full player');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          // Logo
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  const Color(0xFF00D9FF),
                  const Color(0xFF7B2FFF),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Container(
                width: 52,
                height: 52,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Color(0xFF2A2A2A),
                ),
                child: const Center(
                  child: Text(
                    'Vibz',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Title
          const Text(
            'Vibz',
            style: TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        indicator: const UnderlineTabIndicator(
          borderSide: BorderSide(
            color: Color(0xFF00D9FF),
            width: 3,
          ),
          insets: EdgeInsets.symmetric(horizontal: 16),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelColor: Colors.white,
        unselectedLabelColor: const Color(0xFFB3B3B3),
        labelStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        tabs: const [
          Tab(text: 'Récents'),
          Tab(text: 'Playlists'),
          Tab(text: 'Favoris'),
          Tab(text: 'Historique'),
        ],
      ),
    );
  }

  Widget _buildRecentsTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          
          // Recently played albums section
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Écoutés Réciement',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Show all recent albums
                  },
                  child: const Text(
                    'Voir tout',
                    style: TextStyle(
                      color: Color(0xFF00D9FF),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          
          // Albums carousel
          SizedBox(
            height: 190,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              scrollDirection: Axis.horizontal,
              itemCount: _recentAlbums.length,
              itemBuilder: (context, index) {
                return AlbumCard(
                  album: _recentAlbums[index],
                  onTap: () {
                    // TODO: Navigate to album details
                    print('Tapped album: ${_recentAlbums[index].name}');
                  },
                );
              },
            ),
          ),
          
          // Carousel indicators
          const SizedBox(height: 16),
          Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(
                _recentAlbums.length,
                (index) => Container(
                  width: 6,
                  height: 6,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: index == 0
                        ? const Color(0xFF00D9FF)
                        : const Color(0xFF4A4A4A),
                  ),
                ),
              ),
            ),
          ),
          
          const SizedBox(height: 32),
          
          // All songs section
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Touttes les Musiques',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          
          // Songs list
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _allSongs.length,
            itemBuilder: (context, index) {
              return SongListTile(
                song: _allSongs[index],
                onTap: () {
                  setState(() {
                    _currentSong = _allSongs[index];
                    _isPlaying = true;
                  });
                },
                onFavoriteToggle: () {
                  // TODO: Save to favorites
                  print('Favorite toggled: ${_allSongs[index].title}');
                },
              );
            },
          ),
          
          const SizedBox(height: 80), // Space for mini player
        ],
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    return const Center(
      child: Text(
        'Playlists\n(À implémenter)',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return const Center(
      child: Text(
        'Favoris\n(À implémenter)',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }

  Widget _buildHistoryTab() {
    return const Center(
      child: Text(
        'Historique\n(À implémenter)',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
        ),
      ),
    );
  }
}