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
}
