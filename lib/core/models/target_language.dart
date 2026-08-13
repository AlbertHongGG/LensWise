enum TargetLanguage {
  traditionalChinese('繁體中文', 'Traditional Chinese'),
  english('English', 'English'),
  japanese('日本語', 'Japanese'),
  korean('한국어', 'Korean');

  final String displayName;
  final String promptName;

  const TargetLanguage(this.displayName, this.promptName);

  static TargetLanguage fromDisplayName(String name) {
    return TargetLanguage.values.firstWhere(
      (e) => e.displayName == name,
      orElse: () => TargetLanguage.traditionalChinese,
    );
  }

  static TargetLanguage fromString(String name) {
    return TargetLanguage.values.firstWhere(
      (e) => e.name == name,
      orElse: () => TargetLanguage.traditionalChinese,
    );
  }
}
