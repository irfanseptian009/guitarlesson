import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_palette.dart';
import '../../core/i18n/strings.dart';
import '../../core/music/chords.dart';
import '../../core/utils/practice_clock.dart';
import '../../data/models/progress_state.dart';
import '../../providers/app_providers.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/pill_chip.dart';
import '../../widgets/screen_scaffold.dart';
import 'widgets/chord_diagram.dart';

/// Chord library: detector banner, selected-chord detail with audio
/// preview, and the full catalog grid.
class ChordLibraryScreen extends ConsumerStatefulWidget {
  const ChordLibraryScreen({super.key});

  @override
  ConsumerState<ChordLibraryScreen> createState() =>
      _ChordLibraryScreenState();
}

class _ChordLibraryScreenState extends ConsumerState<ChordLibraryScreen> {
  ChordShape _selected = kChordCatalog.first;
  late final PracticeClock _clock;
  final TextEditingController _search = TextEditingController();

  /// Which instrument's chords are shown.
  Instrument _instrument = Instrument.guitar;

  /// null = all levels; otherwise filter by [ChordLevel].
  ChordLevel? _levelFilter;
  bool _favoritesOnly = false;

  @override
  void initState() {
    super.initState();
    final progress = ref.read(progressProvider.notifier);
    _clock = PracticeClock(
        (s) => progress.addPracticeSeconds(PracticeCategory.chords, s));
  }

  @override
  void dispose() {
    _clock.commit();
    _search.dispose();
    super.dispose();
  }

  List<ChordShape> get _visibleChords {
    final query = _search.text.trim().toLowerCase();
    final favorites = ref.read(progressProvider).favoriteChords;
    return [
      for (final chord in chordsFor(_instrument))
        if ((query.isEmpty || chord.name.toLowerCase().startsWith(query)) &&
            (_levelFilter == null || chord.level == _levelFilter) &&
            (!_favoritesOnly || favorites.contains(chord.name)))
          chord,
    ];
  }

  void _setInstrument(Instrument instrument) {
    if (_instrument == instrument) return;
    setState(() {
      _instrument = instrument;
      _levelFilter = null;
      _favoritesOnly = false;
      _selected = chordsFor(instrument).first;
    });
  }

  void _playSelected() {
    final a4 = ref.read(settingsProvider).a4Calibration;
    unawaited(
        ref.read(soundBankProvider).playStrum(_selected.midiNotes, a4: a4));
  }

