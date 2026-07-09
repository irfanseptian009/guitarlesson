import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/theme/app_palette.dart';
import '../../core/i18n/strings.dart';
import '../../data/catalogs/songs_catalog.dart';
import '../../data/models/song.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/pill_chip.dart';
import '../../widgets/screen_scaffold.dart';

/// Song library with genre filtering.
class SongsScreen extends StatefulWidget {
  const SongsScreen({super.key});

  @override
  State<SongsScreen> createState() => _SongsScreenState();
}

class _SongsScreenState extends State<SongsScreen> {
  // Fixed album-art tile colors (solid accents, same on both themes).
  static const _artColors = [
    Color(0xFFF0521F),
    Color(0xFF3554D1),
    Color(0xFFEFA51D),
    Color(0xFF1FA05A),
    Color(0xFFEF6FAC),
    Color(0xFF7A4FD8),
  ];

  String _genre = 'Semua';

  @override
  Widget build(BuildContext context) {
    final songs = [
      for (final song in kSongCatalog)
        if (_genre == 'Semua' || song.genre.contains(_genre)) song,
    ];

    return ScreenScaffold(
      gap: 16,
      children: [
        SubScreenHeader(title: context.s.songs),
        Text(
          context.s.songsSubtitle,
          style: TextStyle(fontSize: 13, color: context.colors.creamDim),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final genre in kSongGenres)
              PillChip(
                label: genre == 'Semua' ? context.s.genreAll : genre,
                selected: _genre == genre,
                onTap: () => setState(() => _genre = genre),
              ),
          ],
        ),
        Column(
          children: [
            for (var i = 0; i < songs.length; i++) ...[
              if (i > 0) const SizedBox(height: 11),
              _SongRow(song: songs[i], artColor: _artColors[i % 6]),
            ],
          ],
        ),
      ],
    );
  }
}

class _SongRow extends StatelessWidget {
  const _SongRow({required this.song, required this.artColor});

  final Song song;
  final Color artColor;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      radius: 20,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      onTap: () => context.push('/tools/songs/${song.id}'),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: artColor,
              borderRadius: BorderRadius.circular(14),
            ),
            alignment: Alignment.center,
            child: Text(
              song.title[0],
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(song.title,
                    style: const TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w700)),
                const SizedBox(height: 3),
                Text(
                  '${song.artist} · ${song.genre}',
                  style: TextStyle(
                      fontSize: 11,
                      color: context.colors.cream.withValues(alpha: 0.5)),
                ),
              ],
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: song.level.color.withValues(alpha: 0.4)),
            ),
            child: Text(
              switch (song.level) {
                SongLevel.easy => context.s.levelEasy,
                SongLevel.medium => context.s.levelMedium,
                SongLevel.hard => context.s.levelHard,
              },
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: song.level.color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
