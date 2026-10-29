abstract interface class WriteTransactionRunner {
  Future<T> run<T>(Future<T> Function() action);
}
