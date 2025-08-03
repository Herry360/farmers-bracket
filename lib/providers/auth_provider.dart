import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';

// Auth state model
class AuthState {
  final bool isAuthenticated;
  final User? user;
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
    User? user,
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
    required Widget Function(User user) authenticated,
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

// Auth notifier - using Firebase
class AuthNotifier extends StateNotifier<AuthState> {
  final Ref ref;
  final FirebaseAuth _auth;

  AuthNotifier(this.ref) 
    : _auth = FirebaseAuth.instance,
      super(const AuthState(isAuthenticated: false)) {
    _initializeAuth();
  }

  Future<void> _initializeAuth() async {
    state = state.copyWith(isLoading: true);
    try {
      // Initialize Firebase if not already initialized
      await Firebase.initializeApp();

      // Get initial auth state
      final user = _auth.currentUser;

      if (user != null) {
        state = AuthState(
          isAuthenticated: true,
          user: user,
          isLoading: false,
        );
      } else {
        state = const AuthState(isAuthenticated: false, isLoading: false);
      }

      // Listen for auth state changes
      _auth.authStateChanges().listen((User? user) {
        if (user != null) {
          state = AuthState(
            isAuthenticated: true,
            user: user,
            isLoading: false,
          );
        } else {
          state = const AuthState(isAuthenticated: false, isLoading: false);
        }
      });
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
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        state = AuthState(
          isAuthenticated: true,
          user: userCredential.user,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Login failed. Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getFirebaseAuthErrorMessage(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);
      await _auth.signOut();
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
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Update user profile with metadata
        await userCredential.user?.updateDisplayName(userMetadata['name']);
        await userCredential.user?.updatePhotoURL(userMetadata['avatar_url']);
        
        state = AuthState(
          isAuthenticated: true,
          user: userCredential.user,
          isLoading: false,
        );
      } else {
        state = state.copyWith(
          isLoading: false,
          error: 'Registration failed. Please try again.',
        );
      }
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getFirebaseAuthErrorMessage(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      state = state.copyWith(isLoading: true);
      await _auth.sendPasswordResetEmail(email: email);
      state = state.copyWith(
        isLoading: false,
        error: 'Password reset email sent to $email',
      );
    } on FirebaseAuthException catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: _getFirebaseAuthErrorMessage(e),
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to send password reset email',
      );
    }
  }

  String _getFirebaseAuthErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'invalid-email':
        return 'Invalid email address';
      case 'email-already-in-use':
        return 'Email already in use';
      case 'weak-password':
        return 'Password is too weak';
      case 'too-many-requests':
        return 'Too many requests. Try again later';
      default:
        return e.message ?? 'Authentication failed';
    }
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref);
});