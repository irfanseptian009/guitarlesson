import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/challenge/daily_challenge_screen.dart';
import '../features/chords/chord_detector_screen.dart';
import '../features/chords/chord_library_screen.dart';
import '../features/ear_training/ear_training_screen.dart';
import '../features/home/home_screen.dart';
import '../features/lessons/lesson_player_screen.dart';
import '../features/lessons/lessons_screen.dart';
import '../features/metronome/metronome_screen.dart';
import '../features/onboarding/onboarding_screen.dart';
import '../features/profile/profile_screen.dart';
import '../features/recorder/riff_recorder_screen.dart';
import '../features/shell/app_shell.dart';
import '../features/songs/song_detail_screen.dart';
import '../features/songs/songs_screen.dart';
import '../features/stats/practice_stats_screen.dart';
import '../features/tools/tools_screen.dart';
import '../features/tuner/tuner_screen.dart';
import '../providers/app_providers.dart';

/// Soft fade + slide-up used for every pushed sub-screen.
CustomTransitionPage<void> _subPage(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.03),
            end: Offset.zero,
          ).animate(curved),
          child: child,
        ),
      );
    },
  );
}

/// App navigation. Five stateful shell branches mirror the design's bottom
/// nav; sub-screens live inside their branch so the nav stays visible and
/// highlights the right tab (as the design's `tab()` logic does).
final routerProvider = Provider<GoRouter>((ref) {
  final onboardingDone =
      ref.read(sharedPreferencesProvider).getString('strumi.settings') != null;

  return GoRouter(
    initialLocation: onboardingDone ? '/home' : '/onboarding',
    redirect: (context, state) {
      final done = ref.read(settingsProvider).onboardingDone;
      final atOnboarding = state.matchedLocation == '/onboarding';
      if (!done && !atOnboarding) return '/onboarding';
      if (done && atOnboarding) return '/home';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
              routes: [
                GoRoute(
                  path: 'stats',
                  pageBuilder: (context, state) =>
                      _subPage(state, const PracticeStatsScreen()),
                ),
                GoRoute(
                  path: 'challenge',
                  pageBuilder: (context, state) =>
                      _subPage(state, const DailyChallengeScreen()),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/lessons',
              builder: (context, state) => const LessonsScreen(),
              routes: [
                GoRoute(
                  path: ':id',
                  pageBuilder: (context, state) => _subPage(state,
                      LessonPlayerScreen(lessonId: state.pathParameters['id']!)),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/tuner',
              builder: (context, state) => const TunerScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/tools',
              builder: (context, state) => const ToolsScreen(),
              routes: [
                GoRoute(
                  path: 'metronome',
                  pageBuilder: (context, state) =>
                      _subPage(state, const MetronomeScreen()),
                ),
                GoRoute(
                  path: 'chords',
                  pageBuilder: (context, state) =>
                      _subPage(state, const ChordLibraryScreen()),
                ),
                GoRoute(
                  path: 'chord-detector',
                  pageBuilder: (context, state) =>
                      _subPage(state, const ChordDetectorScreen()),
                ),
                GoRoute(
                  path: 'songs',
                  pageBuilder: (context, state) =>
                      _subPage(state, const SongsScreen()),
                  routes: [
                    GoRoute(
                      path: ':id',
                      pageBuilder: (context, state) => _subPage(state,
                          SongDetailScreen(songId: state.pathParameters['id']!)),
                    ),
                  ],
                ),
                GoRoute(
                  path: 'ear-training',
                  pageBuilder: (context, state) =>
                      _subPage(state, const EarTrainingScreen()),
                ),
                GoRoute(
                  path: 'recorder',
                  pageBuilder: (context, state) =>
                      _subPage(state, const RiffRecorderScreen()),
                ),
              ],
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ]),
        ],
      ),
    ],
  );
});
