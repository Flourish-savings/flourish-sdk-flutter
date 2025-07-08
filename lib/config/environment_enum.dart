enum Environment {
  development,
  staging,
  production,
  preproduction;

  String toEnvValue() => name.toUpperCase();
}
