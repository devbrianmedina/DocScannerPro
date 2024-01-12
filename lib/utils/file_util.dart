import 'dart:io';

class FileUtil {
  static Future<bool> deleteFile(String filePath) async {
    try {
      File file = File(filePath);
      await file.delete();
      print('File deleted successfully.');
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }
}