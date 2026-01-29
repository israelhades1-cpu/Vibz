import 'package:permission_handler/permission_handler.dart';

class PermissionService {
  /// Demander la permission de lire les fichiers audio
  static Future<bool> requestAudioPermission() async {
    // Android 13+ (API 33+) utilise READ_MEDIA_AUDIO
    if (await Permission.audio.isGranted) {
      return true;
    }
    
    // Demander la permission
    final status = await Permission.audio.request();
    
    if (status.isGranted) {
      return true;
    } else if (status.isPermanentlyDenied) {
      // L'utilisateur a refusé définitivement, ouvrir les paramètres
      await openAppSettings();
      return false;
    }
    
    return false;
  }
  
  /// Vérifier si la permission est accordée
  static Future<bool> hasAudioPermission() async {
    return await Permission.audio.isGranted;
  }
}