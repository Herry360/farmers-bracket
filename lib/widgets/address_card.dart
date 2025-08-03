import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddressCard extends StatefulWidget {
  final String? userId;
  final VoidCallback? onEditPressed;

  const AddressCard({
    super.key,
    this.userId,
    this.onEditPressed,
  });

  @override
  State<AddressCard> createState() => _AddressCardState();
}

class _AddressCardState extends State<AddressCard> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  Map<String, dynamic>? _address;
  bool _isLoading = true;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    _fetchAddress();
  }

  Future<void> _fetchAddress() async {
    if (widget.userId == null) return;

    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final doc = await _firestore
          .collection('addresses')
          .doc(widget.userId!)
          .get();

      if (doc.exists) {
        setState(() {
          _address = doc.data();
        });
      } else {
        setState(() {
          _address = null;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error fetching address: ${e.toString()}')),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                  if (_address?['full_name'] != null) Text(_address!['full_name']),
                  if (_address?['street_address'] != null) Text(_address!['street_address']),
                  if (_address?['apartment'] != null) Text(_address!['apartment']!),
                  if (_address?['city'] != null && _address?['postal_code'] != null)
                    Text('${_address!['city']}, ${_address!['postal_code']}'),
                  if (_address?['country'] != null) Text(_address!['country']!),
                  const SizedBox(height: 8),
                  if (_address?['phone_number'] != null)
                    Text('Phone: ${_address!['phone_number']}'),
                ],
              ),
          ],
        ),
      ),
    );
  }
}