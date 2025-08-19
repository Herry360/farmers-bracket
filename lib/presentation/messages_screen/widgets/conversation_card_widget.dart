import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

import '../../../core/app_export.dart';

class ConversationCardWidget extends StatelessWidget {
  final Map<String, dynamic> conversation;
  final VoidCallback? onTap;
  final VoidCallback? onMarkRead;
  final VoidCallback? onDelete;
  final VoidCallback? onBlock;

  const ConversationCardWidget({
    super.key,
    required this.conversation,
    this.onTap,
    this.onMarkRead,
    this.onDelete,
    this.onBlock,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bool isUnread = (conversation["unreadCount"] as int? ?? 0) > 0;
    final bool isOnline = conversation["isOnline"] as bool? ?? false;
    final String lastMessage = conversation["lastMessage"] as String? ?? "";
    final String timestamp = conversation["timestamp"] as String? ?? "";
    final int unreadCount = conversation["unreadCount"] as int? ?? 0;
    final String orderContext = conversation["orderContext"] as String? ?? "";

    return Dismissible(
      key: Key(conversation["id"].toString()),
      direction: DismissDirection.startToEnd,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: EdgeInsets.symmetric(horizontal: 4.w),
        decoration: BoxDecoration(
          color: AppTheme.lightTheme.colorScheme.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            CustomIconWidget(
              iconName: 'mark_email_read',
              color: AppTheme.lightTheme.colorScheme.primary,
              size: 24,
            ),
            SizedBox(width: 2.w),
            Text(
              'Mark Read',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppTheme.lightTheme.colorScheme.primary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
      onDismissed: (direction) {
        if (onMarkRead != null) onMarkRead!();
      },
      child: InkWell(
        onTap: onTap,
        onLongPress: () => _showContextMenu(context),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 4.w, vertical: 1.h),
          padding: EdgeInsets.all(3.w),
          decoration: BoxDecoration(
            color: isUnread
                ? colorScheme.primary.withValues(alpha: 0.05)
                : colorScheme.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isUnread
                  ? colorScheme.primary.withValues(alpha: 0.2)
                  : colorScheme.outline.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            children: [
              // Profile Image with Online Status
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(25),
                    child: CustomImageWidget(
                      imageUrl: conversation["avatar"] as String? ?? "",
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                  ),
                  if (isOnline)
                    Positioned(
                      bottom: 2,
                      right: 2,
                      child: Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: AppTheme.successColor,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: colorScheme.surface,
                            width: 2,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(width: 3.w),

              // Message Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name and Timestamp Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            conversation["name"] as String? ?? "Unknown",
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight:
                                  isUnread ? FontWeight.w600 : FontWeight.w500,
                              color: colorScheme.onSurface,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          timestamp,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: isUnread
                                ? colorScheme.primary
                                : colorScheme.onSurfaceVariant,
                            fontWeight:
                                isUnread ? FontWeight.w500 : FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 0.5.h),

                    // Order Context (if available)
                    if (orderContext.isNotEmpty) ...[
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 2.w, vertical: 0.5.h),
                        decoration: BoxDecoration(
                          color: AppTheme.accentColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CustomIconWidget(
                              iconName: 'shopping_bag',
                              color: AppTheme.accentColor,
                              size: 12,
                            ),
                            SizedBox(width: 1.w),
                            Text(
                              orderContext,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: AppTheme.accentColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 0.5.h),
                    ],

                    // Last Message and Unread Count Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            lastMessage,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: isUnread
                                  ? colorScheme.onSurface
                                  : colorScheme.onSurfaceVariant,
                              fontWeight:
                                  isUnread ? FontWeight.w500 : FontWeight.w400,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (unreadCount > 0) ...[
                          SizedBox(width: 2.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                                horizontal: 2.w, vertical: 0.5.h),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            constraints: BoxConstraints(
                              minWidth: 20,
                              minHeight: 20,
                            ),
                            child: Text(
                              unreadCount > 99 ? '99+' : unreadCount.toString(),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: colorScheme.onPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 10.sp,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showContextMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: EdgeInsets.all(4.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12.w,
              height: 0.5.h,
              decoration: BoxDecoration(
                color: Theme.of(context)
                    .colorScheme
                    .outline
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: 3.h),
            _buildContextMenuItem(
              context,
              icon: 'mark_email_read',
              title: 'Mark as Read',
              onTap: () {
                Navigator.pop(context);
                if (onMarkRead != null) onMarkRead!();
              },
            ),
            _buildContextMenuItem(
              context,
              icon: 'delete_outline',
              title: 'Delete Conversation',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                if (onDelete != null) onDelete!();
              },
            ),
            _buildContextMenuItem(
              context,
              icon: 'block',
              title: 'Block User',
              isDestructive: true,
              onTap: () {
                Navigator.pop(context);
                if (onBlock != null) onBlock!();
              },
            ),
            SizedBox(height: 2.h),
          ],
        ),
      ),
    );
  }

  Widget _buildContextMenuItem(
    BuildContext context, {
    required String icon,
    required String title,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 3.h),
        child: Row(
          children: [
            CustomIconWidget(
              iconName: icon,
              color: isDestructive ? colorScheme.error : colorScheme.onSurface,
              size: 24,
            ),
            SizedBox(width: 4.w),
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                color:
                    isDestructive ? colorScheme.error : colorScheme.onSurface,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
