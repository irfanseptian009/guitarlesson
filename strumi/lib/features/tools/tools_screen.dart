import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_palette.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/screen_scaffold.dart';

class _Tool {
  const _Tool(this.name, this.desc, this.color, this.round, this.action);

  final String name;
  final String desc;
  final Color color;

  /// True = circle icon, false = rounded square (mirrors the design).
  final bool round;
  final void Function(BuildContext) action;
}

/// Tools hub: the eight tool cards from the design, all functional.
class ToolsScreen extends StatelessWidget {
  const ToolsScreen({super.key});

  static List<_Tool> _tools(AppPalette colors) => [
        _Tool('Tuner', 'Setem 6 senar dengan gauge presisi ±1 cent',
            colors.orange, true, (c) => c.go('/tuner')),
        _Tool('Metronome', 'BPM 40–220, tap tempo & drum tracks', colors.blue,
            false, (c) => c.push('/tools/metronome')),
        _Tool('Chord Library', '26+ chord dengan diagram jari', colors.yellow,
            false, (c) => c.push('/tools/chords')),
        _Tool('Chord Detector', 'AI menebak chord yang kamu mainkan',
            colors.green, true, (c) => c.push('/tools/chord-detector')),
        _Tool('Songs + Chart Player', 'Chart chord auto-play + slow-downer',
            colors.red, false, (c) => c.push('/tools/songs')),
        _Tool('Ear Training', 'Latih telinga: interval, chord & melodi',
            colors.purple, true, (c) => c.push('/tools/ear-training')),
        _Tool('Jam Tracks', 'Drum backing track semua genre & tempo',
            colors.orange, false, (c) => c.push('/tools/metronome')),
        _Tool('Riff Recorder', 'Rekam ide riff-mu, AI baca notasinya',
            colors.blue, true, (c) => c.push('/tools/recorder')),
      ];

  @override
  Widget build(BuildContext context) {
    final tools = _tools(context.colors);
    return ScreenScaffold(
      gap: 16,
      children: [
        const ScreenTitle(
          'Tools',
          subtitle: 'Semua alat bantu latihanmu di satu tempat',
        ),
        Column(
          children: [
            for (var row = 0; row < tools.length; row += 2) ...[
              if (row > 0) const SizedBox(height: 11),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _ToolCard(tool: tools[row])),
                    const SizedBox(width: 11),
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
    return GlassCard(
      radius: 22,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      onTap: () => tool.action(context),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 92),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: tool.color.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(14),
              ),
              alignment: Alignment.center,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: tool.color,
                  borderRadius: BorderRadius.circular(tool.round ? 7 : 4),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(tool.name,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(
              tool.desc,
              style: TextStyle(
                fontSize: 11,
                height: 1.45,
                color: context.colors.cream.withValues(alpha: 0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
