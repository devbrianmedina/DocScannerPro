import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:uuid/uuid.dart';

class ImageSaverUtil {
  static Future<String?> saveImage(String imagePath, String fileName) async {
    try {
      // Get the directory for permanent storage (could be documents directory)
      Directory appDocDir = await getApplicationDocumentsDirectory();
      String appDocPath = appDocDir.path;
      String dateTime = DateFormat("yyyyMMdd_HHmmss").format(DateTime.now());

      // Create a file in the permanent directory
      File destinationFile = File('$appDocPath/$fileName$dateTime${const Uuid().v4()}.${imagePath.split('.').last}');

      // Copy the image from the source path to the destination path
      await File(imagePath).copy(destinationFile.path);

      return destinationFile.path;
    } catch (e) {
      print('Error saving image: $e');
      return null;
    }
  }

  static Future<String?> saveImageToFile(Uint8List imageData) async {
    try {
      // Decode the image data
      img.Image image = img.decodeImage(imageData)!;

      // Create a ByteData buffer from the image data
      ByteData byteData = ByteData.sublistView(Uint8List.fromList(img.encodePng(image)));

      // Get the documents directory
      String documentsDirectory = (await getApplicationDocumentsDirectory()).path;

      String dateTime = DateFormat("yyyyMMdd_HHmmss").format(DateTime.now());

      // Create a file path
      String filePath = '$documentsDirectory/image$dateTime${const Uuid().v4()}.png';

      // Write the ByteData buffer to the file
      await File(filePath).writeAsBytes(byteData.buffer.asUint8List());

      print('Image saved to: $filePath');
      return filePath;
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
