import 'package:ecommerce_app/core/hive_init.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../core/storage_service.dart';

final storageProvider = FutureProvider<StorageService>((ref) async {
  await HiveSetup.init();
  return StorageService(Hive.box('preferences'));
});