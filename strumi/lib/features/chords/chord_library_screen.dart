import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_colors.dart';
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
      for (final chord in kChordCatalog)
        if ((query.isEmpty || chord.name.toLowerCase().startsWith(query)) &&
            (_levelFilter == null || chord.level == _levelFilter) &&
            (!_favoritesOnly || favorites.contains(chord.name)))
          chord,
    ];
  }

  void _playSelected() {
    final a4 = ref.read(settingsProvider).a4Calibration;
    unawaited(
        ref.read(soundBankProvider).playStrum(_selected.midiNotes, a4: a4));
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(progressProvider);
    final mastered = progress.masteredChords;
    final favorites = progress.favoriteChords;
    final visible = _visibleChords;

    return ScreenScaffold(
      gap: 16,
      children: [
        const SubScreenHeader(title: 'Chord Library'),

        // ------------------------------------------------ detector banner
        GlassCard(
          radius: 22,
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.blue.withValues(alpha: 0.14),
              Colors.white.withValues(alpha: 0.04),
            ],
          ),
          border: AppColors.blue.withValues(alpha: 0.28),
          onTap: () => context.push('/tools/chord-detector'),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.blue.withValues(alpha: 0.18),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: Container(
                  width: 10,
                  height: 18,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    border: Border.all(color: AppColors.blue, width: 2),
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Chord Detector',
                        style: TextStyle(
                            fontSize: 14, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text(
                      'Mainkan chord apa pun — AI menebak namanya',
                      style: TextStyle(
                          fontSize: 12, color: AppColors.creamDim),
                    ),
                  ],
                ),
              ),
              const Text(
                'Dengar ›',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: AppColors.blue,
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
                                ? AppColors.yellow
                                : AppColors.creamFaint,
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
                                  color: AppColors.green
                                      .withValues(alpha: 0.45)),
                            ),
                            child: const Text(
                              'Dikuasai ✓',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: AppColors.green,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _selected.tip,
                      style: TextStyle(
                        fontSize: 12,
                        height: 1.5,
                        color: AppColors.creamDim,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _ActionPill(label: '▶ Dengar', onTap: _playSelected),
                        const SizedBox(width: 8),
                        _ActionPill(
                          label: 'Cek dengan AI',
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
            hintText: 'Cari chord… (Am, F, Cmaj7)',
            hintStyle: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: AppColors.creamFaint,
            ),
            prefixIcon:
                Icon(Icons.search_rounded, color: AppColors.creamFaint),
            suffixIcon: _search.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(Icons.close_rounded,
                        size: 18, color: AppColors.creamFaint),
                    onPressed: () {
                      _search.clear();
                      setState(() {});
                    },
                  ),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.06),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  BorderSide(color: Colors.white.withValues(alpha: 0.12)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide:
                  const BorderSide(color: AppColors.orange, width: 1.5),
            ),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              PillChip(
                label: 'Semua',
                selected: _levelFilter == null && !_favoritesOnly,
                onTap: () => setState(() {
                  _levelFilter = null;
                  _favoritesOnly = false;
                }),
              ),
              const SizedBox(width: 8),
              PillChip(
                label: '★ Favorit',
                selected: _favoritesOnly,
                onTap: () => setState(() {
                  _favoritesOnly = !_favoritesOnly;
                  _levelFilter = null;
                }),
              ),
              for (final level in ChordLevel.values) ...[
                const SizedBox(width: 8),
                PillChip(
                  label: level.label,
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
                _favoritesOnly
                    ? 'Belum ada chord favorit — bintangi dari kartu detail.'
                    : 'Tidak ada chord yang cocok.',
                style:
                    TextStyle(fontSize: 12, color: AppColors.creamFaint),
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
          color: AppColors.orange.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border:
              Border.all(color: AppColors.orange.withValues(alpha: 0.4)),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppColors.orangeLight,
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
      border = AppColors.cardBorderActive;
    } else if (mastered) {
      border = AppColors.green.withValues(alpha: 0.35);
    } else {
      border = AppColors.cardBorder;
    }
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        decoration: BoxDecoration(
          color: selected ? AppColors.cardFillActive : AppColors.cardFill,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: border),
        ),
        child: Stack(
          children: [
            if (favorite)
              const Positioned(
                top: 5,
                right: 7,
                child: Icon(Icons.star_rounded,
                    size: 11, color: AppColors.yellow),
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
                          selected ? AppColors.orangeLight : AppColors.cream,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    chord.level.label,
                    style:
                        TextStyle(fontSize: 10, color: AppColors.creamFaint),
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
