import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

class DownloadDBFile {
  /// Requests storage permissions for Android and iOS
  static Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      if (await Permission.storage.request().isGranted) {
        return true;
      }

      // For Android 11+ (Scoped Storage)
      if (await Permission.manageExternalStorage.request().isGranted) {
        return true;
      }
    }

    if (Platform.isIOS) {
      if (await Permission.photos.request().isGranted) {
        return true;
      }
    }

    return false;
  }

  /// Downloads the database file and saves it to Downloads directory
  static Future<void> downloadDBFile() async {
    try {
      // Check & Request Permissions
      bool hasPermission = await requestPermissions();
      if (!hasPermission) {
        print("Storage permission denied!");
        return;
      }

      // Get the database file path
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String dbPath = '${appDocDir.path}/my_database.db';

      File dbFile = File(dbPath);
      if (!dbFile.existsSync()) {
        throw Exception("Database file not found!");
      }

      // Get the Downloads directory (Android) or Documents (iOS)
      Directory? downloadsDir;
      if (Platform.isAndroid) {
        downloadsDir = await getExternalStorageDirectory(); // Android
      } else if (Platform.isIOS) {
        downloadsDir = await getApplicationDocumentsDirectory(); // iOS
      }

      if (downloadsDir == null) throw Exception("Downloads directory not found!");

      // Copy database file to downloads folder
      String newFilePath = '${downloadsDir.path}/my_database.db';
      await dbFile.copy(newFilePath);

      print("✅ Database file downloaded at: $newFilePath");
    } catch (e) {
      print("❌ Error downloading database file: $e");
    }
  }
}
