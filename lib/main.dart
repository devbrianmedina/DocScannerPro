import 'package:doc_scanner_pro/database/settings_table.dart';
import 'package:doc_scanner_pro/screens/app_screen.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: getDarkThemeFromSettings(),
      builder: (context, snapshot) {
        bool isDarkTheme = snapshot.data ?? false;

        return MaterialApp(
          title: 'Doc Scanner Pro',
          theme: isDarkTheme
            ? ThemeData.dark().copyWith(
            appBarTheme: AppBarTheme(
              backgroundColor: Colors.grey.shade800
            )
          )
            : ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
              appBarTheme: const AppBarTheme(
                  backgroundColor: Colors.blue,
                foregroundColor: Colors.white
              )
        ),
          home: AppScreenPage(darkTheme: isDarkTheme,),
        );
      },
    );
  }

  Future<bool> getDarkThemeFromSettings() async {
    bool isDarkTheme = (await SettingsTable.getSettings()).darkTheme;
    return isDarkTheme;
  }
}
