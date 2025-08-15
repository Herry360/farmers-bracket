import 'package:hive_flutter/hive_flutter.dart';

class StorageService {
  final Box _box;

  StorageService(this._box);

  // String operations
  Future<void> setString(String key, String value) => _box.put(key, value);
  String? getString(String key) => _box.get(key);

  // Bool operations
  Future<void> setBool(String key, bool value) => _box.put(key, value);
  bool getBool(String key, [bool defaultValue = false]) => 
      _box.get(key, defaultValue: defaultValue);

  // Clear storage
  Future<void> clear() => _box.clear();
}