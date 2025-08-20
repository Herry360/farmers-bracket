// lib/services/auth_storage_service.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/auth_state.dart'; // Make sure this import path is correct

class AuthStorageService {
  static const String _authBoxName = 'auth_box';
  static const String _authStateKey = 'auth_state';
  
  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized) return;
    
    try {
      await Hive.initFlutter();
      
      // Check if adapter is already registered
      if (!Hive.isAdapterRegistered(AuthStateAdapter().typeId)) {
        Hive.registerAdapter(AuthStateAdapter());
      }
      
      await Hive.openBox(_authBoxName);
      _isInitialized = true;
    } catch (e) {
      throw Exception('Failed to initialize AuthStorageService: $e');
    }
  }

  Future<void> saveAuthState(AuthState state) async {
    if (!_isInitialized) await init();
    
    try {
      final box = Hive.box(_authBoxName);
      await box.put(_authStateKey, state);
    } catch (e) {
      throw Exception('Failed to save auth state: $e');
    }
  }

  Future<AuthState?> getAuthState() async {
    if (!_isInitialized) await init();
    
    try {
      final box = Hive.box(_authBoxName);
      final state = box.get(_authStateKey);
      return state is AuthState ? state : null;
    } catch (e) {
      throw Exception('Failed to get auth state: $e');
    }
  }

  Future<void> clearAuthState() async {
    if (!_isInitialized) await init();
    
    try {
      final box = Hive.box(_authBoxName);
      await box.delete(_authStateKey);
    } catch (e) {
      throw Exception('Failed to clear auth state: $e');
    }
  }

  // Close Hive when done (call this when app closes)
  Future<void> dispose() async {
    if (_isInitialized) {
      await Hive.close();
      _isInitialized = false;
    }
  }
}