enum ClientEnum {
  bancosol, bancosol_capybara, tricolor, hermoney, baneco, flourish
}

extension ToString on ClientEnum {
  String toEnvValue() {
    return this.name.toUpperCase();
  }
}