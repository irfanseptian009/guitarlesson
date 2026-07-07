import 'package:flutter_test/flutter_test.dart';
import 'package:strumi/core/music/chords.dart';
import 'package:strumi/core/music/note_utils.dart';
import 'package:strumi/core/music/transpose.dart';
import 'package:strumi/core/music/tunings.dart';
import 'package:strumi/core/utils/dates.dart';
import 'package:strumi/data/models/progress_state.dart';

void main() {
  group('NoteUtils', () {
    test('A4 = 440 Hz maps to MIDI 69 with ~0 cents', () {
      final pitch = NoteUtils.pitchFromFrequency(440);
      expect(pitch, isNotNull);
      expect(pitch!.midi, 69);
      expect(pitch.name, 'A');
      expect(pitch.octave, 4);
      expect(pitch.cents.abs(), lessThan(0.01));
    });

    test('midiToFrequency inverts frequencyToMidi', () {
      expect(NoteUtils.midiToFrequency(69), closeTo(440, 1e-9));
      expect(NoteUtils.midiToFrequency(40), closeTo(82.407, 0.01));
      expect(NoteUtils.frequencyToMidi(261.626), closeTo(60, 0.001));
    });

    test('centsBetween is 0 for identical and ~100 for a semitone', () {
      expect(NoteUtils.centsBetween(440, 440), 0);
      expect(
        NoteUtils.centsBetween(NoteUtils.midiToFrequency(70), 440),
        closeTo(100, 1e-6),
      );
    });

    test('calibration shifts frequencies', () {
      expect(NoteUtils.midiToFrequency(69, a4: 442), 442);
    });
  });

  group('ChordShape', () {
    test('Am voicing produces the expected notes', () {
      final am = chordByName('Am');
      expect(am.midiNotes, [45, 52, 57, 60, 64]);
      expect(am.pitchClasses, {9, 0, 4}); // A C E
      expect(am.rootPitchClass, 9);
      expect(am.isMinor, isTrue);
    });

    test('G major voicing covers G B D', () {
      final g = chordByName('G');
      expect(g.pitchClasses, {7, 11, 2});
      expect(g.isMinor, isFalse);
    });

    test('F#m root parses the sharp', () {
      expect(chordByName('F#m').rootPitchClass, 6);
    });

    test('catalog voicings are internally consistent', () {
      for (final chord in kChordCatalog) {
        expect(chord.frets.length, 6);
        expect(chord.fingers.length, 6);
        expect(chord.midiNotes, isNotEmpty);
        expect(chord.pitchClasses.contains(chord.rootPitchClass), isTrue,
            reason: '${chord.name} must contain its root');
      }
    });
  });

  group('transposeChordName', () {
    test('shifts roots and keeps the quality suffix', () {
      expect(transposeChordName('Am', 2), 'Bm');
      expect(transposeChordName('Cmaj7', -1), 'Bmaj7');
      expect(transposeChordName('G', 5), 'C');
      expect(transposeChordName('F#m', 1), 'Gm');
      expect(transposeChordName('E', -4), 'C');
      expect(transposeChordName('D7', 0), 'D7');
    });

    test('wraps around the octave in both directions', () {
      expect(transposeChordName('B', 1), 'C');
      expect(transposeChordName('C', -1), 'B');
      expect(transposeChordName('A', -12), 'A');
    });
  });

  group('Tunings', () {
    test('standard tuning is E2 A2 D3 G3 B3 E4', () {
      expect(kTunings.first.labels, ['E2', 'A2', 'D3', 'G3', 'B3', 'E4']);
      expect(kTunings.first.frequencyOf(0), closeTo(82.407, 0.01));
    });
  });

  group('ProgressState', () {
    test('level math matches the design (level 7→8 costs 3500 XP)', () {
      expect(const ProgressState(xp: 0).level, 1);
      expect(ProgressState.cumulativeXpForLevel(2), 500);
      expect(ProgressState.xpForNextLevel(7), 3500);
      expect(const ProgressState(xp: 499).level, 1);
      expect(const ProgressState(xp: 500).level, 2);
    });

    test('streak counts consecutive practice days', () {
      final today = DateTime.now();
      String key(int daysAgo) =>
          Dates.key(today.subtract(Duration(days: daysAgo)));
      final progress = ProgressState(practiceSeconds: {
        key(0): {'tuner': 120},
        key(1): {'lesson': 300},
        key(2): {'metronome': 90},
        key(4): {'tuner': 60}, // gap at day 3 breaks the streak
      });
      expect(progress.streakDays, 3);
      expect(progress.totalSeconds, 570);
    });

    test('streak survives an empty today', () {
      final today = DateTime.now();
      String key(int daysAgo) =>
          Dates.key(today.subtract(Duration(days: daysAgo)));
      final progress = ProgressState(practiceSeconds: {
        key(1): {'lesson': 300},
        key(2): {'lesson': 300},
      });
      expect(progress.streakDays, 2);
    });

    test('averageAccuracy is 0 with no data', () {
      expect(const ProgressState().averageAccuracy, 0);
      expect(
        const ProgressState(accuracyLog: [80, 90]).averageAccuracy,
        85,
      );
    });

    test('json roundtrip preserves state', () {
      final original = ProgressState(
        xp: 1234,
        lessonProgress: const {'beg-01': 1.0, 'beg-02': 0.5},
        masteredChords: const {'Am', 'C'},
        openedSongs: const {'perfect'},
        practiceSeconds: const {
          '2026-07-06': {'tuner': 300},
        },
        accuracyLog: const [88.5],
        completedChallengeDates: const {'2026-07-06'},
        bestEarStreak: 7,
        savedRiffCount: 2,
      );
      final restored = ProgressState.fromJson(original.toJson());
      expect(restored.xp, original.xp);
      expect(restored.lessonProgress, original.lessonProgress);
      expect(restored.masteredChords, original.masteredChords);
      expect(restored.practiceSeconds, original.practiceSeconds);
      expect(restored.bestEarStreak, 7);
    });
  });
}
