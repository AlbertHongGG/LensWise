import 'package:flutter_test/flutter_test.dart';
import 'package:lens_wise/core/utils/markdown_utils.dart';

void main() {
  group('MarkdownUtils.formatAiMarkdown Tests', () {
    test('Unescapes literal \\n and \\r\\n sequences', () {
      const input = r'總體評價 (Overall Verdict)\n本次評測涵蓋\r\n多項商品。';
      final formatted = MarkdownUtils.formatAiMarkdown(input);
      expect(formatted, contains('\n'));
      expect(formatted, isNot(contains(r'\n')));
      expect(formatted, isNot(contains(r'\r\n')));
    });

    test('Normalizes headings missing space after #', () {
      const input = '##總體評價\n###特點說明';
      final formatted = MarkdownUtils.formatAiMarkdown(input);
      expect(formatted, contains('## 總體評價'));
      expect(formatted, contains('### 特點說明'));
    });

    test('Normalizes bullet lists missing space', () {
      const input = '-第一項\n*第二項\n+第三項';
      final formatted = MarkdownUtils.formatAiMarkdown(input);
      expect(formatted, contains('- 第一項'));
      expect(formatted, contains('* 第二項'));
      expect(formatted, contains('+ 第三項'));
    });

    test('Auto-promotes known comparison headers if ## was omitted', () {
      const input = '總體評價 (Overall Verdict)\n這是開場總體介紹。\n決定性差異\n- 價格有差距。';
      final formatted = MarkdownUtils.formatAiMarkdown(input);
      expect(formatted, contains('## 總體評價 (Overall Verdict)'));
      expect(formatted, contains('## 決定性差異'));
    });

    test('Fixes CJK bold flanking rules', () {
      const input = '這是**最強豆皮烏龍麵**的特色。';
      final formatted = MarkdownUtils.formatAiMarkdown(input);
      expect(formatted, contains(' **最強豆皮烏龍麵** '));
    });

    test('Collapses excessive consecutive blank lines', () {
      const input = '第一段\n\n\n\n\n第二段';
      final formatted = MarkdownUtils.formatAiMarkdown(input);
      expect(formatted, equals('第一段\n\n第二段'));
    });

    test('Handles empty and whitespace string safely', () {
      expect(MarkdownUtils.formatAiMarkdown(''), equals(''));
      expect(MarkdownUtils.formatAiMarkdown('   \n  '), equals(''));
    });
  });
}
