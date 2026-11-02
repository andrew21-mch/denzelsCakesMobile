import 'package:flutter/material.dart';

import 'add_cake_screen.dart';

/// Same form as a new cake, filled with the cake being changed.
class EditCakeScreen extends StatelessWidget {
  final Map<String, dynamic> cake;

  const EditCakeScreen({super.key, required this.cake});

  @override
  Widget build(BuildContext context) {
    return AddCakeScreen(cake: cake);
  }
}
