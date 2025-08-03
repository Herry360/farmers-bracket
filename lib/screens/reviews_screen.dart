import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

// Review Model
class Review {
  final String id;
  final String itemName;
  final double rating;
  final String comment;
  final DateTime date;
  final String userId;

  Review({
    required this.id,
    required this.itemName,
    required this.rating,
    required this.comment,
    required this.date,
    required this.userId,
  });

  factory Review.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Review(
      id: doc.id,
      itemName: data['itemName'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
      comment: data['comment'] ?? '',
      date: (data['date'] as Timestamp).toDate(),
      userId: data['userId'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'itemName': itemName,
      'rating': rating,
      'comment': comment,
      'date': Timestamp.fromDate(date),
      'userId': userId,
    };
  }

  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);
  String get starRating => '★' * rating.floor() + '☆' * (5 - rating.floor());
}

// Review Provider
final reviewsProvider = StreamProvider.autoDispose<List<Review>>((ref) {
  final userId = FirebaseAuth.instance.currentUser?.uid;
  if (userId == null) return const Stream.empty();

  return FirebaseFirestore.instance
      .collection('reviews')
      .where('userId', isEqualTo: userId)
      .orderBy('date', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs.map(Review.fromFirestore).toList());
});

class ReviewsScreen extends ConsumerWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reviewsAsync = ref.watch(reviewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reviews'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddReviewDialog(context, ref),
            tooltip: 'Add Review',
          ),
        ],
      ),
      body: reviewsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('Error loading reviews', 
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(error.toString(), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => ref.refresh(reviewsProvider),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
        data: (reviews) {
          if (reviews.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.reviews, size: 64, color: Colors.grey),
                  const SizedBox(height: 16),
                  Text('No reviews yet', 
                      style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  const Text('Your reviews will appear here'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _showAddReviewDialog(context, ref),
                    child: const Text('Add Your First Review'),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () => ref.refresh(reviewsProvider as Refreshable<Future<void>>),
            child: ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: reviews.length,
              separatorBuilder: (context, index) => const Divider(height: 24),
              itemBuilder: (context, index) {
                final review = reviews[index];
                return _ReviewCard(
                  review: review,
                  onDelete: () => _deleteReview(context, ref, review.id),
                  onEdit: () => _showEditReviewDialog(context, ref, review),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _showAddReviewDialog(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final itemController = TextEditingController();
    final commentController = TextEditingController();
    double rating = 3.0;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add New Review'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: itemController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => 
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Rating:'),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Slider(
                          value: rating,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: rating.toStringAsFixed(1),
                          onChanged: (value) => rating = value,
                        ),
                      ),
                      Text(rating.toStringAsFixed(1)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: 'Comment',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) => 
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  final userId = FirebaseAuth.instance.currentUser?.uid;
                  if (userId == null) return;

                  try {
                    await FirebaseFirestore.instance.collection('reviews').add({
                      'itemName': itemController.text,
                      'rating': rating,
                      'comment': commentController.text,
                      'date': Timestamp.now(),
                      'userId': userId,
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Review added successfully')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                }
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _showEditReviewDialog(
    BuildContext context, 
    WidgetRef ref, 
    Review review,
  ) async {
    final formKey = GlobalKey<FormState>();
    final itemController = TextEditingController(text: review.itemName);
    final commentController = TextEditingController(text: review.comment);
    double rating = review.rating;

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Edit Review'),
          content: Form(
            key: formKey,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextFormField(
                    controller: itemController,
                    decoration: const InputDecoration(
                      labelText: 'Item Name',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) => 
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      const Text('Rating:'),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Slider(
                          value: rating,
                          min: 1,
                          max: 5,
                          divisions: 4,
                          label: rating.toStringAsFixed(1),
                          onChanged: (value) => rating = value,
                        ),
                      ),
                      Text(rating.toStringAsFixed(1)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: commentController,
                    decoration: const InputDecoration(
                      labelText: 'Comment',
                      border: OutlineInputBorder(),
                    ),
                    maxLines: 3,
                    validator: (value) => 
                        value?.isEmpty ?? true ? 'Required' : null,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  try {
                    await FirebaseFirestore.instance
                        .collection('reviews')
                        .doc(review.id)
                        .update({
                      'itemName': itemController.text,
                      'rating': rating,
                      'comment': commentController.text,
                    });
                    if (context.mounted) {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Review updated successfully')),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Error: ${e.toString()}')),
                      );
                    }
                  }
                }
              },
              child: const Text('Update'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteReview(
    BuildContext context, 
    WidgetRef ref, 
    String reviewId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await FirebaseFirestore.instance
            .collection('reviews')
            .doc(reviewId)
            .delete();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Review deleted successfully')),
          );
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: ${e.toString()}')),
          );
        }
      }
    }
  }
}

class _ReviewCard extends StatelessWidget {
  final Review review;
  final VoidCallback onDelete;
  final VoidCallback onEdit;

  const _ReviewCard({
    required this.review,
    required this.onDelete,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  review.itemName,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  review.formattedDate,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  review.starRating,
                  style: TextStyle(
                    color: Colors.amber,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  review.rating.toStringAsFixed(1),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              review.comment,
              style: theme.textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: onEdit,
                  child: const Text('Edit'),
                ),
                const SizedBox(width: 8),
                TextButton(
                  onPressed: onDelete,
                  style: TextButton.styleFrom(
                    foregroundColor: colorScheme.error,
                  ),
                  child: const Text('Delete'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}