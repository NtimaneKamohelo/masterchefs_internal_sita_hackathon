import 'package:flutter_test/flutter_test.dart';
import 'package:grantsandbenfits/core/security/content_sanitizer.dart';

void main() {
  test('plain text drops tags and control characters', () {
    expect(
      ContentSanitizer.sanitizePlainText('Ann  <b>Smith</b>'),
      'Ann Smith',
    );
    expect(
      ContentSanitizer.sanitizePlainText('Ada\u0000Lovelace'),
      'AdaLovelace',
    );
  });

  test('html escape replaces markup characters', () {
    expect(
      ContentSanitizer.escapeHtml('<script>"x"</script>'),
      '&lt;script&gt;&quot;x&quot;&lt;/script&gt;',
    );
  });
}
