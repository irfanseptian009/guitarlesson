import 'package:flutter_test/flutter_test.dart';
import 'package:strumi/core/music/chords.dart';
import 'package:strumi/data/catalogs/lessons_catalog.dart';
import 'package:strumi/data/models/lesson.dart';

void main() {
  group('lessons catalog', () {
    test('ids are unique', () {
      final ids = kLessonCatalog.map((l) => l.id).toList();
      expect(ids.toSet().length, ids.length);
    });

    test('every track has a full learning path', () {
      expect(lessonsInTrack(LessonTrack.beginner).length,
          greaterThanOrEqualTo(6));
      expect(lessonsInTrack(LessonTrack.intermediate).length,
          greaterThanOrEqualTo(6));
      expect(lessonsInTrack(LessonTrack.advanced).length,
          greaterThanOrEqualTo(5));
    });

    test('all practice chords exist in the chord catalog', () {
      for (final lesson in kLessonCatalog) {
        for (final chord in lesson.practiceChords) {
          expect(() => chordByName(chord), returnsNormally,
              reason: '${lesson.id} references unknown chord "$chord"');
        }
      }
    });

    test('every lesson has content to show', () {
      for (final lesson in kLessonCatalog) {
        expect(lesson.summary, isNotEmpty, reason: lesson.id);
        final hasContent = lesson.theoryPoints.isNotEmpty ||
            lesson.practiceChords.isNotEmpty ||
            lesson.tab != null;
        expect(hasContent, isTrue,
            reason: '${lesson.id} has no theory, chords, or tab');
      }
    });

    test('tab lines always contain six cells', () {
      for (final lesson in kLessonCatalog) {
        for (final line in lesson.tab ?? const <TabLine>[]) {
          expect(line.notes.length, 6, reason: lesson.id);
        }
      }
    });

    test('lessonById resolves every catalog entry', () {
      for (final lesson in kLessonCatalog) {
        expect(lessonById(lesson.id).title, lesson.title);
      }
    });

    test('every lesson has English titles and summaries', () {
      for (final lesson in kLessonCatalog) {
        expect(lesson.titleEn, isNotNull, reason: lesson.id);
        expect(lesson.titleEn, isNotEmpty, reason: lesson.id);
        expect(lesson.summaryEn, isNotNull, reason: lesson.id);
        expect(lesson.summaryEn, isNotEmpty, reason: lesson.id);
        if (lesson.theoryPoints.isNotEmpty) {
          expect(lesson.theoryPointsEn.length, lesson.theoryPoints.length,
              reason: '${lesson.id} theoryPointsEn count mismatch');
        }
      }
    });

    test('instrument-specific guitar tags are valid GuitarKind ids', () {
      const validIds = {
        'acousticSteel', 'acousticNylon', 'electric', 'bass', 'ukulele',
      };
      for (final lesson in kLessonCatalog) {
        if (lesson.guitar != null) {
          expect(validIds.contains(lesson.guitar), isTrue,
              reason: '${lesson.id} has unknown guitar tag "${lesson.guitar}"');
        }
      }
    });
  });

  group('chord catalog', () {
    test('every chord has an English tip', () {
      for (final chord in kChordCatalog) {
        expect(chord.tipEn, isNotNull,
            reason: '${chord.name} (${chord.instrument.name})');
        expect(chord.tipEn, isNotEmpty,
            reason: '${chord.name} (${chord.instrument.name})');
      }
    });
  });
}
