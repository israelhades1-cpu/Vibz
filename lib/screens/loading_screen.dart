import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/audio_library_service.dart';
import '../services/permission_service.dart';
import '../models/song.dart';
import 'home_screen.dart';

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({Key? key}) : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  final AudioLibraryService _libraryService = AudioLibraryService();
  
  String _statusMessage = 'Initialisation...';
  bool _hasError = false;
  String _errorMessage = '';
  double _progress = 0.0;
  bool _showPermissionRationale = false;
  bool _isPermissionPermanentlyDenied = false;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    try {
      // Étape 1: Vérifier la version Android
      setState(() {
        _statusMessage = 'Vérification du système...';
        _progress = 0.1;
      });

      int sdkVersion = await PermissionService.getAndroidSdkVersion();
      print('📱 SDK Version: $sdkVersion');

      await Future.delayed(const Duration(milliseconds: 300));

      // Étape 2: Vérifier les permissions
      setState(() {
        _statusMessage = 'Vérification des permissions...';
        _progress = 0.2;
      });

      bool hasPermission = await PermissionService.hasAudioPermission();
      
      if (!hasPermission) {
        // Afficher d'abord la justification
        setState(() {
          _showPermissionRationale = true;
          _statusMessage = 'Permission requise';
          _progress = 0.25;
        });

        // Attendre 2 secondes pour que l'utilisateur lise
        await Future.delayed(const Duration(seconds: 2));

        setState(() {
          _statusMessage = 'Demande de permission...';
          _progress = 0.3;
          _showPermissionRationale = false;
        });

        hasPermission = await PermissionService.requestAudioPermission();
        
        if (!hasPermission) {
          // Vérifier si refusée définitivement
          PermissionStatus status = await PermissionService.getAudioPermissionStatus();
          
          setState(() {
            _hasError = true;
            _isPermissionPermanentlyDenied = status.isPermanentlyDenied;
            
            if (status.isPermanentlyDenied) {
              _errorMessage = 'Permission refusée définitivement.\n\n'
                  'Veuillez aller dans les paramètres de l\'application '
                  'et autoriser l\'accès au stockage/fichiers audio.';
            } else {
              _errorMessage = 'Permission refusée.\n\n'
                  'L\'application a besoin d\'accéder à vos fichiers audio pour fonctionner.';
            }
          });
          return;
        }
      }

      print('✅ Permissions OK, démarrage du scan...');

      // Étape 3: Scanner la bibliothèque
      setState(() {
        _statusMessage = 'Scan de votre bibliothèque musicale...';
        _progress = 0.5;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      List<Song> songs = await _libraryService.scanAudioFiles();

      print('📁 ${songs.length} chansons trouvées');

      setState(() {
        _statusMessage = '${songs.length} chanson${songs.length > 1 ? 's' : ''} détectée${songs.length > 1 ? 's' : ''}';
        _progress = 0.8;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Étape 4: Récupérer les statistiques
      Map<String, int> stats = await _libraryService.getLibraryStats();

      setState(() {
        _statusMessage = 'Finalisation...';
        _progress = 1.0;
      });

      await Future.delayed(const Duration(milliseconds: 500));

      // Navigation vers l'écran principal
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              initialSongs: songs,
              libraryStats: stats,
            ),
          ),
        );
      }

    } catch (e) {
      print('❌ Erreur: $e');
      setState(() {
        _hasError = true;
        _errorMessage = 'Erreur lors de l\'initialisation:\n\n${e.toString()}';
      });
    }
  }

  Future<void> _retryInitialization() async {
    setState(() {
      _hasError = false;
      _errorMessage = '';
      _progress = 0.0;
      _statusMessage = 'Initialisation...';
      _isPermissionPermanentlyDenied = false;
      _showPermissionRationale = false;
    });
    
    await _initializeApp();
  }

  Future<void> _openSettings() async {
    await openAppSettings();
    // Après le retour des paramètres, réessayer
    await Future.delayed(const Duration(seconds: 1));
    _retryInitialization();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1F1F1F),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              Container(
                width: 120,
                height: 120,
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
                    width: 110,
                    height: 110,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: Color(0xFF2A2A2A),
                    ),
                    child: const Center(
                      child: Text(
                        'Vibz',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 48),

              // Titre
              const Text(
                'Vibz',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'Votre lecteur de musique',
                style: TextStyle(
                  color: Color(0xFFB3B3B3),
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 64),

              // Contenu conditionnel
              if (_showPermissionRationale) ...[
                // Justification de la permission
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2A2A2A),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF00D9FF),
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Permission requise',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        PermissionService.getPermissionRationale(),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFB3B3B3),
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ] else if (_hasError) ...[
                // Affichage d'erreur
                Icon(
                  _isPermissionPermanentlyDenied 
                      ? Icons.settings_outlined 
                      : Icons.error_outline,
                  color: const Color(0xFFFF6B35),
                  size: 64,
                ),
                const SizedBox(height: 24),
                Text(
                  _errorMessage,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 32),
                
                // Boutons d'action
                if (_isPermissionPermanentlyDenied) ...[
                  // Permission refusée définitivement - Ouvrir les paramètres
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _openSettings,
                      icon: const Icon(Icons.settings),
                      label: const Text('Ouvrir les Paramètres'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF00D9FF),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 32,
                          vertical: 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ] else ...[
                  // Permission simplement refusée - Réessayer
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _retryInitialization,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Réessayer'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF00D9FF),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: _openSettings,
                          icon: const Icon(Icons.settings),
                          label: const Text('Paramètres'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2A2A2A),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              vertical: 16,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ] else ...[
                // Barre de progression
                SizedBox(
                  width: 250,
                  child: Column(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: _progress,
                          backgroundColor: const Color(0xFF2A2A2A),
                          valueColor: const AlwaysStoppedAnimation<Color>(
                            Color(0xFF00D9FF),
                          ),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        _statusMessage,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFB3B3B3),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}