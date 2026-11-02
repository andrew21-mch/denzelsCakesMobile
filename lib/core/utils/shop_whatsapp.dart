import 'package:denzels_cakes/l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

/// Opens the shop WhatsApp chat. The customer still taps Send.
class ShopWhatsApp {
  static const number = '237683252520';
  static const displayNumber = '+237 683 252 520';

  /// "Hello,\nMy name is Jane.\nI would like to order a cake."
  static String introduce(AppLocalizations l10n, String? name, String request) {
    final trimmed = name?.trim() ?? '';
    final requestLine = l10n.whatsappIWouldLikeTo(request);
    if (trimmed.isEmpty) {
      return '${l10n.whatsappHello}\n$requestLine';
    }
    return '${l10n.whatsappHello}\n${l10n.whatsappMyNameIs(trimmed)}\n$requestLine';
  }

  static Future<bool> open(String message) async {
    final encoded = Uri.encodeComponent(message);
    final uris = [
      Uri.parse('https://wa.me/$number?text=$encoded'),
      Uri.parse('whatsapp://send?phone=$number&text=$encoded'),
    ];

    for (final uri in uris) {
      try {
        final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
        if (opened) return true;
      } catch (_) {}
    }
    return false;
  }
}
