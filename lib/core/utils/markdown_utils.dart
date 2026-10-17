class MarkdownUtils {
  /// Fixes a common markdown parsing bug with CJK characters in flutter_markdown.
  /// The CommonMark specification has strict left-flanking and right-flanking rules for `**`.
  /// If `**` is immediately preceded by a CJK character and followed by a punctuation (e.g. `店**「`), 
  /// it is NOT considered left-flanking and will not open a bold tag.
  /// By injecting spaces around the bold blocks, we satisfy the flanking rules safely.
  static String fixCjkBold(String text) {
    return text.replaceAllMapped(RegExp(r'\*\*(.*?)\*\*', dotAll: true), (match) {
      final inner = match.group(1);
      return ' **$inner** ';
    });
  }

  /// Comprehensive AI Markdown sanitization pipeline.
  ///
  /// - Unescapes literal newline sequences (`\n`, `\r\n`) emitted inside JSON strings.
  /// - Normalizes missing spaces after Markdown headings (`##標題` -> `## 標題`).
  /// - Normalizes missing spaces after list bullets (`-項目` -> `- 項目`).
  /// - Normalizes missing spaces after ordered lists (`1.項目` -> `1. 項目`).
  /// - Auto-promotes comparison section headers if `##` was omitted.
  /// - Fixes CJK bold flanking rules.
  /// - Cleans up redundant blank lines.
  static String formatAiMarkdown(String text) {
    if (text.isEmpty) return '';

    String formatted = text;

    // 1. Unescape literal newlines and tabs
    formatted = formatted
        .replaceAll(r'\r\n', '\n')
        .replaceAll(r'\n', '\n')
        .replaceAll(r'\r', '\n')
        .replaceAll(r'\t', '  ');

    // 2. Normalize headings missing space: ##標題 -> ## 標題
    formatted = formatted.replaceAllMapped(
      RegExp(r'^(#{1,6})([^\s#])', multiLine: true),
      (match) => '${match[1]} ${match[2]}',
    );

    // 3. Normalize bullet lists missing space: -條目 -> - 條目
    formatted = formatted.replaceAllMapped(
      RegExp(r'^([\*\-+])([^\s\*\-+])', multiLine: true),
      (match) => '${match[1]} ${match[2]}',
    );

    // 4. Normalize ordered lists missing space: 1.項目 -> 1. 項目
    formatted = formatted.replaceAllMapped(
      RegExp(r'^(\d+\.)([^\s\d])', multiLine: true),
      (match) => '${match[1]} ${match[2]}',
    );

    // 5. Auto-promote known comparison section headers if ## was omitted by LLM
    formatted = formatted.replaceAllMapped(
      RegExp(r'^(?<!#\s?)(總體評價|決定性差異|各自優勢|推薦受眾)(.*)$', multiLine: true),
      (match) => '## ${match[1]}${match[2]}',
    );

    // 6. Fix CJK bold flanking
    formatted = fixCjkBold(formatted);

    // 7. Collapse 3+ consecutive newlines into 2
    formatted = formatted.replaceAll(RegExp(r'\n{3,}'), '\n\n');

    return formatted.trim();
  }
}
