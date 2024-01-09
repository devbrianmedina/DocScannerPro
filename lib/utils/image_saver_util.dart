import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

class ImageSaverUtil {
  static Future<String?> saveImage(String imagePath, String fileName) async {
    try {
      // Get the directory for permanent storage (could be documents directory)
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String dateTime = DateFormat("yyyyMMdd_HHmmss").format(DateTime.now());

      // Create a file in the permanent directory
      File destinationFile = File('$appDocPath/$fileName $dateTime.${imagePath.split('.').last}');

      // Copy the image from the source path to the destination path
      await File(imagePath).copy(destinationFile.path);

      return destinationFile.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }
}

// Example usage:
// String sourceImagePath = ... // Path to your source image
// String fileName = 'example_image.jpg';
// String? savedImagePath = await ImageSaver.saveImage(sourceImagePath, fileName);
// if (savedImagePath != null) {
//   print('Image saved successfully at: $savedImagePath');
// }
