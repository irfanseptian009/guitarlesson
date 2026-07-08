import 'package:flutter/material.dart';

import '../app/theme/app_palette.dart';
import 'fade_slide_in.dart';

/// Height reserved beneath scrollable content so it clears the floating nav.
const double kBottomNavClearance = 118;

/// Standard screen layout: safe-area aware scroll view with the design's
/// 22px gutters, clearance for the floating bottom nav, and a staggered
/// entrance animation per section.
class ScreenScaffold extends StatelessWidget {
  const ScreenScaffold({
    super.key,
    required this.children,
    this.gap = 18,
    this.scrollController,
    this.withNavClearance = true,
    this.animate = true,
  });

  final List<Widget> children;
  final double gap;
  final ScrollController? scrollController;
  final bool withNavClearance;

  /// Set false to opt out of the entrance stagger (rarely needed).
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.paddingOf(context).top;
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    return SingleChildScrollView(
      controller: scrollController,
      padding: EdgeInsets.fromLTRB(
        22,
        topInset + 16,
        22,
        withNavClearance ? kBottomNavClearance + bottomInset : 24 + bottomInset,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (var i = 0; i < children.length; i++) ...[
            if (i > 0) SizedBox(height: gap),
            if (animate)
              FadeSlideIn(
                delay: Duration(milliseconds: 45 * i.clamp(0, 8)),
                child: children[i],
              )
            else
              children[i],
          ],
        ],
      ),
    );
  }
}

/// Circular "back" button used by sub-screens.
class RoundBackButton extends StatelessWidget {
  const RoundBackButton({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GestureDetector(
      onTap: onTap ?? () => Navigator.of(context).maybePop(),
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: colors.cream.withValues(alpha: 0.07),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Icon(Icons.arrow_back_ios_new_rounded,
            size: 16, color: colors.cream),
      ),
    );
  }
}

/// Large screen title matching the design's 26px/700 headers.
class ScreenTitle extends StatelessWidget {
  const ScreenTitle(this.text, {super.key, this.subtitle});

  final String text;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(text,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700)),
        if (subtitle != null) ...[
          const SizedBox(height: 6),
          Text(subtitle!,
              style: TextStyle(fontSize: 13, color: context.colors.creamDim)),
        ],
      ],
    );
  }
}

/// Header row with back button + title for sub-screens.
class SubScreenHeader extends StatelessWidget {
  const SubScreenHeader({
    super.key,
    required this.title,
    this.overline,
    this.onBack,
    this.trailing,
  });

  final String title;
  final String? overline;
  final VoidCallback? onBack;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        RoundBackButton(onTap: onBack),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (overline != null)
                Text(
                  overline!.toUpperCase(),
                  style: TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.5,
                    color: context.colors.cream.withValues(alpha: 0.5),
                  ),
                ),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: overline != null ? 17 : 26,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
        ?trailing,
      ],
    );
  }
}
