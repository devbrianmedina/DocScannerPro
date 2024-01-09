import 'package:cunning_document_scanner/cunning_document_scanner.dart';
import 'package:doc_scanner_pro/screens/scanner_screen.dart';
import 'package:doc_scanner_pro/widgets/floating_action_bubble.dart';
import 'package:flutter/material.dart';

class AppScreenPage extends StatefulWidget {
  const AppScreenPage({super.key});

  @override
  State<AppScreenPage> createState() => _AppScreenPageState();
}

class _AppScreenPageState extends State<AppScreenPage> with SingleTickerProviderStateMixin {

  late Animation<double> _animation;
  late AnimationController _animationController;
  String currentView = 'scanner';
  String _title = '';
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
        default:
          _title = "Scanner";
          _screen =  ScannerScreenPage(title: _title,);
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
