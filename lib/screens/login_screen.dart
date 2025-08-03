import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Provider for authentication service
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Authentication service class
class AuthService {
  Future<UserCredential?> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      return await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);
    } on FirebaseAuthException {
      rethrow;
    }
  }
}

// Provider for login screen state
final loginControllerProvider =
    StateNotifierProvider<LoginController, AsyncValue<void>>((ref) {
  final authService = ref.watch(authServiceProvider);
  return LoginController(authService: authService);
});

// Login controller to handle business logic
class LoginController extends StateNotifier<AsyncValue<void>> {
  final AuthService _authService;

  LoginController({required AuthService authService})
      : _authService = authService,
        super(const AsyncValue.data(null));

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();
    try {
      await _authService.signInWithEmailAndPassword(email, password);
      state = const AsyncValue.data(null);
    } on FirebaseAuthException catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = TextEditingController();
    final passwordController = TextEditingController();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Welcome to Our App',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 40),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(
                  labelText: 'Email',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 24),
              Consumer(
                builder: (context, ref, child) {
                  final loginState = ref.watch(loginControllerProvider);
                  final loginController =
                      ref.read(loginControllerProvider.notifier);

                  return loginState.isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton(
                          onPressed: () async {
                            final email = emailController.text.trim();
                            final password = passwordController.text;

                            if (email.isEmpty || password.isEmpty) {
                              _showErrorSnackbar(
                                  context, 'Please enter email and password');
                              return;
                            }

                            try {
                              await loginController.login(email, password);
                              if (context.mounted) {
                                Navigator.of(context)
                                    .pushReplacementNamed('/home');
                              }
                            } on FirebaseAuthException catch (e) {
                              _showErrorSnackbar(
                                  context, 'Firebase error: ${e.message}');
                            } catch (e) {
                              _showErrorSnackbar(
                                  context, 'Error: ${e.toString()}');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            minimumSize: const Size(double.infinity, 50),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Login',
                            style: TextStyle(fontSize: 16),
                          ),
                        );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showErrorSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
}