/// Plain-text cleanup for values stored or shown in the app, plus HTML
/// escaping for any later template that renders those values on the web.
abstract final class ContentSanitizer {
  static String sanitizePlainText(String input, {int maxLength = 80}) {
    final withoutTags = input.replaceAll(RegExp(r'<[^>]*>'), '');
    final withoutControls = withoutTags.replaceAll(
      RegExp(r'[\u0000-\u001F\u007F]'),
      '',
    );
    final collapsed = withoutControls.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (collapsed.length <= maxLength) return collapsed;
    return collapsed.substring(0, maxLength).trim();
  }

  static String escapeHtml(String input) {
    return input
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&#39;');
  }
}
