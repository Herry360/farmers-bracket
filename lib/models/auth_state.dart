// lib/models/auth_state.dart
import 'package:hive/hive.dart';

part 'auth_state.g.dart'; // This will be generated

@HiveType(typeId: 0) // Unique typeId for Hive
class AuthState {
  @HiveField(0)
  final String token;
  
  @HiveField(1)
  final String userId;
  
  @HiveField(2)
  final DateTime? expiryDate;
  
  @HiveField(3)
  final bool isLoggedIn;

  AuthState({
    required this.token,
    required this.userId,
    this.expiryDate,
    required this.isLoggedIn,
  });
}