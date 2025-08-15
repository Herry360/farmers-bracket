// lib/providers/auth_storage_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_storage_service.dart';

final authStorageProvider = Provider<AuthStorageService>((ref) {
  final service = AuthStorageService();
  // Add disposal logic if needed
  ref.onDispose(() async {
    await service.dispose();
  });
  return service;
});