import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:doc_scanner_pro/database/scanner_table.dart';
import 'package:doc_scanner_pro/models/scanner.dart';
import 'package:doc_scanner_pro/screens/scanner_view_screen.dart';
import 'package:doc_scanner_pro/utils/file_util.dart';
import 'package:doc_scanner_pro/utils/image_saver_util.dart';
import 'package:doc_scanner_pro/widgets/floating_action_bubble.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pdf_image_renderer/pdf_image_renderer.dart';
import 'package:path/path.dart' as path;

class ScannerScreenPage extends StatefulWidget {
  String title;
  ScannerScreenPage({super.key, required this.title});

  @override
  State<ScannerScreenPage> createState() => _ScannerScreenPageState();
}

class _ScannerScreenPageState extends State<ScannerScreenPage> with SingleTickerProviderStateMixin{

  List<Scanner> listScanner = [];
  late Animation<double> _animation;
  late AnimationController _animationController;

  @override
  void initState() {
    loadData();
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation = CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
  }

  Future<void> loadData() async {
    setState(() {
      listScanner = [];
    });
    List<Scanner>? list = await ScannerTable.getAll();
    if(list == null) return;
    setState(() {
      listScanner.addAll(list);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
              child: ListView.builder(
                itemCount: listScanner.length,
                itemBuilder: (BuildContext context, int index) {
                  Scanner scanner = listScanner[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: FileImage(File(scanner.imagesPath.first)),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () async {
                        setState(() {
                          listScanner.removeAt(index);
                        });
                        await ScannerTable.delete(scanner);
                        for(String path in scanner.imagesPath) {
                          await FileUtil.deleteFile(path);
                        }
                      },
                    ),
                    title: Text(scanner.title),
                    subtitle: Text(scanner.createdAt),
                    onTap: () async {
                      await Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ScannerViewScreenPage(scanner: scanner,))
                      );
                      await loadData();
                    },
                    // Add more widgets as needed
                  );
                },
              )
          )
        ],
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
                String dateTime = DateFormat("yyyy/MM/dd HH:mm aa").format(DateTime.now());
                String? image = await ImageSaverUtil.saveImage(imagePath, "DocScannerPro");
                if(image == null) return;
                int id = await ScannerTable.add(Scanner(title: "DocScannerPro ${dateTime.split(" ").first}", createdAt: dateTime, imagesPath: [image]));
                Scanner? scanner = await ScannerTable.getById(id);
                if(scanner == null) return;
                await Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => ScannerViewScreenPage(scanner: scanner,))
                );
                await loadData();
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
                  String dateTime = DateFormat("yyyy/MM/dd HH:mm aa").format(DateTime.now());
                  int id = await ScannerTable.add(Scanner(title: "DocScannerPro ${dateTime.split(" ").first}", createdAt: dateTime, imagesPath: paths));
                  Scanner? scanner = await ScannerTable.getById(id);
                  if(scanner == null) return;
                  await Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => ScannerViewScreenPage(scanner: scanner,))
                  );
                  await loadData();
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
      /*
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {

        },
      ),*/
    );
  }
}
