import 'dart:io';
import 'package:permission_handler/permission_handler.dart';
import 'package:device_info_plus/device_info_plus.dart';

class PermissionService {
  /// Obtenir la version SDK d'Android
  static Future<int> getAndroidSdkVersion() async {
    if (Platform.isAndroid) {
      final androidInfo = await DeviceInfoPlugin().androidInfo;
      return androidInfo.version.sdkInt;
    }
    return 0;
  }

  /// Demander la permission de lire les fichiers audio
  static Future<bool> requestAudioPermission() async {
    try {
      // Vérifier la version Android
      int sdkVersion = await getAndroidSdkVersion();
      
      print('📱 Version Android SDK: $sdkVersion');

      // Android 13+ (API 33+) utilise READ_MEDIA_AUDIO
      if (sdkVersion >= 33) {
        print('🎵 Android 13+ détecté - Utilisation de READ_MEDIA_AUDIO');
        
        // Vérifier si déjà accordée
        if (await Permission.audio.isGranted) {
          print('✅ Permission READ_MEDIA_AUDIO déjà accordée');
          return true;
        }

        // Demander la permission
        print('❓ Demande de permission READ_MEDIA_AUDIO...');
        final status = await Permission.audio.request();
        
        if (status.isGranted) {
          print('✅ Permission READ_MEDIA_AUDIO accordée');
          return true;
        } else if (status.isPermanentlyDenied) {
          print('❌ Permission READ_MEDIA_AUDIO refusée définitivement');
          await openAppSettings();
          return false;
        } else if (status.isDenied) {
          print('❌ Permission READ_MEDIA_AUDIO refusée');
          return false;
        }
      } 
      // Android 10-12 (API 29-32) utilise READ_EXTERNAL_STORAGE
      else if (sdkVersion >= 29) {
        print('📁 Android 10-12 détecté - Utilisation de READ_EXTERNAL_STORAGE');
        
        if (await Permission.storage.isGranted) {
          print('✅ Permission STORAGE déjà accordée');
          return true;
        }

        print('❓ Demande de permission STORAGE...');
        final status = await Permission.storage.request();
        
        if (status.isGranted) {
          print('✅ Permission STORAGE accordée');
          return true;
        } else if (status.isPermanentlyDenied) {
          print('❌ Permission STORAGE refusée définitivement');
          await openAppSettings();
          return false;
        } else {
          print('❌ Permission STORAGE refusée');
          return false;
        }
      }
      // Android < 10 (API < 29)
      else {
        print('📁 Android < 10 détecté - Utilisation de READ/WRITE_EXTERNAL_STORAGE');
        
        if (await Permission.storage.isGranted) {
          print('✅ Permission STORAGE déjà accordée');
          return true;
        }

        print('❓ Demande de permission STORAGE...');
        final status = await Permission.storage.request();
        
        if (status.isGranted) {
          print('✅ Permission STORAGE accordée');
          return true;
        } else if (status.isPermanentlyDenied) {
          print('❌ Permission STORAGE refusée définitivement');
          await openAppSettings();
          return false;
        } else {
          print('❌ Permission STORAGE refusée');
          return false;
        }
      }
      
      return false;
    } catch (e) {
      print('❌ Erreur lors de la demande de permission: $e');
      return false;
    }
  }
  
  /// Vérifier si la permission est accordée
  static Future<bool> hasAudioPermission() async {
    try {
      int sdkVersion = await getAndroidSdkVersion();
      
      if (sdkVersion >= 33) {
        // Android 13+
        return await Permission.audio.isGranted;
      } else {
        // Android < 13
        return await Permission.storage.isGranted;
      }
    } catch (e) {
      print('❌ Erreur lors de la vérification de permission: $e');
      return false;
    }
  }

  /// Demander toutes les permissions nécessaires
  static Future<Map<String, bool>> requestAllPermissions() async {
    try {
      int sdkVersion = await getAndroidSdkVersion();
      Map<String, bool> results = {};

      if (sdkVersion >= 33) {
        // Android 13+: demander READ_MEDIA_AUDIO, READ_MEDIA_VIDEO, READ_MEDIA_IMAGES
        Map<Permission, PermissionStatus> statuses = await [
          Permission.audio,
          Permission.videos,
          Permission.photos,
        ].request();

        results['audio'] = statuses[Permission.audio]?.isGranted ?? false;
        results['videos'] = statuses[Permission.videos]?.isGranted ?? false;
        results['photos'] = statuses[Permission.photos]?.isGranted ?? false;
      } else {
        // Android < 13: demander STORAGE
        final status = await Permission.storage.request();
        results['storage'] = status.isGranted;
      }

      return results;
    } catch (e) {
      print('❌ Erreur lors de la demande de toutes les permissions: $e');
      return {};
    }
  }

  /// Vérifier le statut détaillé de la permission
  static Future<PermissionStatus> getAudioPermissionStatus() async {
    try {
      int sdkVersion = await getAndroidSdkVersion();
      
      if (sdkVersion >= 33) {
        return await Permission.audio.status;
      } else {
        return await Permission.storage.status;
      }
    } catch (e) {
      print('❌ Erreur lors de la récupération du statut: $e');
      return PermissionStatus.denied;
    }
  }

  /// Afficher un dialogue explicatif avant de demander la permission
  static String getPermissionRationale() {
    return 'Vibz a besoin d\'accéder à vos fichiers audio pour :\n\n'
           '• Scanner et afficher votre bibliothèque musicale\n'
           '• Lire vos fichiers audio locaux\n'
           '• Gérer vos playlists\n\n'
           'Aucune donnée ne sera partagée ou envoyée en ligne.';
  }
}