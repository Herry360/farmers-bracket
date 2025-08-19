import 'package:flutter/material.dart';

class AddressCard extends StatefulWidget {
  final VoidCallback? onEditPressed;
  final Map<String, dynamic>? initialAddress;

  const AddressCard({
    super.key,
    this.onEditPressed,
    this.initialAddress,
  });

  @override
  State<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  Map<String, dynamic>? _address;
  bool _isLoading = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _address = widget.initialAddress;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
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
                  'Delivery Address',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton(
                  onPressed: widget.onEditPressed,
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(50, 30),
                  ),
                  child: Text(
                    'Change',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            
            if (_isLoading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16),
                child: Center(child: CircularProgressIndicator()),
              )
            else if (_hasError)
              Text(
                'Failed to load address',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              )
            else if (_address == null)
              Text(
                'No address saved',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                ),
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_address?['full_name'] != null) 
                    Text(_address!['full_name'], style: theme.textTheme.bodyLarge),
                  const SizedBox(height: 4),
                  if (_address?['street_address'] != null) 
                    Text(_address!['street_address'], style: theme.textTheme.bodyMedium),
                  if (_address?['apartment'] != null) 
                    Text(_address!['apartment']!, style: theme.textTheme.bodyMedium),
                  if (_address?['city'] != null && _address?['postal_code'] != null)
                    Text('${_address!['city']}, ${_address!['postal_code']}', 
                         style: theme.textTheme.bodyMedium),
                  if (_address?['country'] != null) 
                    Text(_address!['country']!, style: theme.textTheme.bodyMedium),
                  const SizedBox(height: 8),
                  if (_address?['phone_number'] != null)
                    Text('Phone: ${_address!['phone_number']}', 
                         style: theme.textTheme.bodyMedium),
                ],
              ),
          ],
        ),
      ),
    );
  }
}