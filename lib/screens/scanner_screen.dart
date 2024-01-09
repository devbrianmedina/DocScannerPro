import 'dart:io';

import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:doc_scanner_pro/database/scanner_table.dart';
import 'package:doc_scanner_pro/models/Scanner.dart';
import 'package:doc_scanner_pro/screens/scanner_view_screen.dart';
import 'package:doc_scanner_pro/utils/image_saver_util.dart';
import 'package:doc_scanner_pro/widgets/floating_action_bubble.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ScannerScreenPage extends StatefulWidget {
  String title;
  ScannerScreenPage({super.key, required this.title});

  @override
  State<ScannerScreenPage> createState() => _ScannerScreenPageState();
}

class _ScannerScreenPageState extends State<ScannerScreenPage>{

  List<Scanner> listScanner = [];

  @override
  void initState() {
    loadData();
    super.initState();
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
                    title: Text(scanner.title),
                    subtitle: Text(scanner.createdAt),
                    onTap: () {
                      Navigator.of(context).push(
                          MaterialPageRoute(builder: (context) => ScannerViewScreenPage(scanner: scanner,))
                      );
                    },
                    // Add more widgets as needed
                  );
                },
              )
          )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
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
        },
      ),
    );
  }
}
