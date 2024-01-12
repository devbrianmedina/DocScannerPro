import 'dart:convert';

class Settings {
  bool darkTheme;
  String preferredAdType;

  Settings({
    required this.darkTheme,
    required this.preferredAdType,
  });

  Map<String, dynamic> toMap() {
    return {
      'darkTheme': darkTheme ? 1 : 0, // 1 for true, 0 for false
      'preferredAdType': preferredAdType,
    };
  }

  factory Settings.fromMap(Map<String, dynamic> map) {
    return Settings(
      darkTheme: map['darkTheme'] == 1,
      preferredAdType: map['preferredAdType'],
    );
  }
}