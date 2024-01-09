import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:doc_scanner_pro/database/scanner_table.dart';
import 'package:doc_scanner_pro/utils/image_saver_util.dart';
import 'package:flutter/material.dart';
import 'package:doc_scanner_pro/models/Scanner.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:reorderable_grid/reorderable_grid.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

class ScannerViewScreenPage extends StatefulWidget {
  final Scanner scanner;

  ScannerViewScreenPage({Key? key, required this.scanner}) : super(key: key);

  @override
  State<ScannerViewScreenPage> createState() => _ScannerViewScreenPageState();
}

class _ScannerViewScreenPageState extends State<ScannerViewScreenPage> {
  List<String> imagePaths = [];

  @override
  void initState() {
    super.initState();
    imagePaths = List.from(widget.scanner.imagesPath);
  }

  Future<void> convertImagesToPdf(BuildContext context) async {
    final pdf = pw.Document();

    for (final imagePath in imagePaths) {
      final image = pw.MemoryImage(Uint8List.fromList(File(imagePath).readAsBytesSync()));
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(8.0),
          build: (context) {
            return pw.Stack(
              children: [
                pw.Center(
                  child: pw.Image(image),
                ),
                pw.Positioned(
                  bottom: 20, // Ajusta la posición vertical del texto
                  right: 20, // Ajusta la posición horizontal del texto
                  child: pw.UrlLink(
                    child: pw.Text(
                      'Make By DocScannerPro',
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.black),
                    ),
                    destination: 'https://www.dercide.com',
                  ),
                ),
              ],
            );
          },
        ),
      );
    }

    final output = await getTemporaryDirectory();
    final file = File('${output.path}/output.pdf');
    await file.writeAsBytes(await pdf.save());

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('PDF Created'),
          content: Text('PDF file has been created successfully at: ${file.path}'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cerrar'),
            ),
            TextButton(
              onPressed: () {
                Share.shareXFiles([XFile(file.path)], text: 'Doc Scanner Pro');
              },
              child: Text('Compartir'),
            ),
          ],
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.scanner.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.share), // Cambia 'settings' por el icono que desees
            onPressed: () async {
              await convertImagesToPdf(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ReorderableGridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 8.0,
          mainAxisSpacing: 8.0,
          childAspectRatio: 0.7,
          onReorder: _onReorder,
          children: _buildGridItems(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final String? imagePath = (await CunningDocumentScanner.getPictures(true))?.last;
          if(imagePath == null) return;
          String dateTime = DateFormat("yyyy/MM/dd HH:mm aa").format(DateTime.now());
          String? image = await ImageSaverUtil.saveImage(imagePath, "DocScannerPro");
          if(image == null) return;
          setState(() {
            widget.scanner.imagesPath.add(image);
            imagePaths.add(image);
          });
          await ScannerTable.update(widget.scanner);
        },
      ),
    );
  }

  List<Widget> _buildGridItems() {
    return imagePaths.map((imagePath) {
      return SizedBox(
        key: ValueKey(imagePath),
        child: GestureDetector(
          onTap: () {
            // Handle image tap (if needed)
          },
          child: Card(
            elevation: 4.0,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8.0), // Ajusta el radio según tus preferencias
              child: Image.file(File(imagePath), fit: BoxFit.cover),
            ),
          ),
        ),
      );
    }).toList();
  }

  Future<void> _onReorder(int oldIndex, int newIndex) async {
    setState(() {
      final String item = imagePaths.removeAt(oldIndex);
      imagePaths.insert(newIndex, item);
    });
    Scanner scanner = widget.scanner;
    scanner.imagesPath = imagePaths;
    await ScannerTable.update(scanner);
  }
}