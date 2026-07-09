import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_palette.dart';
import '../../core/i18n/strings.dart';
import '../../widgets/capi_deco.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/screen_scaffold.dart';

class _Tool {
  const _Tool(this.name, this.desc, this.icon, this.color, this.action,
      {this.darkIcon = false});

  final String name;
  final String desc;

  /// A distinct, instantly-recognisable glyph per tool.
  final IconData icon;
  final Color color;

  /// True when the chip color is light (yellow/pink) and needs navy ink.
  final bool darkIcon;
  final void Function(BuildContext) action;
}

/// Tools hub: the eight tool cards, each with its own icon & accent color.
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  static List<_Tool> _tools(AppPalette colors, S s) => [
        _Tool('Tuner', s.toolTunerDesc, Icons.speed_rounded, colors.orange,
            (c) => c.go('/tuner')),
        _Tool('Metronome', s.toolMetronomeDesc, Icons.av_timer_rounded,
            colors.blue, (c) => c.push('/tools/metronome')),
        _Tool('Chord Library', s.toolChordLibDesc, Icons.grid_on_rounded,
            colors.yellow, (c) => c.push('/tools/chords'), darkIcon: true),
        _Tool('Chord Detector', s.toolDetectorDesc, Icons.mic_rounded,
            colors.green, (c) => c.push('/tools/chord-detector')),
        _Tool('Songs + Chart', s.toolSongsDesc, Icons.queue_music_rounded,
            colors.red, (c) => c.push('/tools/songs')),
        _Tool('Ear Training', s.toolEarDesc, Icons.hearing_rounded,
            colors.purple, (c) => c.push('/tools/ear-training')),
        _Tool('Jam Tracks', s.toolJamDesc, Icons.album_rounded,
            colors.pinkStrong, (c) => c.push('/tools/metronome')),
        _Tool('Riff Recorder', s.toolRecorderDesc,
            Icons.radio_button_checked_rounded, colors.navy,
            (c) => c.push('/tools/recorder')),
      ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final s = context.s;
    final tools = _tools(colors, s);
    return ScreenScaffold(
      gap: 16,
      children: [
        Stack(
          children: [
            ScreenTitle(
              s.tools,
              subtitle: s.toolsSubtitle,
            ),
            Positioned(
              top: 4,
              right: 2,
              child: Sparkle(color: colors.yellow, size: 20),
            ),
          ],
        ),
        Column(
          children: [
            for (var row = 0; row < tools.length; row += 2) ...[
              if (row > 0) const SizedBox(height: 12),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _ToolCard(tool: tools[row])),
                    const SizedBox(width: 12),
                    Expanded(
                      child: row + 1 < tools.length
                          ? _ToolCard(tool: tools[row + 1])
                          : const SizedBox.shrink(),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

class _ToolCard extends StatelessWidget {
  const _ToolCard({required this.tool});

  final _Tool tool;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return GlassCard(
      radius: 24,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      onTap: () => tool.action(context),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 108),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: tool.color,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: tool.color.withValues(alpha: 0.35),
                        blurRadius: 12,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Icon(
                    tool.icon,
                    size: 24,
                    color: tool.darkIcon
                        ? const Color(0xFF232B54)
                        : Colors.white,
                  ),
                ),
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    color: colors.cream.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                    border: Border.all(color: colors.cardBorder),
                  ),
                  child: Icon(Icons.arrow_outward_rounded,
                      size: 14, color: colors.creamDim),
                ),
              ],
            ),
            const SizedBox(height: 13),
            Text(tool.name,
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text(
              tool.desc,
              style: TextStyle(
                fontSize: 11,
                height: 1.45,
                color: colors.creamFaint,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
