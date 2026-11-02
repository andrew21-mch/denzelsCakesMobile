import 'package:flutter/material.dart';
import 'package:denzels_cakes/l10n/app_localizations.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../data/auth_repository.dart';
import '../../../../core/services/api_service.dart';
import '../widgets/auth_page.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(); // For email or phone
  final _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;

    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isLoading = true;
    });

    try {
      // Call real authentication API with identifier (email or phone)
      final authResponse = await AuthRepository.login(
        identifier: _identifierController.text.trim(),
        password: _passwordController.text,
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
          SnackBar(
            content: Text(l10n.loginSuccessful),
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
        // Show error message
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
      loadingMessage: l10n.signingYouIn,
      logoLabel: l10n.denzelsCakeShop,
      title: l10n.signIn,
      subtitle: l10n.continueTo(l10n.denzelsCakeShop),
      primaryLabel: l10n.signIn,
      onPrimary: _handleLogin,
      secondaryLabel: l10n.createAccount,
      onSecondary: () => Navigator.of(context).pushNamed('/register'),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextFormField(
              controller: _identifierController,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              decoration: InputDecoration(
                labelText: l10n.emailOrPhone,
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return l10n.enterEmailOrPhone;
                }
                final isEmail = RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value);
                final isPhone = RegExp(
                  r'^(\+?[\d\s\-\(\)]{8,20})$',
                ).hasMatch(value.trim());
                if (!isEmail && !isPhone) {
                  return l10n.enterEmailOrPhone;
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              obscureText: !_isPasswordVisible,
              textInputAction: TextInputAction.done,
              onFieldSubmitted: (_) => _handleLogin(),
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
          ],
        ),
      ),
    );
  }
}
