import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../data/auth_repository.dart';
import '../../../../core/services/api_service.dart';
import '../widgets/auth_page.dart';
import 'package:denzels_cakes/l10n/app_localizations.dart';

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
  bool _autovalidate = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _revalidateContact() {
    if (_autovalidate) {
      _formKey.currentState?.validate();
    }
  }

  String? _validateEmail(String? value, AppLocalizations l10n) {
    final email = value?.trim() ?? '';
    final phone = _phoneController.text.trim();
    if (email.isEmpty && phone.isEmpty) {
      return l10n.enterEmailOrPhone;
    }
    if (email.isEmpty) return null;
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return l10n.pleaseEnterValidEmail;
    }
    return null;
  }

  String? _validatePhone(String? value, AppLocalizations l10n) {
    final phone = value?.trim() ?? '';
    final email = _emailController.text.trim();
    if (phone.isEmpty && email.isEmpty) {
      return l10n.enterEmailOrPhone;
    }
    if (phone.isEmpty) return null;
    if (!RegExp(r'^(\+?[\d\s\-\(\)]{8,20})$').hasMatch(phone)) {
      return l10n.pleaseEnterValidPhoneNumber;
    }
    return null;
  }

  Future<void> _handleRegister() async {
    setState(() => _autovalidate = true);
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call real authentication API with either email or phone
      final email = _emailController.text.trim();
      final phone = _phoneController.text.trim();
      final authResponse = await AuthRepository.register(
        name: _nameController.text.trim(),
        email: email.isEmpty ? null : email,
        password: _passwordController.text,
        phone: phone.isEmpty ? null : phone,
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
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.registrationSuccessful),
            backgroundColor: AppTheme.successColor,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(ApiService.readableError(e)),
            backgroundColor: AppTheme.errorColor,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AuthPage(
      isLoading: _isLoading,
      loadingMessage: l10n.creatingYourAccount,
      logoLabel: l10n.denzelsCakeShop,
      title: l10n.createAccount,
      subtitle: l10n.continueTo(l10n.denzelsCakeShop),
      primaryLabel: l10n.createAccount,
      onPrimary: _handleRegister,
      secondaryLabel: l10n.signIn,
      onSecondary: () {
        if (Navigator.of(context).canPop()) {
          Navigator.of(context).pop();
        } else {
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
      child: Form(
        key: _formKey,
        autovalidateMode: _autovalidate
            ? AutovalidateMode.always
            : AutovalidateMode.disabled,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _nameController,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              decoration: InputDecoration(
                labelText: l10n.fullName,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterYourName;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _revalidateContact(),
              decoration: InputDecoration(
                labelText: l10n.emailAddress,
              ),
              validator: (value) => _validateEmail(value, l10n),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              textInputAction: TextInputAction.next,
              onChanged: (_) => _revalidateContact(),
              decoration: InputDecoration(
                labelText: l10n.phoneNumber,
              ),
              validator: (value) => _validatePhone(value, l10n),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.password,
                suffixIcon: IconButton(
                  onPressed: () => setState(
                    () => _isPasswordVisible = !_isPasswordVisible,
                  ),
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterPassword;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              obscureText: !_isConfirmPasswordVisible,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleRegister(),
              decoration: InputDecoration(
                labelText: l10n.confirmPassword,
                suffixIcon: IconButton(
                  onPressed: () => setState(
                    () =>
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible,
                  ),
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility_off
                        : Icons.visibility,
                  ),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.pleaseEnterPassword;
                }
                if (value != _passwordController.text) {
                  return l10n.passwordsDoNotMatch;
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }
}
