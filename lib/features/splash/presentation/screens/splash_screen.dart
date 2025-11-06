import 'package:flutter/material.dart';
import '../../../../shared/theme/app_theme.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../features/auth/data/auth_repository.dart';
import '../../../../l10n/app_localizations.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.0, 0.6, curve: Curves.easeOut),
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.2, 0.8, curve: Curves.elasticOut),
    ));

    _startAnimation();
  }

  void _startAnimation() async {
    await _animationController.forward();

    // Wait a bit more then navigate
    await Future.delayed(const Duration(milliseconds: 1000));

    if (mounted) {
      // Check if user is logged in
      final isLoggedIn = await AuthRepository.isLoggedIn();
// print('Splash Screen - User logged in: $isLoggedIn');

      if (isLoggedIn) {
        // Get current user to check role
        final user = await AuthRepository.getCurrentUser();
// print('Splash Screen - Current user: ${user?.name}, Role: ${user?.role}');

        if (user != null && user.role == 'admin') {
          // Redirect admin to admin dashboard
// print('Splash Screen - Redirecting admin to dashboard');
          Navigator.of(context).pushReplacementNamed('/admin');
        } else {
          // Redirect regular user to home
// print('Splash Screen - Redirecting user to home');
          Navigator.of(context).pushReplacementNamed('/home');
        }
      } else {
        // User not logged in, go to login
// print('Splash Screen - No user logged in, going to login');
        Navigator.of(context).pushReplacementNamed('/login');
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: AppTheme.backgroundGradient,
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(flex: 2),

                // Logo and Brand
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _scaleAnimation.value,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: Column(
                          children: [
                            // Animated Logo Container with Real Logo
                            Container(
                              width: 160,
                              height: 160,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(40),
                                boxShadow: [
                                  const BoxShadow(
                                    color: AppTheme.shadowColor,
                                    blurRadius: 30,
                                    offset: Offset(0, 15),
                                  ),
                                  BoxShadow(
                                    color: AppTheme.accentColor
                                        .withValues(alpha: 0.2),
                                    blurRadius: 50,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(12),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(28),
                                child: Image.asset(
                                  'assets/images/logo.jpeg',
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        gradient: AppTheme.primaryGradient,
                                        borderRadius: BorderRadius.circular(28),
                                      ),
                                      child: Stack(
                                        alignment: Alignment.center,
                                        children: [
                                          // Rotating background circle
                                          RotationTransition(
                                            turns: _animationController,
                                            child: Container(
                                              width: 100,
                                              height: 100,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                gradient: LinearGradient(
                                                  colors: [
                                                    Colors.white
                                                        .withValues(alpha: 0.1),
                                                    Colors.white
                                                        .withValues(alpha: 0.3),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ),
                                          // Main cake icon
                                          const Icon(
                                            Icons.cake,
                                            size: 80,
                                            color: Colors.white,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),

                            const SizedBox(height: 32),

                            // App Name with Gradient and Slide Animation
                            SlideTransition(
                              position: Tween<Offset>(
                                begin: const Offset(0, 0.5),
                                end: Offset.zero,
                              ).animate(CurvedAnimation(
                                parent: _animationController,
                                curve: const Interval(0.4, 0.8,
                                    curve: Curves.easeOutBack),
                              )),
                              child: Column(
                                children: [
                                  ShaderMask(
                                    shaderCallback: (bounds) => AppTheme
                                        .primaryGradient
                                        .createShader(bounds),
                                    child: const Text(
                                      AppConstants.appName,
                                      style: TextStyle(
                                        fontSize: 42,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                        letterSpacing: 2.0,
                                        shadows: [
                                          Shadow(
                                            color: AppTheme.shadowColor,
                                            blurRadius: 8,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),

                                  const SizedBox(height: 12),

                                  // Tagline with Fade Animation
                                  FadeTransition(
                                    opacity: Tween<double>(begin: 0.0, end: 1.0)
                                        .animate(
                                      CurvedAnimation(
                                        parent: _animationController,
                                        curve: const Interval(0.6, 1.0,
                                            curve: Curves.easeIn),
                                      ),
                                    ),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 24, vertical: 8),
                                      decoration: BoxDecoration(
                                        color:
                                            Colors.white.withValues(alpha: 0.9),
                                        borderRadius: BorderRadius.circular(20),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: AppTheme.shadowColor,
                                            blurRadius: 10,
                                            offset: Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: Text(
                                        AppLocalizations.of(context)!.splashTagline,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: AppTheme.textSecondary,
                                          fontWeight: FontWeight.w500,
                                          fontStyle: FontStyle.italic,
                                          letterSpacing: 0.5,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(flex: 2),

                // Loading Indicator with modern design
                AnimatedBuilder(
                  animation: _fadeAnimation,
                  builder: (context, child) {
                    return FadeTransition(
                      opacity: _fadeAnimation,
                      child: Column(
                        children: [
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(25),
                              boxShadow: const [
                                BoxShadow(
                                  color: AppTheme.shadowColor,
                                  blurRadius: 15,
                                  offset: Offset(0, 6),
                                ),
                              ],
                            ),
                            child: const Center(
                              child: SizedBox(
                                width: 28,
                                height: 28,
                                child: CircularProgressIndicator(
                                  strokeWidth: 3,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    AppTheme.accentColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.8),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Text(
                              AppLocalizations.of(context)!.preparingCakeExperience,
                              style: const TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 0.3,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                const SizedBox(height: 60),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
