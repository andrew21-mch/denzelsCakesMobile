import 'package:flutter/material.dart';

class QuickActionsCard extends StatelessWidget {
  final VoidCallback? onOrdersPressed;
  final VoidCallback? onCakesPressed;
  final VoidCallback? onCustomersPressed;

  const QuickActionsCard({
    super.key,
    this.onOrdersPressed,
    this.onCakesPressed,
    this.onCustomersPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tiles = [
      (Icons.receipt_long_outlined, 'Orders', onOrdersPressed),
      (Icons.cake_outlined, 'Cakes', onCakesPressed),
      (Icons.people_outline, 'Customers', onCustomersPressed),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Shortcuts', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 4),
        Material(
          color: scheme.surfaceContainerLowest,
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: scheme.outlineVariant),
          ),
          child: Column(
            children: [
              for (var i = 0; i < tiles.length; i++) ...[
                if (i > 0)
                  Divider(height: 1, indent: 56, color: scheme.outlineVariant),
                ListTile(
                  leading: Icon(tiles[i].$1),
                  title: Text(tiles[i].$2),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: tiles[i].$3,
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
