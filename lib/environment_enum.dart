enum Environment { development, staging, production, preproduction }

extension ToString on Environment {
  String toEnvValue() {
    return this.name.toUpperCase();
  }
}
