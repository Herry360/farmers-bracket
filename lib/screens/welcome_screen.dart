import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_screen.dart';

final welcomeContentProvider = Provider<WelcomeContent>((ref) {
  return WelcomeContent(
    appName: 'FarmersBracket',
    tagline: 'Welcome to the Farmers Market!',
    buttonText: 'Continue',
    imageUrl: null,
    primaryColor: Colors.green,
    secondaryColor: Colors.white,
    showSkipButton: false,
  );
});

class WelcomeContent {
  final String appName;
  final String tagline;
  final String buttonText;
  final String? imageUrl;
  final Color primaryColor;
  final Color secondaryColor;
  final bool showSkipButton;

  WelcomeContent({
    required this.appName,
    required this.tagline,
    required this.buttonText,
    this.imageUrl,
    this.primaryColor = Colors.green,
    this.secondaryColor = Colors.white,
    this.showSkipButton = false,
  });
}

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  bool _isLoading = false;
  bool _hasSeenWelcome = false;

  @override
  void initState() {
    super.initState();
    _checkFirstSeen();
  }

  Future<void> _checkFirstSeen() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _hasSeenWelcome = prefs.getBool('has_seen_welcome') ?? false;
    });
  }

  Future<void> _navigateToLogin() async {
    setState(() => _isLoading = true);
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('has_seen_welcome', true);

    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    final welcomeContent = ref.watch(welcomeContentProvider);
    return Scaffold(
      body: _buildWelcomeContent(context, welcomeContent),
    );
  }

  Widget _buildWelcomeContent(BuildContext context, WelcomeContent content) {
    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                content.primaryColor.withAlpha(25),
                content.secondaryColor.withAlpha(25),
              ],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (content.imageUrl != null) ...[
                    // Replace with Image.asset if using local assets
                    Image.network(
                      content.imageUrl!,
                      height: 200,
                      semanticLabel: 'Welcome image',
                    ),
                    const SizedBox(height: 40),
                  ],
                  Text(
                    content.appName,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: content.primaryColor,
                    ),
                    semanticsLabel: 'App name',
                  ),
                  const SizedBox(height: 20),
                  Text(
                    content.tagline,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  const SizedBox(height: 40),
                  ElevatedButton(
                    onPressed: _isLoading ? null : _navigateToLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: content.primaryColor,
                      foregroundColor: content.secondaryColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            content.buttonText,
                            style: const TextStyle(fontSize: 16),
                          ),
                  ),
                  if (content.showSkipButton && _hasSeenWelcome) ...[
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading ? null : _navigateToLogin,
                      child: Text(
                        'Skip for now',
                        style: TextStyle(
                          color: content.primaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: TextButton(
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
            child: Text(
              'Admin Login',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
        ),
      ],
    );
  }
}