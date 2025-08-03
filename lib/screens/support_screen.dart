import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Fixed import
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart'; // Added for DateFormat

// Provider for support options
final supportOptionsProvider = FutureProvider.autoDispose<List<SupportOption>>((ref) async {
  return SupportService.fetchSupportOptions();
});

class SupportOption {
  final String id;
  final String title;
  final IconData icon;
  final String? subtitle;
  final String? action;
  final String? description;
  final int displayOrder;
  final bool isActive;
  final DateTime? updatedAt;

  SupportOption({
    required this.id,
    required this.title,
    required this.icon,
    this.subtitle,
    this.action,
    this.description,
    this.displayOrder = 0,
    this.isActive = true,
    this.updatedAt,
  });

  factory SupportOption.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return SupportOption(
      id: doc.id,
      title: data['title'] ?? 'Support',
      icon: _iconFromString(data['icon'] ?? 'help_outline'),
      subtitle: data['subtitle'],
      action: data['action'],
      description: data['description'],
      displayOrder: data['displayOrder'] ?? 0,
      isActive: data['isActive'] ?? true,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(), // Fixed Timestamp usage
    );
  }

  static IconData _iconFromString(String iconName) {
    switch (iconName) {
      case 'question_answer': return Icons.question_answer;
      case 'email': return Icons.email;
      case 'phone': return Icons.phone;
      case 'chat': return Icons.chat;
      case 'forum': return Icons.forum;
      case 'help': return Icons.help;
      case 'contact_support': return Icons.contact_support;
      case 'feedback': return Icons.feedback;
      default: return Icons.help_outline;
    }
  }
}

class SupportService {
  static final _firestore = FirebaseFirestore.instance;

  static Future<List<SupportOption>> fetchSupportOptions() async {
    try {
      final querySnapshot = await _firestore
          .collection('support_options')
          .where('isActive', isEqualTo: true)
          .orderBy('displayOrder')
          .get();

      return querySnapshot.docs
          .map((doc) => SupportOption.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load support options: $e');
    }
  }

  static Future<void> logSupportInteraction({
    required String optionId,
    required String optionTitle,
    String? userId,
  }) async {
    try {
      await _firestore.collection('support_interactions').add({
        'optionId': optionId,
        'optionTitle': optionTitle,
        'userId': userId ?? FirebaseAuth.instance.currentUser?.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      debugPrint('Failed to log support interaction: $e');
    }
  }
}

class SupportScreen extends ConsumerWidget {
  const SupportScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final supportOptionsAsync = ref.watch(supportOptionsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Help & Support'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => ref.refresh(supportOptionsProvider),
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: supportOptionsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load support options',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(supportOptionsProvider),
                child: const Text('Try Again'),
              ),
            ],
          ),
        ),
        data: (options) {
          if (options.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.support_agent, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    'No support options available',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  const Text('Please check back later'),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: options.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final option = options[index];
              return _SupportOptionCard(
                option: option,
                onTap: () => _handleOptionTap(context, option),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _handleOptionTap(BuildContext context, SupportOption option) async {
    // Log the interaction
    final userId = FirebaseAuth.instance.currentUser?.uid;
    await SupportService.logSupportInteraction(
      optionId: option.id,
      optionTitle: option.title,
      userId: userId,
    );

    if (option.action != null) {
      final uri = Uri.parse(option.action!);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Cannot launch ${option.title}')),
          );
        }
      }
    } else {
      // For options without actions, navigate to detail screen
      if (context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SupportDetailScreen(option: option),
          ),
        );
      }
    }
  }
}

class _SupportOptionCard extends StatelessWidget {
  final SupportOption option;
  final VoidCallback onTap;

  const _SupportOptionCard({
    required this.option,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: theme.dividerColor,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  option.icon,
                  color: theme.colorScheme.primary,
                  semanticLabel: option.title,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      option.title,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (option.subtitle != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        option.subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class SupportDetailScreen extends StatelessWidget {
  final SupportOption option;

  const SupportDetailScreen({super.key, required this.option});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(option.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: colorScheme.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                option.icon,
                size: 40,
                color: colorScheme.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              option.title,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
            if (option.subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                option.subtitle!,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.8),
                ),
                textAlign: TextAlign.center,
              ),
            ],
            const SizedBox(height: 32),
            if (option.description != null) ...[
              Text(
                option.description!,
                style: theme.textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
            ],
            if (option.action != null) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    final uri = Uri.parse(option.action!);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Cannot launch ${option.title}')),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Text(
                    option.action!.startsWith('mailto:')
                        ? 'Send Email'
                        : option.action!.startsWith('tel:')
                            ? 'Call Now'
                            : option.action!.startsWith('http')
                                ? 'Open Website'
                                : 'Open Link',
                  ),
                ),
              ),
            ],
            if (option.updatedAt != null) ...[
              const SizedBox(height: 32),
              Text(
                'Last updated: ${DateFormat('MMM dd, yyyy').format(option.updatedAt!)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}