import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens WhatsApp or Facebook with a cake the shop can send to a customer.
class CakeShare {
  static String linkFor(String? id) {
    if (id == null || id.isEmpty) return 'https://denzelscakes.com';
    return 'https://denzelscakes.com/?cake=$id';
  }

  static String message({
    required String title,
    required num price,
    String? description,
    String? id,
  }) {
    final about = (description ?? '').trim();
    final short = about.length > 140 ? '${about.substring(0, 137)}...' : about;
    return [
      title.trim(),
      '${price.round()} XAF',
      if (short.isNotEmpty) short,
      "Denzel'sCakes",
      linkFor(id),
    ].join('\n');
  }

  static Future<void> show(
    BuildContext context, {
    required String title,
    required num price,
    String? description,
    String? id,
  }) {
    final text = message(
      title: title,
      price: price,
      description: description,
      id: id,
    );
    final link = linkFor(id);
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.chat_outlined),
                title: const Text('WhatsApp'),
                subtitle: const Text('Send this cake in a chat'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final opened = await _open(_whatsappUris(text));
                  if (!opened && context.mounted) {
                    _failed(context, 'WhatsApp');
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.facebook),
                title: const Text('Facebook'),
                subtitle: const Text('Post this cake'),
                onTap: () async {
                  Navigator.pop(sheetContext);
                  final opened = await _open(_facebookUris(link));
                  if (!opened && context.mounted) {
                    _failed(context, 'Facebook');
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  static List<Uri> _whatsappUris(String text) {
    final encoded = Uri.encodeComponent(text);
    return [
      Uri.parse('whatsapp://send?text=$encoded'),
      Uri.parse('https://wa.me/?text=$encoded'),
      Uri.parse('https://api.whatsapp.com/send?text=$encoded'),
    ];
  }

  static List<Uri> _facebookUris(String link) {
    final sharePage =
        'https://www.facebook.com/sharer/sharer.php?u=${Uri.encodeComponent(link)}';
    return [
      Uri.parse(
        'fb://facewebmodal/f?href=${Uri.encodeComponent(sharePage)}',
      ),
      Uri.parse(sharePage),
    ];
  }

  static Future<bool> _open(List<Uri> uris) async {
    for (final uri in uris) {
      try {
        final opened = await launchUrl(
          uri,
          mode: LaunchMode.externalApplication,
        );
        if (opened) return true;
      } catch (_) {}
    }
    return false;
  }

  static void _failed(BuildContext context, String app) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Could not open $app')),
    );
  }
}
