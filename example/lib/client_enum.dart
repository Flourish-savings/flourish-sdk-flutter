enum ClientEnum {
  bancosol, tricolor, hermoney, baneco, flourish
}

extension ToString on ClientEnum {
  String toEnvValue() {
    return this.name.toUpperCase();
  }
}