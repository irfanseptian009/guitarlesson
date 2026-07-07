/// Date helpers shared by the practice log, streak, and stats code.
abstract final class Dates {
  /// Canonical storage key: `yyyy-MM-dd`.
  static String key(DateTime date) =>
      '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';

  static String todayKey() => key(DateTime.now());

  /// Monday of the week containing [date].
  static DateTime startOfWeek(DateTime date) {
    final day = DateTime(date.year, date.month, date.day);
    return day.subtract(Duration(days: day.weekday - DateTime.monday));
  }

  /// Indonesian day initials, Monday-first (Senin..Minggu).
  static const weekDayInitials = ['S', 'S', 'R', 'K', 'J', 'S', 'M'];
}
