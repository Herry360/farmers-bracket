import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

enum CustomAppBarVariant {
  standard,
  search,
  profile,
  back,
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final CustomAppBarVariant variant;
  final List<Widget>? actions;
  final VoidCallback? onSearchTap;
  final VoidCallback? onProfileTap;
  final VoidCallback? onBackPressed;
  final bool showNotificationBadge;
  final String? searchHint;
  final TextEditingController? searchController;
  final ValueChanged<String>? onSearchChanged;
  final bool isSearchActive;

  const CustomAppBar({
    super.key,
    this.title,
    this.variant = CustomAppBarVariant.standard,
    this.actions,
    this.onSearchTap,
    this.onProfileTap,
    this.onBackPressed,
    this.showNotificationBadge = false,
    this.searchHint = 'Search fresh produce...',
    this.searchController,
    this.onSearchChanged,
    this.isSearchActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    switch (variant) {
      case CustomAppBarVariant.search:
        return _buildSearchAppBar(context, theme, colorScheme);
      case CustomAppBarVariant.profile:
        return _buildProfileAppBar(context, theme, colorScheme);
      case CustomAppBarVariant.back:
        return _buildBackAppBar(context, theme, colorScheme);
      case CustomAppBarVariant.standard:
  return _buildStandardAppBar(context, theme, colorScheme);
    }
  }

  Widget _buildStandardAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 2.0,
      surfaceTintColor: Colors.transparent,
      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            )
          : null,
      leading: IconButton(
        icon: Icon(Icons.menu, color: colorScheme.onSurface),
        onPressed: () => Scaffold.of(context).openDrawer(),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: colorScheme.onSurface),
          onPressed: onSearchTap ??
              () => Navigator.pushNamed(context, '/product-listing-screen'),
        ),
        Stack(
          children: [
            IconButton(
              icon: Icon(Icons.shopping_cart_outlined,
                  color: colorScheme.onSurface),
              onPressed: () =>
                  Navigator.pushNamed(context, '/shopping-cart-screen'),
            ),
            if (showNotificationBadge)
              Positioned(
                right: 8,
                top: 8,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    color: colorScheme.error,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 12,
                    minHeight: 12,
                  ),
                ),
              ),
          ],
        ),
        ...?actions,
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 2.0,
      surfaceTintColor: Colors.transparent,
      title: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Container(
          height: 40,
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: colorScheme.outline),
          ),
          child: TextField(
            controller: searchController,
            onChanged: onSearchChanged,
            style: GoogleFonts.inter(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintText: searchHint,
              hintStyle: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: colorScheme.onSurfaceVariant,
              ),
              prefixIcon: Icon(
                Icons.search,
                color: colorScheme.onSurfaceVariant,
                size: 20,
              ),
              suffixIcon: isSearchActive
                  ? IconButton(
                      icon: Icon(
                        Icons.clear,
                        color: colorScheme.onSurfaceVariant,
                        size: 20,
                      ),
                      onPressed: () {
                        searchController?.clear();
                        onSearchChanged?.call('');
                      },
                    )
                  : null,
              border: InputBorder.none,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),
          ),
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.tune, color: colorScheme.onSurface),
          onPressed: () {
            // Show filter bottom sheet
            showModalBottomSheet(
              context: context,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              builder: (context) => Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Filter Products',
                      style: GoogleFonts.inter(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Filter options would go here
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Apply Filters'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildProfileAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 2.0,
      surfaceTintColor: Colors.transparent,
      title: Text(
        title ?? 'Profile',
        style: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurface,
        ),
      ),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.edit, color: colorScheme.onSurface),
          onPressed: onProfileTap,
        ),
        IconButton(
          icon: Icon(Icons.more_vert, color: colorScheme.onSurface),
          onPressed: () {
            // Show profile options menu
          },
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildBackAppBar(
      BuildContext context, ThemeData theme, ColorScheme colorScheme) {
    return AppBar(
      backgroundColor: colorScheme.surface,
      foregroundColor: colorScheme.onSurface,
      elevation: 2.0,
      surfaceTintColor: Colors.transparent,
      title: title != null
          ? Text(
              title!,
              style: GoogleFonts.inter(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                color: colorScheme.onSurface,
              ),
            )
          : null,
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: colorScheme.onSurface),
        onPressed: onBackPressed ?? () => Navigator.pop(context),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
