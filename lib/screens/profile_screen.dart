import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _firstNameController = TextEditingController(text: 'Collen');
  final TextEditingController _lastNameController = TextEditingController(text: 'Siyabonga');
  final TextEditingController _emailController = TextEditingController(text: 'collen@example.com');
  final TextEditingController _phoneController = TextEditingController(text: '081 234 5678');
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final TextEditingController _homeAddressController = TextEditingController();
  final TextEditingController _businessAddressController = TextEditingController();
  final TextEditingController _preferredNameController = TextEditingController();
  final TextEditingController _emergencyContactController = TextEditingController();
  final TextEditingController _loyaltyNumberController = TextEditingController();
  
  File? _profileImage;
  bool _isLoading = false;
  bool _isEditing = false;
  DateTime? _selectedDob;
  String? _selectedGender;

  final List<String> _genders = ['Male', 'Female', 'Other', 'Prefer not to say'];

  Future<void> _pickImage() async {
    final pickedImage = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _profileImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDob) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      // Simulate API call
      await Future.delayed(const Duration(seconds: 2));
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile saved successfully')),
        );
        setState(() {
          _isEditing = false;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
          if (_isEditing)
            TextButton(
              onPressed: _isLoading ? null : () => setState(() => _isEditing = false),
              child: const Text('Cancel', style: TextStyle(color: Colors.white)),
            ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Profile Picture Section
            Center(
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: _profileImage != null
                        ? FileImage(_profileImage!)
                        : const AssetImage('assets/images/default_profile.png') as ImageProvider,
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.blue,
                          ),
                          child: const Icon(Icons.camera_alt, size: 24, color: Colors.white),
                        ),
                      ),
                    )
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Personal Information Section
            const Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildEditableField(
                    label: 'First Name',
                    controller: _firstNameController,
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter first name' : null,
                    isEditing: _isEditing,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildEditableField(
                    label: 'Last Name',
                    controller: _lastNameController,
                    validator: (value) => value?.isEmpty ?? true ? 'Please enter last name' : null,
                    isEditing: _isEditing,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            _buildEditableField(
              label: 'Preferred Name (Optional)',
              controller: _preferredNameController,
              isEditing: _isEditing,
            ),
            const SizedBox(height: 12),
            
            _buildEditableField(
              label: 'Email Address',
              controller: _emailController,
              validator: (value) {
                if (value?.isEmpty ?? true) return 'Please enter your email';
                if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value!)) {
                  return 'Please enter a valid email';
                }
                return null;
              },
              isEditing: _isEditing,
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            
            _buildEditableField(
              label: 'Phone Number',
              controller: _phoneController,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter your phone number' : null,
              isEditing: _isEditing,
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            
            if (_isEditing)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Date of Birth', style: TextStyle(color: Colors.grey)),
                  InkWell(
                    onTap: () => _selectDate(context),
                    child: IgnorePointer(
                      child: TextFormField(
                        controller: _dobController,
                        decoration: const InputDecoration(
                          suffixIcon: Icon(Icons.calendar_today),
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) => value?.isEmpty ?? true ? 'Please select date of birth' : null,
                      ),
                    ),
                  ),
                ],
              )
            else
              ListTile(
                title: const Text('Date of Birth', style: TextStyle(color: Colors.grey)),
                subtitle: Text(_dobController.text.isEmpty ? 'Not provided' : _dobController.text),
              ),
            const SizedBox(height: 12),
            
            if (_isEditing)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Gender', style: TextStyle(color: Colors.grey)),
                  DropdownButtonFormField<String>(
                    value: _selectedGender,
                    items: _genders.map((gender) {
                      return DropdownMenuItem(
                        value: gender,
                        child: Text(gender),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedGender = value;
                        _genderController.text = value ?? '';
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                    ),
                    hint: const Text('Select Gender'),
                  ),
                ],
              )
            else
              ListTile(
                title: const Text('Gender', style: TextStyle(color: Colors.grey)),
                subtitle: Text(_genderController.text.isEmpty ? 'Not specified' : _genderController.text),
              ),
            const SizedBox(height: 24),

            // Identification Section
            const Text('Identification', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _buildEditableField(
              label: 'ID/Passport Number',
              controller: _idNumberController,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter ID number' : null,
              isEditing: _isEditing,
            ),
            const SizedBox(height: 24),

            // Address Section
            const Text('Address Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _buildEditableField(
              label: 'Home Address',
              controller: _homeAddressController,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter home address' : null,
              isEditing: _isEditing,
              maxLines: 3,
            ),
            const SizedBox(height: 12),
            
            _buildEditableField(
              label: 'Business Address (Optional)',
              controller: _businessAddressController,
              isEditing: _isEditing,
              maxLines: 3,
            ),
            const SizedBox(height: 24),

            // Emergency Contact Section
            const Text('Emergency Contact', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _buildEditableField(
              label: 'Emergency Contact Name & Number',
              controller: _emergencyContactController,
              validator: (value) => value?.isEmpty ?? true ? 'Please enter emergency contact' : null,
              isEditing: _isEditing,
            ),
            const SizedBox(height: 24),

            // Loyalty Program Section
            const Text('Loyalty Program', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            
            _buildEditableField(
              label: 'Loyalty Card Number',
              controller: _loyaltyNumberController,
              isEditing: _isEditing,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 24),
            
            // Save Button
            if (_isEditing)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text('Save Profile'),
                ),
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildEditableField({
    required String label,
    required TextEditingController controller,
    required bool isEditing,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return isEditing
        ? TextFormField(
            controller: controller,
            decoration: InputDecoration(
              labelText: label,
              border: const OutlineInputBorder(),
            ),
            validator: validator,
            keyboardType: keyboardType,
            maxLines: maxLines,
          )
        : ListTile(
            title: Text(label, style: const TextStyle(color: Colors.grey)),
            subtitle: Text(controller.text.isEmpty ? 'Not provided' : controller.text),
          );
  }
}