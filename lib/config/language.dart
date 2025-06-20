enum Language {
  spanish,
  english,
  portugues;

  String get code {
    switch (this) {
      case Language.spanish:
        return 'es';
      case Language.english:
        return 'en';
      case Language.portugues:
        return 'pt';
    }
  }
}
