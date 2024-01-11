import 'package:doc_scanner_pro/database/scanner_table.dart';
import 'package:doc_scanner_pro/models/Scanner.dart';
import 'package:doc_scanner_pro/screens/scanner_screen.dart';
import 'package:doc_scanner_pro/screens/scanner_view_screen.dart';
import 'package:doc_scanner_pro/utils/image_saver_util.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as path;
import 'package:pdf_image_renderer/pdf_image_renderer.dart';

class AppScreenPage extends StatefulWidget {
  const AppScreenPage({super.key});

  @override
  State<AppScreenPage> createState() => _AppScreenPageState();
}

class _AppScreenPageState extends State<AppScreenPage> with SingleTickerProviderStateMixin {

  late Animation<double> _animation;
  late AnimationController _animationController;
  String currentView = 'scanner';
  String _title = 'Scanner';
  late Widget _screen;

  @override
  void initState() {
    _screen =  ScannerScreenPage(title: _title,);
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    final curvedAnimation = CurvedAnimation(curve: Curves.easeInOut, parent: _animationController);
    _animation = Tween<double>(begin: 0, end: 1).animate(curvedAnimation);
    super.initState();
  }

  void setCurrentView(String view) {
    if(_animationController.isCompleted) {
      _animationController.reverse();
    }
    setState(() {
      currentView = view;
      switch(view) {
        case "scanner":
          _title = "Scanner";
          _screen =  ScannerScreenPage(title: _title,);
          break;
        default:
          _screen =  const SizedBox();
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(_title),
        actions: [
          PopupMenuButton(
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  child: const Row(
                    children: [
                      Icon(Icons.settings),
                      SizedBox(width: 8.0,),
                      Text('Ajustes')
                    ],
                  ),
                  onTap: () {
                  },
                ),
              ];
            },
          ),
        ],
      ),
      body: _screen,
      drawer: Drawer(
          child: ListView(
              children: [
                ListTile(
                  title: Text("Doc Scanner Pro", style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),),
                  subtitle: Text('contact@dercide.com', style: TextStyle(fontStyle: FontStyle.italic, color: Theme.of(context).primaryColor)),
                  leading: Image.asset('assets/images/logo.png'),
                  selected: true,
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
                ListTile(
                  title: const Text("Scanner"),
                  leading: const Icon(Icons.camera),
                  selected: currentView == 'resume',
                  onTap: () {
                    setCurrentView('scanner');
                    Navigator.pop(context);
                  },
                ),
              ]
          )
      ),
    );
  }
}
