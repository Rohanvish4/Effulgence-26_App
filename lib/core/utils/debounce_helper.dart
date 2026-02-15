import 'dart:async';

/// Debounce Helper for efficient API calls and expensive operations
/// Prevents duplicate/rapid API calls by waiting for a delay before executing
/// 
/// Usage:
/// ```dart
/// final debouncer = Debouncer(milliseconds: 500);
/// 
/// _searchController.addListener(() {
///   debouncer.run(() {
///     searchEvents(_searchController.text);
///   });
/// });
/// ```
class Debouncer {
  final int milliseconds;
  Timer? _timer;

  Debouncer({this.milliseconds = 500});

  /// Execute a function with debounce delay
  /// If called again before the delay completes, the previous call is cancelled
  run(Function() action) {
    _timer?.cancel();
    _timer = Timer(Duration(milliseconds: milliseconds), action);
  }

  /// Cancel any pending debounced action
  void cancel() {
    _timer?.cancel();
  }

  /// Dispose the debouncer (call in cleanup)
  void dispose() {
    _timer?.cancel();
  }
}

/// Factory function to create debounced callbacks
/// More idiomatic for single-use debouncing
Future<T> debounce<T>(
  Future<T> Function() action, {
  int milliseconds = 500,
}) async {
  await Future.delayed(Duration(milliseconds: milliseconds));
  return action();
}
