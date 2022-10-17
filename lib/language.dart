enum Language {
  spanish,
  english,
  portugues
}

final Map<Language, String> langMap = {
  Language.spanish: 'es',
  Language.english: 'en',
  Language.portugues: 'pt',
};

extension LangCode on Language {
  String? code() {
    return langMap[this];
  }
}
