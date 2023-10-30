class Logger {
  static final Logger _mInstance = Logger._internal();

  static Logger get instance => _mInstance;

  Logger._internal();

  final List<String> _logs = [];

  Iterable<String> get logs => _logs;

  void error(Object message) => _logs.add("ERROR: ${message.toString()}");

  void debug(Object message) => _logs.add("DEBUG: ${message.toString()}");
}
