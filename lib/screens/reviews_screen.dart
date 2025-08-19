import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class Review {
  final String id;
  final String itemName;
  final double rating;
  final String comment;
  final DateTime date;

  Review({
    required this.id,
    required this.itemName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  String get formattedDate => DateFormat('MMM dd, yyyy').format(date);
  String get starRating => '★' * rating.floor() + '☆' * (5 - rating.floor());
}

class ReviewsScreen extends StatefulWidget {
  const ReviewsScreen({super.key});

  @override
  State<ReviewsScreen> createState() => _ReviewsScreenState();
}

class _ReviewsScreenState extends State<ReviewsScreen> {
  final List<Review> _reviews = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    // Sample data - replace with your actual data source
    setState(() {
      _reviews.addAll([
        Review(
          id: '1',
          itemName: 'Organic Apples',
          rating: 4.5,
          comment: 'Very fresh and tasty! Will buy again.',
          date: DateTime.now().subtract(const Duration(days: 2)),
        ),
        Review(
          id: '2',
          itemName: 'Farm Fresh Eggs',
          rating: 5.0,
          comment: 'The best eggs I\'ve ever had. Perfect for breakfast.',
          date: DateTime.now().subtract(const Duration(days: 5)),
        ),
        Review(
          id: '3',
          itemName: 'Homemade Bread',
          rating: 3.5,
          comment: 'Good flavor but a bit dense. Would prefer softer texture.',
          date: DateTime.now().subtract(const Duration(days: 10)),
        ),
      ]);
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
  // final colorScheme = theme.colorScheme; // Removed unused variable

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reviews'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: _showAddReviewDialog,
            tooltip: 'Add Review',
          ),
        ],
      ),
      body: _isLoading && _reviews.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : _reviews.isEmpty
              ? _buildEmptyState(theme)
              : RefreshIndicator(
                  onRefresh: _loadReviews,
                  child: ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: _reviews.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final review = _reviews[index];
                      return _ReviewCard(
                        review: review,
                        onDelete: () => _deleteReview(review.id),
                        onEdit: () => _showEditReviewDialog(review),
                      );
                    },
                  ),
                ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.reviews, size: 64, color: theme.colorScheme.outline),
          const SizedBox(height: 16),
          Text(
            'No reviews yet',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.8),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your reviews will appear here',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _showAddReviewDialog,
            child: const Text('Add Your First Review'),
          ),
        ],
      ),
    );
  }

  Future<void> _showAddReviewDialog() async {
    final result = await showModalBottomSheet<Review>(
      context: context,
      isScrollControlled: true,
      builder: (context) => const _ReviewFormSheet(),
    );

    if (result != null && mounted) {
      setState(() => _reviews.insert(0, result));
    }
  }

  Future<void> _showEditReviewDialog(Review review) async {
    final result = await showModalBottomSheet<Review>(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ReviewFormSheet(review: review),
    );

    if (result != null && mounted) {
      setState(() {
        final index = _reviews.indexWhere((r) => r.id == review.id);
        if (index != -1) {
          _reviews[index] = result;
        }
      });
    }
  }

  Future<void> _deleteReview(String reviewId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Text('Delete Review'),
        content: const Text('Are you sure you want to delete this review?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => _reviews.removeWhere((r) => r.id == reviewId));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Review deleted'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: colorScheme.outlineVariant,
          width: 1,
        ),
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

class _ReviewFormSheet extends StatefulWidget {
  final Review? review;

  const _ReviewFormSheet({this.review});

  @override
  State<_ReviewFormSheet> createState() => _ReviewFormSheetState();
}

class _ReviewFormSheetState extends State<_ReviewFormSheet> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _itemController;
  late final TextEditingController _commentController;
  late double _rating;

  @override
  void initState() {
    super.initState();
    _itemController = TextEditingController(text: widget.review?.itemName ?? '');
    _commentController = TextEditingController(text: widget.review?.comment ?? '');
    _rating = widget.review?.rating ?? 3.0;
  }

  @override
  void dispose() {
    _itemController.dispose();
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEditing = widget.review != null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: theme.colorScheme.outline.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Text(
              isEditing ? 'Edit Review' : 'Add Review',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            TextFormField(
              controller: _itemController,
              decoration: InputDecoration(
                labelText: 'Item Name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
              ),
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Text('Rating:', style: theme.textTheme.bodyMedium),
                const SizedBox(width: 16),
                Expanded(
                  child: Slider(
                    value: _rating,
                    min: 1,
                    max: 5,
                    divisions: 4,
                    label: _rating.toStringAsFixed(1),
                    onChanged: (value) => setState(() => _rating = value),
                    activeColor: Colors.amber,
                  ),
                ),
                Text(
                  _rating.toStringAsFixed(1),
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _commentController,
              decoration: InputDecoration(
                labelText: 'Comment',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: theme.colorScheme.surfaceContainerHighest.withOpacity(0.2),
              ),
              maxLines: 3,
              validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FilledButton(
                    onPressed: _submitForm,
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(isEditing ? 'Update' : 'Save'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final review = Review(
        id: widget.review?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
        itemName: _itemController.text,
        rating: _rating,
        comment: _commentController.text,
        date: widget.review?.date ?? DateTime.now(),
      );
      Navigator.pop(context, review);
    }
  }
}