/// Measures how long a practice screen was open so the time can be
/// committed to the progress log when the screen is disposed.
class PracticeClock {
  PracticeClock(this._commit);

  final void Function(int seconds) _commit;
  final Stopwatch _watch = Stopwatch()..start();
  bool _committed = false;

  /// Stops the clock and reports elapsed whole seconds exactly once.
  ///
  /// Called from callers' `dispose()`, so the provider write is deferred to
  /// a microtask — Riverpod forbids modifying providers while the widget
  /// tree is being torn down.
  void commit() {
    if (_committed) return;
    _committed = true;
    _watch.stop();
    final seconds = _watch.elapsed.inSeconds;
    Future.microtask(() => _commit(seconds));
  }
}
