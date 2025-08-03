import 'dart:async';
import 'package:flutter/material.dart';

class FarmSearchBar extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final String initialValue;
  final VoidCallback? onSubmitted;
  final Duration debounceDuration;
  final String? hintText;
  final bool autofocus;

  const FarmSearchBar({
    super.key,
    required this.onChanged,
    this.initialValue = '',
    this.onSubmitted,
    this.debounceDuration = const Duration(milliseconds: 300),
    this.hintText = 'Search farms...',
    this.autofocus = false,
  });

  @override
  State<FarmSearchBar> createState() => _FarmSearchBarState();
}

class _FarmSearchBarState extends State<FarmSearchBar> {
  late final TextEditingController _controller;
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
  }

  @override
  void didUpdateWidget(FarmSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue;
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
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    
    return TextField(
      controller: _controller,
      onChanged: _onSearchChanged,
      onSubmitted: (_) => widget.onSubmitted?.call(),
      autofocus: widget.autofocus,
      decoration: InputDecoration(
        hintText: widget.hintText,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: _clearSearch,
                splashRadius: 20,
              )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: colorScheme.surfaceContainerHighest.withAlpha(128),
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        isDense: true,
        constraints: const BoxConstraints(minHeight: 48),
      ),
      textInputAction: TextInputAction.search,
      style: theme.textTheme.bodyMedium,
    );
  }
}