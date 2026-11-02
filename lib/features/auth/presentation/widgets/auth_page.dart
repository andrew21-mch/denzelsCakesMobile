import 'package:flutter/material.dart';
import '../../../../shared/widgets/loading_overlay.dart';

/// Sign-in layout used by Google account screens: product mark and title at
/// the top, the form under them, and the actions pinned to the bottom.
class AuthPage extends StatelessWidget {
  const AuthPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.logoLabel,
    required this.child,
    required this.primaryLabel,
    required this.onPrimary,
    required this.secondaryLabel,
    required this.onSecondary,
    this.isLoading = false,
    this.loadingMessage,
  });

  final String title;
  final String subtitle;
  final String logoLabel;
  final Widget child;
  final String primaryLabel;
  final VoidCallback? onPrimary;
  final String secondaryLabel;
  final VoidCallback onSecondary;
  final bool isLoading;
  final String? loadingMessage;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LoadingOverlay(
      isLoading: isLoading,
      message: loadingMessage,
      child: Scaffold(
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 450),
                      child: IntrinsicHeight(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Image.asset(
                                'assets/images/logo.png',
                                height: 40,
                                fit: BoxFit.contain,
                                alignment: Alignment.centerLeft,
                                semanticLabel: logoLabel,
                              ),
                              const SizedBox(height: 16),
                              Text(title, style: theme.textTheme.headlineSmall),
                              const SizedBox(height: 8),
                              Text(
                                subtitle,
                                style: theme.textTheme.bodyLarge?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                              const SizedBox(height: 32),
                              child,
                              const Spacer(),
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  TextButton(
                                    onPressed: onSecondary,
                                    child: Text(secondaryLabel),
                                  ),
                                  const Spacer(),
                                  FilledButton(
                                    onPressed: isLoading ? null : onPrimary,
                                    child: Text(primaryLabel),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
