import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../models/order.dart' as app_order;
import '../models/cart_item.dart';

class OrderCard extends StatelessWidget {
  static const _cardMargin = EdgeInsets.symmetric(horizontal: 16, vertical: 8);
  static const _cardPadding = EdgeInsets.all(16);
  static const _statusPadding = EdgeInsets.symmetric(horizontal: 12, vertical: 4);
  static const _buttonPadding = EdgeInsets.symmetric(vertical: 8);
  static const _imageSize = 40.0;
  static const _iconSize = 16.0;
  static const _productPreviewHeight = 40.0;

  final app_order.Order order;
  final VoidCallback onTap;
  final VoidCallback? onCancel;
  final VoidCallback? onTrack;
  final VoidCallback? onReorder;
  final bool showStatus;
  final bool showActions;
  final bool showProductPreview;
  final DateFormat _dateFormat = DateFormat('MMM dd, yyyy');
  final DateFormat _timeFormat = DateFormat('hh:mm a');

  OrderCard({
    super.key,
    required this.order,
    required this.onTap,
    this.onCancel,
    this.onTrack,
    this.onReorder,
    this.showStatus = true,
    this.showActions = true,
    this.showProductPreview = true,
  });

  bool get _canCancel {
    return onCancel != null && 
           (order.status == app_order.OrderStatus.processing || 
            order.status == app_order.OrderStatus.shipped);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final statusColor = _getStatusColor(order.status);

    return Card(
      margin: _cardMargin,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDarkMode 
              ? theme.colorScheme.outlineVariant 
              : theme.colorScheme.outline,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Padding(
          padding: _cardPadding,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, statusColor),
              const SizedBox(height: 12),
              _buildOrderDate(context),
              const SizedBox(height: 8),
              _buildItemCount(context),
              if (showProductPreview) ...[
                const SizedBox(height: 8),
                if (order.items.isNotEmpty)
                  _buildProductPreview(context, order.items.first as CartItem),
                const SizedBox(height: 12),
              ],
              _buildTotalAmount(context),
              if (showActions && (onCancel != null || onTrack != null || onReorder != null)) ...[
                const SizedBox(height: 8),
                _buildActionButtons(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Color statusColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Order #${order.id.substring(0, 8)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        if (showStatus)
          Container(
            padding: _statusPadding,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              order.status.value.toUpperCase(),
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildOrderDate(BuildContext context) {
    return _buildInfoRow(
      icon: Icons.calendar_today_outlined,
      text: '${_dateFormat.format(order.date)} • ${_timeFormat.format(order.date)}',
      context: context,
    );
  }

  Widget _buildItemCount(BuildContext context) {
    return _buildInfoRow(
      icon: Icons.shopping_bag_outlined,
      text: '${order.items.length} ${order.items.length == 1 ? 'item' : 'items'}',
      context: context,
    );
  }

  Widget _buildTotalAmount(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Total', style: Theme.of(context).textTheme.bodyMedium),
        Text(
          'R${order.totalAmount.toStringAsFixed(2)}',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    required BuildContext context,
  }) {
    return Row(
      children: [
        Icon(icon, size: _iconSize, color: Theme.of(context).textTheme.bodySmall?.color),
        const SizedBox(width: 8),
        Text(text, style: Theme.of(context).textTheme.bodySmall),
      ],
    );
  }

  Widget _buildProductPreview(BuildContext context, CartItem item) {
    return SizedBox(
      height: _productPreviewHeight,
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: item.product.imageUrl,
              width: _imageSize,
              height: _imageSize,
              fit: BoxFit.cover,
              placeholder: (context, url) => _buildImagePlaceholder(context),
              errorWidget: (context, url, error) => _buildImageError(context),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.product.title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${item.quantity} × R${item.product.price.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurface.withAlpha(154),
                  ),
                ),
              ],
            ),
          ),
          if (order.items.length > 1)
            Text(
              '+${order.items.length - 1} more',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(154),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildImagePlaceholder(BuildContext context) {
    return Container(
      width: _imageSize,
      height: _imageSize,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
    );
  }

  Widget _buildImageError(BuildContext context) {
    return Container(
      width: _imageSize,
      height: _imageSize,
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Icon(
        Icons.shopping_bag,
        size: 20,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        if (onReorder != null)
          _buildReorderButton(context),
        if (_canCancel)
          _buildCancelButton(context),
        if (onTrack != null && order.status == app_order.OrderStatus.shipped)
          _buildTrackButton(context),
      ],
    );
  }

  Widget _buildReorderButton(BuildContext context) {
    return Expanded(
      child: OutlinedButton(
        onPressed: onReorder,
        style: OutlinedButton.styleFrom(
          padding: _buttonPadding,
          side: BorderSide(color: Theme.of(context).colorScheme.primary),
        ),
        child: Text(
          'Reorder',
          style: TextStyle(color: Theme.of(context).colorScheme.primary),
        ),
      ),
    );
  }

  Widget _buildCancelButton(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: OutlinedButton(
          onPressed: onCancel,
          style: OutlinedButton.styleFrom(
            padding: _buttonPadding,
            side: BorderSide(color: Theme.of(context).colorScheme.error),
          ),
          child: Text(
            'Cancel',
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ),
      ),
    );
  }

  Widget _buildTrackButton(BuildContext context) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.only(left: 8),
        child: ElevatedButton(
          onPressed: onTrack,
          style: ElevatedButton.styleFrom(padding: _buttonPadding),
          child: const Text('Track'),
        ),
      ),
    );
  }

  Color _getStatusColor(app_order.OrderStatus status) {
    switch (status) {
      case app_order.OrderStatus.delivered:
        return Colors.green;
      case app_order.OrderStatus.shipped:
        return Colors.blue;
      case app_order.OrderStatus.processing:
        return Colors.orange;
      case app_order.OrderStatus.cancelled:
        return Colors.red;
      case app_order.OrderStatus.returned:
        return Colors.purple;
    }
  }
}