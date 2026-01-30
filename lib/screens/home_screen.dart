import 'package:flutter/material.dart';
import '../models/song.dart';
import '../services/audio_library_service.dart';
import '../widgets/album_card.dart';
import '../widgets/song_list_tile.dart';
import '../widgets/mini_player.dart';

class HomeScreen extends StatefulWidget {
  final List<Song> initialSongs;
  final Map<String, int> libraryStats;

  const HomeScreen({
    Key? key,
    required this.initialSongs,
    required this.libraryStats,
  }) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final AudioLibraryService _libraryService = AudioLibraryService();
  
  int _selectedTabIndex = 0;
  bool _isPlaying = false;
  bool _isLoading = false;

  List<Album> _recentAlbums = [];
  List<Song> _allSongs = [];
  List<Song> _favoriteSongs = [];
  List<Song> _historySongs = [];
  List<Song> _filteredSongs = [];
  
  Song? _currentSong;
  
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() {
        _selectedTabIndex = _tabController.index;
      });
    });
    
    // Initialiser avec les données scannées
    _allSongs = widget.initialSongs;
    _filteredSongs = _allSongs;
    
    // Charger les albums
    _loadAlbums();
    
    // Définir la première chanson comme courante si disponible
    if (_allSongs.isNotEmpty) {
      _currentSong = _allSongs[0];
    }
  }

  Future<void> _loadAlbums() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Album> albums = await _libraryService.scanAlbums();
      setState(() {
        _recentAlbums = albums.take(10).toList(); // Prendre les 10 premiers
        _isLoading = false;
      });
    } catch (e) {
      print('Erreur lors du chargement des albums: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshLibrary() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<Song> songs = await _libraryService.scanAudioFiles();
      setState(() {
        _allSongs = songs;
        _filteredSongs = songs;
        _isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${songs.length} chansons détectées'),
          backgroundColor: const Color(0xFF00D9FF),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Erreur lors du rafraîchissement: $e');
      setState(() {
        _isLoading = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erreur lors du rafraîchissement'),
          backgroundColor: Color(0xFFFF6B35),
        ),
      );
    }
  }

  void _searchSongs(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSongs = _allSongs;
      } else {
        String searchLower = query.toLowerCase();
        _filteredSongs = _allSongs.where((song) {
          return song.title.toLowerCase().contains(searchLower) ||
                 song.artist.toLowerCase().contains(searchLower);
        }).toList();
      }
    });
  }

  void _toggleFavorite(Song song) {
    setState(() {
      song.isFavorite = !song.isFavorite;
      
      if (song.isFavorite) {
        if (!_favoriteSongs.contains(song)) {
          _favoriteSongs.add(song);
        }
      } else {
        _favoriteSongs.remove(song);
      }
    });
    
    // TODO: Sauvegarder dans Hive
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: SafeArea(
        child: Column(
          children: [
            // Header avec logo et titre
            _buildHeader(),
            
            // Barre de recherche (affichée seulement sur l'onglet "Tout")
            if (_selectedTabIndex == 0) _buildSearchBar(),
            
            // Tabs
            _buildTabs(),
            
            // Contenu
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF00D9FF),
                      ),
                    )
                  : TabBarView(
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
          const Expanded(
            child: Text(
              'Vibz',
              style: TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          // Refresh button
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: Color(0xFF00D9FF),
            ),
            onPressed: _refreshLibrary,
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: TextField(
        controller: _searchController,
        onChanged: _searchSongs,
        style: const TextStyle(color: Colors.white),
        decoration: InputDecoration(
          hintText: 'Rechercher une chanson ou artiste...',
          hintStyle: const TextStyle(color: Color(0xFFB3B3B3)),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF00D9FF),
          ),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(
                    Icons.clear,
                    color: Color(0xFFB3B3B3),
                  ),
                  onPressed: () {
                    _searchController.clear();
                    _searchSongs('');
                  },
                )
              : null,
          filled: true,
          fillColor: const Color(0xFF2A2A2A),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
          Tab(text: 'Tout'),
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
          const SizedBox(height: 16),
          
          // Stats de la bibliothèque
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Chansons',
                  widget.libraryStats['totalSongs']?.toString() ?? '0',
                  Icons.music_note,
                ),
                _buildStatCard(
                  'Albums',
                  widget.libraryStats['totalAlbums']?.toString() ?? '0',
                  Icons.album,
                ),
                _buildStatCard(
                  'Artistes',
                  widget.libraryStats['totalArtists']?.toString() ?? '0',
                  Icons.person,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // Albums récents (si disponibles)
          if (_recentAlbums.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Albums Récents',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // TODO: Show all albums
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
                      print('Tapped album: ${_recentAlbums[index].name}');
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),
          ],
          
          // Toutes les musiques
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  _searchController.text.isEmpty
                      ? 'Toutes les Musiques'
                      : 'Résultats (${_filteredSongs.length})',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          
          // Liste des chansons
          if (_filteredSongs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(
                child: Column(
                  children: [
                    Icon(
                      Icons.music_off,
                      color: Color(0xFFB3B3B3),
                      size: 64,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Aucune chanson trouvée',
                      style: TextStyle(
                        color: Color(0xFFB3B3B3),
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _filteredSongs.length,
              itemBuilder: (context, index) {
                return SongListTile(
                  song: _filteredSongs[index],
                  onTap: () {
                    setState(() {
                      _currentSong = _filteredSongs[index];
                      _isPlaying = true;
                    });
                  },
                  onFavoriteToggle: () {
                    _toggleFavorite(_filteredSongs[index]);
                  },
                );
              },
            ),
          
          const SizedBox(height: 80), // Space for mini player
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2A2A2A),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: const Color(0xFF00D9FF),
            size: 32,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFFB3B3B3),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaylistsTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.queue_music,
            color: Color(0xFFB3B3B3),
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            'Playlists',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'À implémenter dans la Phase 4',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB3B3B3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return _favoriteSongs.isEmpty
        ? const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.favorite_border,
                  color: Color(0xFFB3B3B3),
                  size: 64,
                ),
                SizedBox(height: 16),
                Text(
                  'Aucun favori',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ajoutez des chansons à vos favoris',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFFB3B3B3),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        : ListView.builder(
            padding: const EdgeInsets.only(top: 16, bottom: 80),
            itemCount: _favoriteSongs.length,
            itemBuilder: (context, index) {
              return SongListTile(
                song: _favoriteSongs[index],
                onTap: () {
                  setState(() {
                    _currentSong = _favoriteSongs[index];
                    _isPlaying = true;
                  });
                },
                onFavoriteToggle: () {
                  _toggleFavorite(_favoriteSongs[index]);
                },
              );
            },
          );
  }

  Widget _buildHistoryTab() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history,
            color: Color(0xFFB3B3B3),
            size: 64,
          ),
          SizedBox(height: 16),
          Text(
            'Historique',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'À implémenter dans la Phase 4',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFFB3B3B3),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}