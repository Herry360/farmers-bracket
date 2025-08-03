import 'package:flutter/material.dart';
import 'dart:async';

class ProductSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final String? initialValue;
  final Duration debounceDuration;
  final bool autofocus;
  final String? hintText;

  const ProductSearchBar({
    super.key,
    required this.onChanged,
    this.onClear,
    this.initialValue,
    this.debounceDuration = const Duration(milliseconds: 500),
    this.autofocus = false,
    this.hintText,
  });

  @override
  State<ProductSearchBar> createState() => _ProductSearchBarState();
}

class _ProductSearchBarState extends State<ProductSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(ProductSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceDuration, () {
      widget.onChanged(value);
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onChanged('');
    widget.onClear?.call();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: TextField(
        controller: _controller,
        autofocus: widget.autofocus,
        decoration: InputDecoration(
          hintText: widget.hintText ?? 'Search products...',
          prefixIcon: const Icon(Icons.search, size: 24),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: _clearSearch,
                  splashRadius: 20,
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.outline,
              width: 1.0,
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.outline.withOpacity(0.5),
              width: 1.0,
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 2.0,
            ),
          ),
          filled: true,
          fillColor: colorScheme.surfaceContainerHighest.withOpacity(0.7),
          contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          isDense: true,
          constraints: const BoxConstraints(minHeight: 56),
        ),
        onChanged: (value) {
          _onSearchChanged(value);
          setState(() {});
        },
        onSubmitted: (_) => _onSearchChanged(_controller.text),
        style: theme.textTheme.bodyLarge,
        cursorColor: colorScheme.primary,
        textInputAction: TextInputAction.search,
      ),
    );
  }
}