import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/theme/app_colors.dart';
import '../../core/audio/metronome_engine.dart';
import '../../core/audio/sound_bank.dart';
import '../../core/music/chords.dart';
import '../../core/music/transpose.dart';
import '../../core/utils/practice_clock.dart';
import '../../data/catalogs/songs_catalog.dart';
import '../../data/models/progress_state.dart';
import '../../data/models/song.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/primary_button.dart';
import '../../widgets/screen_scaffold.dart';
import '../chords/widgets/chord_diagram.dart';

/// Song detail: chord chart that actually plays — a metronome drives bar
/// changes while the sound bank strums each chord, with slow-downer speeds.
class SongDetailScreen extends ConsumerStatefulWidget {
  const SongDetailScreen({super.key, required this.songId});

  final String songId;

  @override
  ConsumerState<SongDetailScreen> createState() => _SongDetailScreenState();
}

class _SongDetailScreenState extends ConsumerState<SongDetailScreen> {
  late final Song _song = songById(widget.songId);
  late final MetronomeEngine _engine;
  late final SoundBank _soundBank;
  late final PracticeClock _clock;
  late final List<String> _flatBars = [
    for (final section in _song.sections) ...section.bars,
  ];

  final ScrollController _scroll = ScrollController();
  late final List<GlobalKey> _sectionKeys =
      [for (final _ in _song.sections) GlobalKey()];

  double _speed = 1.0;
  bool _playing = false;
  int _barIndex = -1;

  /// Count-in beats remaining before the first bar plays.
  int _countInBeatsLeft = 0;

  /// Restart from the top when the chart ends.
  bool _loop = false;

  /// Semitone offset applied to every chord name (−6..+6).
  int _transpose = 0;

  /// Chord name after transposition.
  String _shifted(String name) => transposeChordName(name, _transpose);

  /// Plays [name] (original chart name) shifted by the transpose offset —
  /// works even when the transposed chord has no catalog voicing.
  void _strumChord(String name) {
    if (!kChordCatalog.any((c) => c.name == name)) return;
    final a4 = ref.read(settingsProvider).a4Calibration;
    final midiNotes = [
      for (final m in chordByName(name).midiNotes) m + _transpose,
    ];
    unawaited(_soundBank.playStrum(midiNotes, a4: a4));
  }

  @override
  void initState() {
    super.initState();
    _soundBank = ref.read(soundBankProvider);
    _engine = MetronomeEngine(_soundBank, onBeat: _onBeat);
    final progress = ref.read(progressProvider.notifier);
    _clock = PracticeClock(
        (s) => progress.addPracticeSeconds(PracticeCategory.songs, s));
    Future.microtask(
        () => ref.read(progressProvider.notifier).openSong(_song.id));
  }

  @override
  void dispose() {
    _clock.commit();
    _engine.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _onBeat(int beat) {
    if (!mounted || !_playing) return;
    // One bar of count-in clicks before the chart starts.
    if (_countInBeatsLeft > 0) {
      setState(() => _countInBeatsLeft--);
      return;
    }
    if (beat != 0) return;
    var next = _barIndex + 1;
    if (next >= _flatBars.length) {
      if (_loop) {
        next = 0;
      } else {
        _stop();
        return;
      }
    }
    setState(() => _barIndex = next);
    _strumChord(_flatBars[next]);
    _autoScroll(next);
  }

  void _autoScroll(int barIndex) {
    var offset = 0;
    for (var i = 0; i < _song.sections.length; i++) {
      final bars = _song.sections[i].bars.length;
      if (barIndex < offset + bars) {
        final ctx = _sectionKeys[i].currentContext;
        if (ctx != null) {
          Scrollable.ensureVisible(
            ctx,
            alignment: 0.2,
            duration: const Duration(milliseconds: 350),
            curve: Curves.easeOut,
          );
        }
        return;
      }
      offset += bars;
    }
  }

  void _play() {
    _engine
      ..style = DrumStyle.click
      ..signature = TimeSignature.fourFour
      ..bpm = (_song.bpm * _speed).round();
    setState(() {
      _playing = true;
      _barIndex = -1;
      _countInBeatsLeft = 4;
    });
    _engine.start();
  }

  void _stop() {
    _engine.stop();
    if (mounted) {
      setState(() {
        _playing = false;
        _barIndex = -1;
        _countInBeatsLeft = 0;
      });
    }
  }

  void _setSpeed(double speed) {
    setState(() => _speed = speed);
    _engine.bpm = (_song.bpm * speed).round();
  }

  /// First flat-bar index of every section.
  late final List<int> _sectionStarts = () {
    final starts = <int>[];
    var offset = 0;
    for (final section in _song.sections) {
      starts.add(offset);
      offset += section.bars.length;
    }
    return starts;
  }();

  @override
  Widget build(BuildContext context) {
    return ScreenScaffold(
      gap: 16,
      scrollController: _scroll,
      children: [
        SubScreenHeader(
          overline: '${_song.artist} · ${_song.genre}',
          title: _song.title,
          trailing: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: _song.level.color.withValues(alpha: 0.4)),
            ),
            child: Text(
              _song.level.label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: _song.level.color,
              ),
            ),
          ),
        ),

