import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:doc_scanner_pro/database/scanner_table.dart';
import 'package:doc_scanner_pro/utils/image_saver_util.dart';
import 'package:doc_scanner_pro/widgets/floating_action_bubble.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:doc_scanner_pro/models/Scanner.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:reorderable_grid/reorderable_grid.dart';
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;
import 'package:uuid/uuid.dart';

class ScannerViewScreenPage extends StatefulWidget {
  final Scanner scanner;

  ScannerViewScreenPage({Key? key, required this.scanner}) : super(key: key);

  @override
  State<ScannerViewScreenPage> createState() => _ScannerViewScreenPageState();
}

class _ScannerViewScreenPageState extends State<ScannerViewScreenPage> with SingleTickerProviderStateMixin{
  List<String> imagePaths = [];
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    imagePaths = List.from(widget.scanner.imagesPath);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation = CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
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
    final file = File('${output.path}/${widget.scanner.title.replaceAll(" ", "").replaceAll("/", "")}ScannerDocumentPro${const Uuid().v4()}.pdf');
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
          PopupMenuButton(
            icon: const Icon(Icons.share),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: const Text('Compartir Pdf'),
                  onTap: () async {
                    await convertImagesToPdf(context);
                  },
                ),
                PopupMenuItem(
                  child: const Text('Compartir Imagenes'),
                  onTap: () async {
                    Share.shareXFiles(widget.scanner.imagesPath.map((e) => XFile(e)).toList(), text: 'Doc Scanner Pro');
                  },
                )
              ];
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
      floatingActionButton: FloatingActionBubble(
        title: const Text('Agregar', style: TextStyle(color: Colors.white),),
        items: [
          Bubble(
              icon: Icons.document_scanner,
              iconColor: Colors.white,
              title: "Escanear",
              titleStyle: const TextStyle(fontSize: 16 , color: Colors.white),
              bubbleColor: Colors.blue,
              onPress: () async {
                final String? imagePath = (await CunningDocumentScanner.getPictures(true))?.last;
                if(imagePath == null) return;
                String? image = await ImageSaverUtil.saveImage(imagePath, "DocScannerPro");
                if(image == null) return;
                setState(() {
                  widget.scanner.imagesPath.add(image);
                  imagePaths.add(image);
                });
                await ScannerTable.update(widget.scanner);
              }
          ),
          Bubble(
              iconColor: Colors.white,
              icon: Icons.archive,
              title: "Importar",
              titleStyle: const TextStyle(fontSize: 16 , color: Colors.white),
              bubbleColor: Colors.blue,
              onPress: () async {
                FilePickerResult? result = await FilePicker.platform.pickFiles(
                  type: FileType.custom,
                  allowMultiple: true,
                  allowedExtensions: ['jpg', 'jpeg', 'png', 'heic', 'pdf'],
                );
                if (result != null) {
                  List<String> paths = [];
                  List<String> files = result.paths.map((path) => path ?? "").toList();
                  files.removeWhere((element) => element == "");
                  for (var element in files) {
                    switch(path.extension(element)) {
                      case ".pdf":
                      // Initialize the renderer
                        final pdf = PdfImageRendererPdf(path: element);
                        // open the pdf document
                        await pdf.open();
                        int pagesCount = await pdf.getPageCount();
                        for(int i = 0; i < pagesCount; i++) {
                          print("object $i");
                          // open a page from the pdf document using the page index
                          await pdf.openPage(pageIndex: i);
                          // get the render size after the page is loaded
                          final size = await pdf.getPageSize(pageIndex: i);
                          // get the actual image of the page
                          final img = await pdf.renderPage(
                            pageIndex: i,
                            x: 0,
                            y: 0,
                            width: size.width, // you can pass a custom size here to crop the image
                            height: size.height, // you can pass a custom size here to crop the image
                            scale: 1, // increase the scale for better quality (e.g. for zooming)
                            background: Colors.white,
                          );
                          // close the page again
                          await pdf.closePage(pageIndex: i);
                          if(img == null) break;
                          String? pathN = await ImageSaverUtil.saveImageToFile(img);
                          if(pathN != null) paths.add(pathN);
                        }
                        // close the PDF after rendering the page
                        pdf.close();
                        break;
                      default:
                        String? path = await ImageSaverUtil.saveImage(element, "DocScannerPro");
                        if(path == null) return;
                        paths.add(path);
                        break;
                    }
                  }
                  setState(() {
                    imagePaths.addAll(paths);
                    widget.scanner.imagesPath = imagePaths;
                  });
                  int id = await ScannerTable.update(widget.scanner);
                } //else cancel picker
              }
          ),
        ],
        // animation controller
        animation: _animation,
        animationController: _animationController,
        // On pressed change animation state
        onPress: () => _animationController.isCompleted
            ? _animationController.reverse()
            : _animationController.forward(),
        // Floating Action button Icon color
        iconColor: Colors.white,
        // Flaoting Action button Icon
        iconData: Icons.add,
        backGroundColor: Colors.blue,
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