class Environment {
  Environment._();

  static const String value = String.fromEnvironment("env");
  static const String label = String.fromEnvironment("env_label");

  static const String dineazyBaseUrl = String.fromEnvironment("dineazy_base_url");
  static const String eazypmsBaseUrl = String.fromEnvironment("eazypms_base_url");

  static const String redisHost = String.fromEnvironment("redis_host");
  static const String redisPort = String.fromEnvironment("redis_port");
  static const String redisPassword = String.fromEnvironment("redis_password");
}
