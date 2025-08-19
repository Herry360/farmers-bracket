import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// User model that would replace Firebase's User
class AppUser {
  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final bool emailVerified;

  const AppUser({
    required this.uid,
    this.email,
    this.displayName,
    this.photoUrl,
    this.emailVerified = false,
  });

  factory AppUser.empty() {
    return AppUser(uid: '');
  }

  bool get isAnonymous => uid.isEmpty;
}

// Auth state model
class AuthState {
  final bool isAuthenticated;
  final AppUser? user;
  final bool isLoading;
  final String? error;

  const AuthState({
    required this.isAuthenticated,
    this.user,
    this.isLoading = false,
    this.error,
  });

  AuthState copyWith({
    bool? isAuthenticated,
    AppUser? user,
    bool? isLoading,
    String? error,
  }) {
    return AuthState(
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }

  Widget when({
    required Widget Function() loading,
    required Widget Function(AppUser user) authenticated,
    required Widget Function() unauthenticated,
    required Widget Function(String error) error,
  }) {
    if (isLoading) {
      return loading();
    } else if (this.error != null) {
      return error(this.error!);
    } else if (isAuthenticated && user != null) {
      return authenticated(user!);
    } else {
      return unauthenticated();
    }
  }
}

// Abstract authentication service
abstract class AuthService {
  Future<AppUser?> getCurrentUser();
  Future<AppUser?> login(String email, String password);
  Future<void> logout();
  Future<AppUser?> register(String email, String password, Map<String, dynamic> userMetadata);
  Future<void> resetPassword(String email);
}

// Mock authentication service for UI development
class MockAuthService implements AuthService {
  @override
  Future<AppUser?> getCurrentUser() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));
    // Return null for unauthenticated state
    // return null;
    // Or return a mock user for authenticated state
    return const AppUser(
      uid: 'mock_uid_123',
      email: 'mock@example.com',
      displayName: 'Mock User',
      photoUrl: 'https://example.com/avatar.jpg',
      emailVerified: true,
    );
  }

  @override
  Future<AppUser?> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 2));
    if (email == 'test@example.com' && password == 'password') {
      return const AppUser(
        uid: 'mock_uid_123',
        email: 'test@example.com',
        displayName: 'Test User',
        emailVerified: true,
      );
    } else {
      throw Exception('Invalid email or password');
    }
  }

  @override
  Future<void> logout() async {
    await Future.delayed(const Duration(seconds: 1));
  }

  @override
  Future<AppUser?> register(String email, String password, Map<String, dynamic> userMetadata) async {
    await Future.delayed(const Duration(seconds: 2));
    return AppUser(
      uid: 'new_user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      displayName: userMetadata['name'],
      photoUrl: userMetadata['avatar_url'],
    );
  }

  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1));
    if (!email.contains('@')) {
      throw Exception('Invalid email address');
    }
  }
}

// Auth notifier - now using abstract AuthService
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final AuthService _authService;

  AuthNotifier(this.ref, {AuthService? authService})
      : _authService = authService ?? MockAuthService(),
        super(const AuthState(isAuthenticated: false)) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      final user = await _authService.getCurrentUser();

      if (user != null) {
        state = AuthState(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
      } else {
        state = const AuthState(isAuthenticated: false, isLoading: false);
      }
    } catch (e) {
      state = AuthState(
        isAuthenticated: false,
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  Future<void> login({required String email, required String password}) async {
    try {
      state = state.copyWith(isLoading: true);
      final user = await _authService.login(email, password);
      
      if (user != null) {
        state = AuthState(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Login failed. Please try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getAuthErrorMessage(e),
      );
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);
      await _authService.logout();
      state = const AuthState(isAuthenticated: false, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Logout failed. Please try again.',
      );
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required Map<String, dynamic> userMetadata,
  }) async {
    try {
      state = state.copyWith(isLoading: true);
      final user = await _authService.register(email, password, userMetadata);

      if (user != null) {
        state = AuthState(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Registration failed. Please try again.',
        );
      }
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getAuthErrorMessage(e),
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      state = state.copyWith(isLoading: true);
      await _authService.resetPassword(email);
      state = state.copyWith(
        isLoading: false,
        error: 'Password reset email sent to $email',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getAuthErrorMessage(e),
      );
    }
  }

  String _getAuthErrorMessage(dynamic e) {
    final error = e.toString();
    if (error.contains('Invalid email or password')) {
      return 'Invalid email or password';
    } else if (error.contains('Invalid email address')) {
      return 'Invalid email address';
    } else if (error.contains('already in use')) {
      return 'Email already in use';
    } else if (error.contains('too weak')) {
      return 'Password is too weak';
    } else if (error.contains('too many requests')) {
      return 'Too many requests. Try again later';
    }
    return 'Authentication failed';
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});