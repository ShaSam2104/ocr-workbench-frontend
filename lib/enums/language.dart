enum LanguageCode {
  hindi('hi', 'Hindi'),
  english('en', 'English'),
  sanskrit('sa', 'Sanskrit');

  final String code;
  final String displayName;

  const LanguageCode(this.code, this.displayName);

  static LanguageCode fromCode(String code) {
    return LanguageCode.values.firstWhere(
      (lang) => lang.code == code,
      orElse: () => LanguageCode.english,
    );
  }
}
