import 'package:doc_scanner_pro/database/settings_table.dart';
import 'package:doc_scanner_pro/main.dart';
import 'package:doc_scanner_pro/models/settings.dart';
import 'package:doc_scanner_pro/screens/app_screen.dart';
import 'package:flutter/material.dart';
import 'package:settings_ui/settings_ui.dart';

class SettingsScreenPage extends StatefulWidget {
  const SettingsScreenPage({Key? key}) : super(key: key);

  @override
  State<SettingsScreenPage> createState() => _SettingsScreenPageState();
}

class _SettingsScreenPageState extends State<SettingsScreenPage> {

  Settings? _settings;
  bool _darkTheme = false;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    var prefs = await SettingsTable.getSettings();
    setState(() {
      _settings = prefs;
      _darkTheme = prefs.darkTheme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ajustes"),
      ),
      body: SettingsList(
        sections: [
          SettingsSection(
            title: Text('Apariencia'),
            tiles: <SettingsTile>[
              SettingsTile.switchTile(
                onToggle: (value) async {
                  if(_settings == null) return;
                  _settings!.darkTheme = value;
                  await SettingsTable.saveSettings(_settings!);
                  setState(() {
                    _darkTheme = value;
                  });
                  Navigator.of(context).popUntil((route) => false);
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (context) => const MyApp()),
                  );
                },
                initialValue: _darkTheme,
                leading: const Icon(Icons.format_paint),
                title: const Text('Tema oscuro'),
                description: const Text('Experimental', style: TextStyle(color: Colors.red),),
              ),
            ],
          ),
        ],
      ),
    );
  }
}