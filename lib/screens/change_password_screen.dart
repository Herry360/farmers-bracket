import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Provider for change password state
final changePasswordProvider = StateNotifierProvider<ChangePasswordNotifier, ChangePasswordState>((ref) {
  return ChangePasswordNotifier();
});

class ChangePasswordNotifier extends StateNotifier<ChangePasswordState> {
  ChangePasswordNotifier() : super(ChangePasswordState());

  void updateCurrentPassword(String value) {
    state = state.copyWith(currentPassword: value);
  }

  void updateNewPassword(String value) {
    state = state.copyWith(newPassword: value);
  }

  void updateConfirmPassword(String value) {
    state = state.copyWith(confirmPassword: value);
  }

  Future<void> submit() async {
    if (!_validate()) return;

    state = state.copyWith(isLoading: true, errorMessage: '');
    
    try {
      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));
      
      // In a real app, you would call your authentication service here
      // For example:
      // await authService.changePassword(
      //   currentPassword: state.currentPassword,
      //   newPassword: state.newPassword,
      // );
      
      state = state.copyWith(
        isLoading: false,
        isSuccess: true,
        errorMessage: '',
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        isSuccess: false,
        errorMessage: 'Failed to change password. Please try again.',
      );
    }
  }

  bool _validate() {
    if (state.currentPassword.isEmpty) {
      state = state.copyWith(errorMessage: 'Current password is required');
      return false;
    }
    
    if (state.newPassword.isEmpty) {
      state = state.copyWith(errorMessage: 'New password is required');
      return false;
    }
    
    if (state.newPassword.length < 6) {
      state = state.copyWith(
        errorMessage: 'Password must be at least 6 characters',
      );
      return false;
    }
    
    if (state.newPassword != state.confirmPassword) {
      state = state.copyWith(
        errorMessage: 'New passwords do not match',
      );
      return false;
    }
    
    state = state.copyWith(errorMessage: '');
    return true;
  }

  void resetState() {
    state = ChangePasswordState();
  }
}

class ChangePasswordState {
  final String currentPassword;
  final String newPassword;
  final String confirmPassword;
  final bool isLoading;
  final bool isSuccess;
  final String errorMessage;

  ChangePasswordState({
    this.currentPassword = '',
    this.newPassword = '',
    this.confirmPassword = '',
    this.isLoading = false,
    this.isSuccess = false,
    this.errorMessage = '',
  });

  ChangePasswordState copyWith({
    String? currentPassword,
    String? newPassword,
    String? confirmPassword,
    bool? isLoading,
    bool? isSuccess,
    String? errorMessage,
  }) {
    return ChangePasswordState(
      currentPassword: currentPassword ?? this.currentPassword,
      newPassword: newPassword ?? this.newPassword,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      isLoading: isLoading ?? this.isLoading,
      isSuccess: isSuccess ?? this.isSuccess,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }
}

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(changePasswordProvider);
    final notifier = ref.read(changePasswordProvider.notifier);
    final theme = Theme.of(context);

    if (state.isSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showSuccessDialog(notifier);
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Change Password'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildCurrentPasswordField(notifier, state),
              const SizedBox(height: 16),
              _buildNewPasswordField(notifier, state),
              const SizedBox(height: 16),
              _buildConfirmPasswordField(notifier, state),
              const SizedBox(height: 24),
              if (state.errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: Text(
                    state.errorMessage,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.error,
                    ),
                  ),
                ),
              ElevatedButton(
                onPressed: state.isLoading ? null : () => _submitForm(notifier),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: state.isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Change Password'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentPasswordField(ChangePasswordNotifier notifier, ChangePasswordState state) {
    return TextFormField(
      obscureText: _obscureCurrentPassword,
      decoration: InputDecoration(
        labelText: 'Current Password',
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureCurrentPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() => _obscureCurrentPassword = !_obscureCurrentPassword);
          },
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter your current password';
        }
        return null;
      },
      onChanged: notifier.updateCurrentPassword,
    );
  }

  Widget _buildNewPasswordField(ChangePasswordNotifier notifier, ChangePasswordState state) {
    return TextFormField(
      obscureText: _obscureNewPassword,
      decoration: InputDecoration(
        labelText: 'New Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureNewPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() => _obscureNewPassword = !_obscureNewPassword);
          },
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please enter a new password';
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters';
        }
        return null;
      },
      onChanged: notifier.updateNewPassword,
    );
  }

  Widget _buildConfirmPasswordField(ChangePasswordNotifier notifier, ChangePasswordState state) {
    return TextFormField(
      obscureText: _obscureConfirmPassword,
      decoration: InputDecoration(
        labelText: 'Confirm New Password',
        prefixIcon: const Icon(Icons.lock_outline),
        suffixIcon: IconButton(
          icon: Icon(
            _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
          ),
          onPressed: () {
            setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
          },
        ),
        border: const OutlineInputBorder(),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Please confirm your new password';
        }
        if (value != state.newPassword) {
          return 'Passwords do not match';
        }
        return null;
      },
      onChanged: notifier.updateConfirmPassword,
    );
  }

  Future<void> _submitForm(ChangePasswordNotifier notifier) async {
    if (_formKey.currentState?.validate() ?? false) {
      await notifier.submit();
    }
  }

  void _showSuccessDialog(ChangePasswordNotifier notifier) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Password Changed'),
        content: const Text('Your password has been changed successfully.'),
        actions: [
          TextButton(
            onPressed: () {
              notifier.resetState();
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Return to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}