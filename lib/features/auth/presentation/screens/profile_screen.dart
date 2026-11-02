import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/loading_overlay.dart';
import '../../../../core/models/user_model.dart';
import '../../../../core/services/api_service.dart';
import '../../../orders/presentation/screens/orders_screen.dart';
import '../../../profile/presentation/screens/addresses_screen.dart';
import '../../../profile/presentation/screens/payment_methods_screen.dart';
import '../../../profile/presentation/screens/contact_us_screen.dart';
import '../../../profile/presentation/screens/language_screen.dart';
import '../../../profile/presentation/screens/privacy_security_screen.dart';
import '../../../profile/presentation/screens/about_screen.dart';
import '../../../profile/presentation/screens/edit_profile_screen.dart';
import '../../data/auth_repository.dart';
import 'package:denzels_cakes/l10n/app_localizations.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      setState(() => _isLoading = true);

      final user = await _getCurrentUserProfile();

      setState(() {
        _currentUser = user;
        _isLoading = false;
      });
    } catch (e) {
// print('DEBUG: Error loading user data: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<User?> _getCurrentUserProfile() async {
    try {
      // First try to get from backend
      final response = await ApiService.get('/auth/profile');
      if (response.statusCode == 200 && response.data['success'] == true) {
        return User.fromJson(response.data['data']);
      }
    } catch (e) {
// print('DEBUG: Failed to load profile from backend: $e');
    }

    // Fallback to local storage
    return await AuthRepository.getCurrentUser();
  }

  Future<void> _logout() async {
    try {
      await AuthRepository.logout();
      if (mounted) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/login', (route) => false);
      }
    } catch (e) {
// print('DEBUG: Error during logout: $e');
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${l10n.logout}: ${l10n.error}'),
            backgroundColor: AppTheme.errorColor,
          ),
        );
      }
    }
  }

  void _showEditProfileDialog() {
    final nameController =
        TextEditingController(text: _currentUser?.name ?? '');
    final emailController =
        TextEditingController(text: _currentUser?.email ?? '');
    final phoneController =
        TextEditingController(text: _currentUser?.phone ?? '');

    showDialog(
      context: context,
      builder: (BuildContext context) {
        final l10n = AppLocalizations.of(context)!;
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.editProfile,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: l10n.fullName,
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: l10n.email,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: phoneController,
                decoration: InputDecoration(
                  labelText: l10n.phoneNumber,
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: AppTheme.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () async {
                  try {
                    // Update profile via API
                    final response =
                        await ApiService.put('/auth/profile', data: {
                      'name': nameController.text.trim(),
                      'phone': phoneController.text.trim(),
                    });

                    if (response.statusCode == 200 &&
                        response.data['success'] == true) {
                      // Update local user data
                      setState(() {
                        _currentUser = User.fromJson(response.data['data']);
                      });

                      Navigator.of(context).pop();
                      final l10n = AppLocalizations.of(context)!;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(l10n.save + '!'),
                          backgroundColor: AppTheme.successColor,
                        ),
                      );
                    } else {
                      throw Exception('Failed to update profile');
                    }
                  } catch (e) {
// print('DEBUG: Error updating profile: $e');
                    Navigator.of(context).pop();
                    final l10n = AppLocalizations.of(context)!;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('${l10n.error}: $e'),
                        backgroundColor: AppTheme.errorColor,
                      ),
                    );
                  }
                },
                child: Text(
                  l10n.save,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return LoadingOverlay(
      isLoading: _isLoading,
      message: l10n.loadingProfile,
      child: Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: CustomScrollView(
          slivers: [
            // Modern Profile Header
            SliverAppBar(
              pinned: true,
              backgroundColor: AppTheme.surfaceColor,
              foregroundColor: AppTheme.textPrimary,
              surfaceTintColor: Colors.transparent,
              title: Text(l10n.profile),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.refresh),
                  onPressed: _loadUserData,
                ),
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: _showEditProfileDialog,
                ),
              ],
            ),
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).colorScheme.primaryContainer,
                      Theme.of(context).colorScheme.surface,
                    ],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: Theme.of(context).colorScheme.surface,
                      child: Icon(
                        Icons.person,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      _currentUser?.name ?? l10n.guestUser,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _currentUser?.email ?? l10n.guestEmail,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                  ],
                ),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Column(
                  children: [
                    _settingsGroup([
                      _settingsTile(
                        icon: Icons.person_outline,
                        title: l10n.editProfile,
                        onTap: () {
                          Navigator.of(context)
                              .push(MaterialPageRoute(
                                builder: (context) => const EditProfileScreen(),
                              ))
                              .then((_) => _loadUserData());
                        },
                      ),
                      _settingsTile(
                        icon: Icons.location_on_outlined,
                        title: l10n.addresses,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const AddressesScreen(),
                          ));
                        },
                      ),
                      _settingsTile(
                        icon: Icons.payment_outlined,
                        title: l10n.paymentMethods,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const PaymentMethodsScreen(),
                          ));
                        },
                      ),
                      _settingsTile(
                        icon: Icons.receipt_long_outlined,
                        title: l10n.orderHistory,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const OrdersScreen(),
                          ));
                        },
                      ),
                      _settingsTile(
                        icon: Icons.favorite_outline,
                        title: l10n.favorites,
                        onTap: () => Navigator.of(context).pushNamed('/favorites'),
                      ),
                    ]),
                    const SizedBox(height: 16),
                    _settingsGroup([
                      _settingsTile(
                        icon: Icons.language_outlined,
                        title: l10n.language,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const LanguageScreen(),
                          ));
                        },
                      ),
                      _settingsTile(
                        icon: Icons.chat_outlined,
                        title: l10n.contactUs,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const ContactUsScreen(),
                          ));
                        },
                      ),
                      _settingsTile(
                        icon: Icons.policy_outlined,
                        title: l10n.privacyPolicy,
                        onTap: () => _openPrivacyPolicy(context),
                      ),
                      _settingsTile(
                        icon: Icons.lock_outline,
                        title: l10n.privacySecurity,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const PrivacySecurityScreen(),
                          ));
                        },
                      ),
                      _settingsTile(
                        icon: Icons.info_outline,
                        title: l10n.about,
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const AboutScreen(),
                          ));
                        },
                      ),
                    ]),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: () => _showLogoutDialog(context),
                      child: Text(
                        l10n.logout,
                        style: TextStyle(color: Theme.of(context).colorScheme.error),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      ),
    );
  }

  Widget _settingsGroup(List<Widget> tiles) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surfaceContainerLowest,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Column(
        children: [
          for (var i = 0; i < tiles.length; i++) ...[
            if (i > 0) Divider(height: 1, indent: 56, color: scheme.outlineVariant),
            tiles[i],
          ],
        ],
      ),
    );
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final opened = await launchUrl(
      Uri.parse(AppConstants.privacyPolicyUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppConstants.privacyPolicyUrl)),
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            l10n.logout,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
          ),
          content: Text(
            l10n.logoutConfirmation,
            style: TextStyle(
              color: AppTheme.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                l10n.cancel,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    AppTheme.errorColor,
                    AppTheme.errorColor.withValues(alpha: 0.8)
                  ],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                  _logout();
                },
                child: Text(
                l10n.logout,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
