/// Measures how long a practice screen was open so the time can be
/// committed to the progress log when the screen is disposed.
class PracticeClock {
  PracticeClock(this._commit);

  final void Function(int seconds) _commit;
  final Stopwatch _watch = Stopwatch()..start();
  bool _committed = false;

  /// Stops the clock and reports elapsed whole seconds exactly once.
  void commit() {
    if (_committed) return;
    _committed = true;
    _watch.stop();
    _commit(_watch.elapsed.inSeconds);
  }
}