  @override
  Widget build(BuildContext context) {
    final st = context.s;
    final progress = ref.watch(progressProvider);
    final mastered = progress.masteredChords;
    final favorites = progress.favoriteChords;
    final visible = _visibleChords;

    return ScreenScaffold(
      gap: 16,
      children: [
        SubScreenHeader(title: st.chordLibrary),

        // ---------------------------------------------- instrument tabs
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            color: context.colors.cream.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              for (final (instrument, label) in [
                (Instrument.guitar, st.instrumentGuitar),
                (Instrument.ukulele, st.instrumentUkulele),
                (Instrument.bass, st.instrumentBass),
              ])
                Expanded(
                  child: GestureDetector(
                    onTap: () => _setInstrument(instrument),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      padding: const EdgeInsets.symmetric(vertical: 9),
                      decoration: BoxDecoration(
                        color: _instrument == instrument
                            ? context.colors.navy
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(14),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        label,
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w800,
                          color: _instrument == instrument
                              ? context.colors.onNavy
                              : context.colors.creamDim,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),

        // ------------------------------------------------ detector banner
        GlassCard(
          radius: 22,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              context.colors.blue.withValues(alpha: 0.14),
              context.colors.cream.withValues(alpha: 0.04),
            ],
          ),
          border: context.colors.blue.withValues(alpha: 0.28),
          onTap: () => context.push('/tools/chord-detector'),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: context.colors.blue.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 10,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: context.colors.blue, width: 2),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(st.chordDetector,
                        style: const TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      st.detectorBannerDesc,
                      style: TextStyle(
                          fontSize: 12, color: context.colors.creamDim),
                    ),
                  ],
                ),
              ),
              Text(
                '${st.listen} ›',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: context.colors.blue,
                ),
              ),
            ],
          ),
        ),

        // ------------------------------------------------ selected detail
        GlassCard(
          radius: 24,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: _playSelected,
                child: ChordDiagram(
                    chord: _selected, width: 110, height: 128),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_selected.name,
                            style: const TextStyle(
                                fontSize: 34,
                                fontWeight: FontWeight.w800,
                                height: 1)),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => ref
                              .read(progressProvider.notifier)
                              .toggleFavoriteChord(_selected.name),
                          child: Icon(
                            favorites.contains(_selected.name)
                                ? Icons.star_rounded
                                : Icons.star_border_rounded,
                            size: 24,
                            color: favorites.contains(_selected.name)
                                ? context.colors.yellowDeep
                                : context.colors.creamFaint,
                          ),
                        ),
                        const SizedBox(width: 6),
                        if (mastered.contains(_selected.name))
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: context.colors.green
                                      .withValues(alpha: 0.45)),
                            ),
                            child: Text(
                              st.masteredBadge,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: context.colors.green,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selected.tipFor(st.lang),
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: context.colors.creamDim,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _ActionPill(
                            label: '▶ ${st.listen}', onTap: _playSelected),
                        _ActionPill(
                          label: st.checkWithAi,
                          onTap: () =>
                              context.push('/tools/chord-detector'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // ------------------------------------------------ search + filter
        TextField(
          controller: _search,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: st.searchChordsHint,
            hintStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: context.colors.creamFaint,
            ),
            prefixIcon:
                Icon(Icons.search_rounded, color: context.colors.creamFaint),
            suffixIcon: _search.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(Icons.close_rounded,
                        size: 18, color: context.colors.creamFaint),
                    onPressed: () {
                      _search.clear();
                      setState(() {});
                    },
                  ),
            filled: true,
            fillColor: context.colors.cream.withValues(alpha: 0.06),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: context.colors.cream.withValues(alpha: 0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: context.colors.cream.withValues(alpha: 0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: context.colors.orange, width: 1.5),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              PillChip(
                label: st.all,
                selected: _levelFilter == null && !_favoritesOnly,
                onTap: () => setState(() {
                  _levelFilter = null;
                  _favoritesOnly = false;
                }),
              ),
              const SizedBox(width: 8),
              PillChip(
                label: '★ ${st.favorites}',
                selected: _favoritesOnly,
                onTap: () => setState(() {
                  _favoritesOnly = !_favoritesOnly;
                  _levelFilter = null;
                }),
              ),
              for (final level in ChordLevel.values) ...[
                const SizedBox(width: 8),
                PillChip(
                  label: _levelName(level, st),
                  selected: _levelFilter == level,
                  onTap: () => setState(() {
                    _levelFilter = _levelFilter == level ? null : level;
                    _favoritesOnly = false;
                  }),
                ),
              ],
            ],
          ),
        ),

        // ------------------------------------------------ catalog grid
        if (visible.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                _favoritesOnly ? st.noFavorites : st.noMatches,
                style:
                    TextStyle(fontSize: 12, color: context.colors.creamFaint),
              ),
            ),
          )
        else
          GridView.count(
            crossAxisCount: 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 9,
            crossAxisSpacing: 9,
            childAspectRatio: 1.15,
            children: [
              for (final chord in visible)
                _ChordTile(
                  chord: chord,
                  selected: chord.name == _selected.name,
                  mastered: mastered.contains(chord.name),
                  favorite: favorites.contains(chord.name),
                  onTap: () {
                    setState(() => _selected = chord);
                    _playSelected();
                  },
                ),
            ],
          ),
      ],
    );
  }
}

String _levelName(ChordLevel level, S s) => switch (level) {
      ChordLevel.dasar => s.lang == 'id' ? 'Dasar' : 'Basic',
      ChordLevel.barre => 'Barre',
      ChordLevel.blues => 'Blues',
      ChordLevel.jazz => 'Jazz',
    };

class _ActionPill extends StatelessWidget {
  const _ActionPill({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: context.colors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: context.colors.orange.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: context.colors.orangeLight,
          ),
        ),
      ),
    );
  }
}

class _ChordTile extends StatelessWidget {
  const _ChordTile({
    required this.chord,
    required this.selected,
    required this.mastered,
    required this.favorite,
    required this.onTap,
  });

  final ChordShape chord;
  final bool selected;
  final bool mastered;
  final bool favorite;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color border;
    if (selected) {
      border = context.colors.cardBorderActive;
    } else if (mastered) {
      border = context.colors.green.withValues(alpha: 0.35);
    } else {
      border = context.colors.cardBorder;
    }
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? context.colors.cardFillActive : context.colors.cardFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Stack(
          children: [
            if (favorite)
              Positioned(
                top: 5,
                right: 7,
                child: Icon(Icons.star_rounded,
                    size: 11, color: context.colors.yellowDeep),
              ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    chord.name,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color:
                          selected ? context.colors.orangeLight : context.colors.cream,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _levelName(chord.level, context.s),
                    style: TextStyle(
                        fontSize: 10, color: context.colors.creamFaint),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
