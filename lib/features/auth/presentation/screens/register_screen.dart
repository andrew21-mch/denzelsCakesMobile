import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../data/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call real authentication API
      final authResponse = await AuthRepository.register(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        phone: _phoneController.text.trim().isEmpty ? null : _phoneController.text.trim(),
      );

      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Check user role and navigate accordingly
        if (authResponse.user.role == 'admin') {
          // Navigate to admin dashboard for admin users
          Navigator.of(context).pushReplacementNamed('/admin');
        } else {
          // Navigate to home for regular users
          Navigator.of(context).pushReplacementNamed('/home');
        }

        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registration successful!'),
            backgroundColor: AppTheme.successColor,
            duration: Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              children: [
                  const SizedBox(height: 16),

                  // Header with back button
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.8),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.arrow_back_ios_new,
                            color: AppTheme.textPrimary,
                            size: 18,
                          ),
                        ),
                      ),
                      const Spacer(),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // Logo and Title Section
                  Column(
                    children: [
                      // Logo with shadow and animation effect
                      Container(
                        width: 100,
                        height: 100,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          boxShadow: const [
                            BoxShadow(
                              color: AppTheme.shadowColor,
                              blurRadius: 20,
                              offset: Offset(0, 10),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.all(8),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset(
                            'assets/images/logo.jpeg',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: BoxDecoration(
                                  gradient: AppTheme.primaryGradient,
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: const Icon(
                                  Icons.cake,
                                  size: 50,
                                  color: Colors.white,
                                ),
                              );
                            },
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Welcome text
                      ShaderMask(
                        shaderCallback: (bounds) =>
                            AppTheme.primaryGradient.createShader(bounds),
                        child: Text(
                          'Join Denzel\'s Cakes',
                          style: Theme.of(context)
                              .textTheme
                              .headlineLarge
                              ?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1.2,
                              ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),

                  // Compact form
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Create Account Title
                          Text(
                            'Create Account',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),

                          const SizedBox(height: 20),

                          // Name Field
                          SizedBox(
                            height: 48,
                            child: TextFormField(
                              controller: _nameController,
                              decoration: const InputDecoration(
                                labelText: 'Full Name',
                                prefixIcon: Icon(Icons.person, size: 20),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter your name';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Email Field
                          SizedBox(
                            height: 48,
                            child: TextFormField(
                              controller: _emailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email',
                                prefixIcon: Icon(Icons.email, size: 20),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if ((value == null || value.isEmpty) && _phoneController.text.isEmpty) {
                                  return 'Enter email or phone';
                                }
                                if (value != null && value.isNotEmpty) {
                                  if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                                    return 'Enter valid email';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Phone Field
                          SizedBox(
                            height: 48,
                            child: TextFormField(
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(
                                labelText: 'Phone (Optional)',
                                prefixIcon: Icon(Icons.phone, size: 20),
                                contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value != null && value.isNotEmpty) {
                                  String cleanPhone = value.replaceAll(' ', '');
                                  if (!RegExp(r'^(\+?237|6)\d{8}$').hasMatch(cleanPhone)) {
                                    return 'Enter valid Cameroon number';
                                  }
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Password Field
                          SizedBox(
                            height: 48,
                            child: TextFormField(
                              controller: _passwordController,
                              obscureText: !_isPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Password',
                                prefixIcon: const Icon(Icons.lock, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please enter password';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 12),

                          // Confirm Password Field
                          SizedBox(
                            height: 48,
                            child: TextFormField(
                              controller: _confirmPasswordController,
                              obscureText: !_isConfirmPasswordVisible,
                              decoration: InputDecoration(
                                labelText: 'Confirm Password',
                                prefixIcon: const Icon(Icons.lock_outline, size: 20),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _isConfirmPasswordVisible ? Icons.visibility_off : Icons.visibility,
                                    size: 20,
                                  ),
                                  onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                                ),
                                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                border: const OutlineInputBorder(),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please confirm password';
                                }
                                if (value != _passwordController.text) {
                                  return 'Passwords do not match';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Register Button
                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleRegister,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                      ),
                                    )
                                  : const Text(
                                      'Create Account',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Login link
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Navigator.of(context).pushReplacementNamed('/login'),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            child: const Text(
                              'Sign In',
                              style: TextStyle(
                                color: AppTheme.primaryColor,
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
            ),
          ),
        ),
      ),
    );
  }
}
