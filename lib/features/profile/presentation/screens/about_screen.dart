import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/theme/app_theme.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('About DenzelsCakes'),
        backgroundColor: AppTheme.surfaceColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // App Logo and Info
            _buildAppInfoSection(context),

            const SizedBox(height: 24),

            // Our Story
            _buildStorySection(context),

            const SizedBox(height: 24),

            // Features
            _buildFeaturesSection(context),

            const SizedBox(height: 24),

            // Team
            _buildTeamSection(context),

            const SizedBox(height: 24),

            // Contact Information
            _buildContactSection(context),

            const SizedBox(height: 24),

            // Legal & Credits
            _buildLegalSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildAppInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // App Logo
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.accentColor,
                  AppTheme.accentColor.withValues(alpha: 0.8),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.accentColor.withValues(alpha: 0.3),
                  blurRadius: 15,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: const Icon(
              Icons.cake,
              size: 50,
              color: Colors.white,
            ),
          ),

          const SizedBox(height: 16),

          // App Name
          Text(
            'DenzelsCakes',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),

          const SizedBox(height: 8),

          // Version
          Text(
            'Version 1.0.0',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                ),
          ),

          const SizedBox(height: 16),

          // Tagline
          Text(
            'Delicious cakes delivered fresh to your doorstep in Cameroon',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.5,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStorySection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Story',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          Text(
            'Founded in 2020, Denzel\'s Cakes began as a passion project to bring the finest, freshest cakes to the people of Cameroon. Our journey started in a small kitchen in Douala with a simple mission: to create memorable moments through exceptional cakes.\n\n'
            'Today, we\'re proud to serve customers across Cameroon with our handcrafted cakes, made with love and the finest local ingredients. Every cake tells a story, and we\'re honored to be part of your special moments.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textSecondary,
                  height: 1.6,
                ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'What We Offer',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          _buildFeatureItem(
            icon: Icons.cake_outlined,
            title: 'Fresh Cakes Daily',
            description: 'Baked fresh every day with premium ingredients',
          ),
          _buildFeatureItem(
            icon: Icons.delivery_dining,
            title: 'Fast Delivery',
            description:
                'Same-day delivery across Yaoundé and surrounding areas',
          ),
          _buildFeatureItem(
            icon: Icons.palette,
            title: 'Custom Designs',
            description: 'Personalized cakes for your special occasions',
          ),
          _buildFeatureItem(
            icon: Icons.payment,
            title: 'Easy Payment',
            description: 'Pay with cards or mobile money (MTN, Orange)',
          ),
          _buildFeatureItem(
            icon: Icons.support_agent,
            title: '24/7 Support',
            description: 'Customer support whenever you need us',
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppTheme.accentColor,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Our Team',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          _buildTeamMember(
            name: 'Marie Dubois',
            role: 'Head Baker & Founder',
            description: '15+ years of baking experience',
          ),
          _buildTeamMember(
            name: 'Jean Kamga',
            role: 'Pastry Chef',
            description: 'Specialist in custom cake designs',
          ),
          _buildTeamMember(
            name: 'Sarah Nkomo',
            role: 'Customer Success',
            description: 'Ensuring every customer is happy',
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMember({
    required String name,
    required String role,
    required String description,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: AppTheme.accentColor.withValues(alpha: 0.1),
            child: const Icon(
              Icons.person,
              color: AppTheme.accentColor,
              size: 25,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                Text(
                  role,
                  style: const TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Contact Us',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),
          
          // Location
          _buildContactItem(
            icon: Icons.location_on,
            title: 'Location',
            subtitle: 'Makepe, Douala\nCameroon\nOpposite Tradex Rhone Poulenc',
          ),
          
          const SizedBox(height: 16),
          
          // Phone
          _buildContactItem(
            icon: Icons.phone,
            title: 'Call Us',
            subtitle: '683 252 520',
          ),
          
          const SizedBox(height: 16),
          
          // WhatsApp
          _buildContactItem(
            icon: Icons.message,
            title: 'WhatsApp',
            subtitle: '683 252 520',
          ),
          
          const SizedBox(height: 16),
          
          // Email
          _buildContactItem(
            icon: Icons.email,
            title: 'Email',
            subtitle: 'hello@denzelscakes.com',
          ),
        ],
      ),
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: AppTheme.accentColor,
            size: 20,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildLegalSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surfaceColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: AppTheme.cardShadowColor,
            blurRadius: 8,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Legal & Credits',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
          ),
          const SizedBox(height: 16),

          _buildLegalItem(
            title: 'Privacy Policy',
            onTap: () {
              HapticFeedback.lightImpact();
              _showPrivacyPolicy(context);
            },
          ),

          _buildLegalItem(
            title: 'Terms of Service',
            onTap: () {
              HapticFeedback.lightImpact();
              _showTermsOfService(context);
            },
          ),

          _buildLegalItem(
            title: 'Open Source Licenses',
            onTap: () {
              HapticFeedback.lightImpact();
              _showLicenses(context);
            },
          ),

          const SizedBox(height: 16),

          // Copyright
          Center(
            child: Text(
              '© 2020 DenzelsCakes Cameroon\nAll rights reserved',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textTertiary,
                  ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem({
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        margin: const EdgeInsets.only(bottom: 8),
        decoration: BoxDecoration(
          color: AppTheme.backgroundColor,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              size: 16,
              color: AppTheme.textTertiary,
            ),
          ],
        ),
      ),
    );
  }

  void _showPrivacyPolicy(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Privacy Policy'),
        content: const SingleChildScrollView(
          child: Text(
            'At DenzelsCakes, we respect your privacy and are committed to protecting your personal information.\n\n'
            'Information We Collect:\n'
            '• Contact information (name, email, phone)\n'
            '• Delivery addresses\n'
            '• Order history and preferences\n'
            '• Payment information (securely processed)\n\n'
            'How We Use Your Information:\n'
            '• Process and fulfill your orders\n'
            '• Communicate about your orders\n'
            '• Improve our services\n'
            '• Send promotional offers (with consent)\n\n'
            'We never sell your personal information to third parties.',
            style: TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Terms of Service'),
        content: const SingleChildScrollView(
          child: Text(
            'Welcome to DenzelsCakes! By using our service, you agree to these terms.\n\n'
            'Orders:\n'
            '• All orders are subject to availability\n'
            '• Custom cakes require 24-48 hours notice\n'
            '• Prices are in FCFA and include applicable taxes\n\n'
            'Delivery:\n'
            '• Delivery times are estimates\n'
            '• Delivery fees apply based on location\n'
            '• We are not responsible for delays due to weather or traffic\n\n'
            'Cancellations:\n'
            '• Orders can be cancelled within 2 hours of placement\n'
            '• Custom orders may have different cancellation policies\n\n'
            'Quality Guarantee:\n'
            '• We guarantee the freshness and quality of our cakes\n'
            '• Contact us within 24 hours for any quality issues',
            style: TextStyle(height: 1.5),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showLicenses(BuildContext context) {
    showLicensePage(
      context: context,
      applicationName: 'DenzelsCakes',
      applicationVersion: '1.0.0',
      applicationLegalese: '© 2020 DenzelsCakes Cameroon',
    );
  }
}
