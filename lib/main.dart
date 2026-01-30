import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'theme/app_theme.dart';
import 'screens/loading_screen.dart';
import 'services/database_service.dart';
import 'providers/library_provider.dart';
import 'providers/player_provider.dart';
import 'providers/playlist_provider.dart';
import 'providers/history_provider.dart';

void main() async {
  // Initialiser les bindings Flutter
  WidgetsFlutterBinding.ensureInitialized();
  
  // Configurer le style de la barre de statut
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Color(0xFF1F1F1F),
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialiser Hive
  print('🔄 Initialisation de Hive...');
  try {
    final databaseService = DatabaseService();
    await databaseService.initialize();
    print('✅ Hive initialisé avec succès');
  } catch (e) {
    print('❌ Erreur initialisation Hive: $e');
  }

  runApp(const VibzApp());
}

class VibzApp extends StatelessWidget {
  const VibzApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Library Provider - Gestion de la bibliothèque musicale
        ChangeNotifierProvider(
          create: (_) => LibraryProvider(),
          lazy: false,
        ),
        
        // Player Provider - Gestion du lecteur audio
        ChangeNotifierProvider(
          create: (_) => PlayerProvider(),
          lazy: false,
        ),
        
        // Playlist Provider - Gestion des playlists
        ChangeNotifierProvider(
          create: (_) => PlaylistProvider(),
          lazy: false,
        ),
        
        // History Provider - Gestion de l'historique
        ChangeNotifierProvider(
          create: (_) => HistoryProvider(),
          lazy: false,
        ),
      ],
      child: MaterialApp(
        title: 'Vibz',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.darkTheme,
        home: const LoadingScreen(),
      ),
    );
  }
}