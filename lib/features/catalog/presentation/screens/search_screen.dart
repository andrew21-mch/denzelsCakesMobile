import 'package:flutter/material.dart';

class SearchScreen extends StatelessWidget {
  final String? initialQuery;

  const SearchScreen({super.key, this.initialQuery});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search')),
      body: Center(
          child: Text('Search Screen - Query: ${initialQuery ?? "None"}')),
    );
  }
}
