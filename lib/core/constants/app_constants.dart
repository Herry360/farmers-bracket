import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'E-Commerce App';
  
  static const Map<String, dynamic> remoteConfigDefaults = {
    'default_theme_mode': 0, // system
    'default_primary_color': 0xFF2196F3, // Colors.blue
    'default_secondary_color': 0xFFFFC107, // Colors.amber
    'default_amoled_dark': false,
    'default_high_contrast': false,
    'theme_settings_locked': false,
  };
  
  static const List<Color> presetColors = [
    Colors.blue,
    Colors.red,
    Colors.green,
    Colors.purple,
    Colors.orange,
    Colors.teal,
    Colors.pink,
    Colors.indigo,
  ];
}