        // ------------------------------------------------ info chips
        Row(
          children: [
            _InfoChip('Kunci ${_song.key}'),
            const SizedBox(width: 8),
            _InfoChip('${_song.bpm} BPM'),
            const SizedBox(width: 8),
            Expanded(child: _InfoChip(_song.strumPattern)),
          ],
        ),

        // ------------------------------------------------ chords used
        const Text('Chord yang dipakai',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              for (final name in _song.chordNames)
                if (kChordCatalog.any((c) => c.name == name))
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GlassCard(
                      radius: 18,
                      padding: const EdgeInsets.all(10),
                      onTap: () => _strumChord(name),
                      child: Column(
                        children: [
                          if (kChordCatalog
                              .any((c) => c.name == _shifted(name)))
                            ChordDiagram(
                                chord: chordByName(_shifted(name)),
                                width: 84,
                                height: 100)
                          else
                            SizedBox(
                              width: 84,
                              height: 100,
                              child: Center(
                                child: Text(
                                  'tanpa\ndiagram',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: 10,
                                      color: AppColors.creamFaint),
                                ),
                              ),
                            ),
                          const SizedBox(height: 6),
                          Text(_shifted(name),
                              style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w800)),
                        ],
                      ),
                    ),
                  ),
            ],
          ),
        ),

        // ------------------------------------------------ playback controls
        Row(
          children: [
            Expanded(
              child: PrimaryButton(
                label: _playing
                    ? (_countInBeatsLeft > 0
                        ? 'SIAP… $_countInBeatsLeft'
                        : 'BERHENTI')
                    : 'MAINKAN CHART',
                height: 50,
                fontSize: 14,
                onTap: _playing ? _stop : _play,
              ),
            ),
            const SizedBox(width: 10),
            for (final speed in [0.5, 0.75, 1.0])
              Padding(
                padding: const EdgeInsets.only(left: 6),
                child: GestureDetector(
                  onTap: () => _setSpeed(speed),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: _speed == speed
                          ? AppColors.orange
                          : Colors.white.withValues(alpha: 0.07),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Text(
                      speed == 1.0 ? '1x' : '${speed}x',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _speed == speed
                            ? AppColors.onOrange
                            : AppColors.cream.withValues(alpha: 0.7),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),

        // ------------------------------------------ transpose + loop row
        GlassCard(
          radius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              Text(
                'Transpose',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.cream.withValues(alpha: 0.7),
                ),
              ),
              const SizedBox(width: 10),
              _StepButton(
                label: '−',
                onTap: () => setState(
                    () => _transpose = (_transpose - 1).clamp(-6, 6)),
              ),
              SizedBox(
                width: 40,
                child: Text(
                  _transpose == 0
                      ? '0'
                      : '${_transpose > 0 ? '+' : ''}$_transpose',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: AppColors.orangeLight,
                  ),
                ),
              ),
              _StepButton(
                label: '+',
                onTap: () => setState(
                    () => _transpose = (_transpose + 1).clamp(-6, 6)),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _loop = !_loop),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 13, vertical: 7),
                  decoration: BoxDecoration(
                    color: _loop
                        ? AppColors.cardFillActive
                        : AppColors.cardFill,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _loop
                          ? AppColors.cardBorderActive
                          : AppColors.cardBorder,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.repeat_rounded,
                        size: 14,
                        color: _loop
                            ? AppColors.orangeLight
                            : AppColors.creamFaint,
                      ),
                      const SizedBox(width: 5),
                      Text(
                        'Loop',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _loop
                              ? AppColors.orangeLight
                              : AppColors.cream.withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        // ------------------------------------------------ chart sections
        for (var s = 0; s < _song.sections.length; s++)
          Builder(
            builder: (context) {
              final section = _song.sections[s];
              final start = _sectionStarts[s];
              return GlassCard(
                key: _sectionKeys[s],
                radius: 22,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      section.name.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                        color: AppColors.orangeLight,
                      ),
                    ),
                    const SizedBox(height: 12),
                    GridView.count(
                      crossAxisCount: 4,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 8,
                      crossAxisSpacing: 8,
                      childAspectRatio: 1.9,
                      children: [
                        for (var b = 0; b < section.bars.length; b++)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 150),
                            decoration: BoxDecoration(
                              color: _barIndex == start + b
                                  ? AppColors.orange.withValues(alpha: 0.2)
                                  : Colors.white.withValues(alpha: 0.05),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: _barIndex == start + b
                                    ? AppColors.orange
                                        .withValues(alpha: 0.6)
                                    : Colors.transparent,
                              ),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              _shifted(section.bars[b]),
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700),
                            ),
                          ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
      ],
    );
  }
}

class _StepButton extends StatelessWidget {
  const _StepButton({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.08),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(label,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.cardFill,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: AppColors.cream.withValues(alpha: 0.7),
        ),
      ),
    );
  }
}
