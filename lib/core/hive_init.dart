import 'package:hive_flutter/hive_flutter.dart';

class HiveSetup {
  static Future<void> init() async {
    await Hive.initFlutter();
    // Register adapters here (see Step 4)
    await Hive.openBox('preferences'); // Main storage box
  }
}