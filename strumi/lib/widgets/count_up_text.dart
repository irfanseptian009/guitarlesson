import 'package:flutter/material.dart';

/// Number that animates towards its value — stats feel alive instead of
/// popping in. Re-animates smoothly whenever [value] changes.
class CountUpText extends StatelessWidget {
  const CountUpText(
    this.value, {
    super.key,
    this.style,
    this.duration = const Duration(milliseconds: 900),
    this.format,
  });

  final num value;
  final TextStyle? style;
  final Duration duration;

  /// Optional formatter; defaults to the rounded integer.
  final String Function(num value)? format;

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.toDouble()),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, animated, _) => Text(
        format?.call(animated) ?? '${animated.round()}',
        style: style,
      ),
    );
  }
}
