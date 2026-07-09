import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app/theme/app_palette.dart';
import '../core/i18n/strings.dart';
import '../core/music/guitars.dart';
import '../providers/app_providers.dart';
import 'capi_deco.dart';
import 'pressable_scale.dart';

/// Bottom sheet for choosing the player's instrument. Each option shows
/// its Capi illustration; picking one updates settings (and with it the
/// hero artwork and instrument-specific lessons).
Future<void> showGuitarPicker(BuildContext context, WidgetRef ref) {
  final colors = context.colors;
  return showModalBottomSheet<void>(
    context: context,
    // Root navigator so the sheet covers the shell's floating nav bar.
    useRootNavigator: true,
    backgroundColor: colors.surfaceDeep,
    isScrollControlled: true,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
    ),
    builder: (sheetContext) => const _GuitarPickerSheet(),
  );
}

class _GuitarPickerSheet extends ConsumerWidget {
  const _GuitarPickerSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final s = context.s;
    final selected = ref.watch(settingsProvider).guitarKind;
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottomInset + 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: colors.creamGhost,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Text(s.chooseGuitar,
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(width: 8),
              Sparkle(color: colors.pinkStrong, size: 15),
            ],
          ),
          const SizedBox(height: 4),
          Text(s.lessonsAdapt,
              style: TextStyle(fontSize: 12.5, color: colors.creamDim)),
          const SizedBox(height: 16),
          SizedBox(
            height: 168,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: GuitarKind.values.length,
              separatorBuilder: (_, _) => const SizedBox(width: 10),
              itemBuilder: (context, i) {
                final kind = GuitarKind.values[i];
                return GuitarKindChip(
                  kind: kind,
                  selected: kind == selected,
                  onTap: () {
                    ref
                        .read(settingsProvider.notifier)
                        .update((st) => st.copyWith(guitarKindId: kind.id));
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          // Tagline of the currently selected kind.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: colors.yellow.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              selected.tagline(s.lang),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: colors.cream,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// A single selectable instrument card — the illustrated thumbnail + its
/// label. Shared by the [showGuitarPicker] sheet and the onboarding
/// screen's inline guitar chooser.
class GuitarKindChip extends StatelessWidget {
  const GuitarKindChip({
    super.key,
    required this.kind,
    required this.selected,
    required this.onTap,
    this.width = 118,
  });

  final GuitarKind kind;
  final bool selected;
  final VoidCallback onTap;
  final double width;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final lang = context.s.lang;
    return PressableScale(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: width,
        padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
        decoration: BoxDecoration(
          color: selected ? colors.navy : colors.cardFill,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: selected ? colors.navy : colors.cardBorder,
            width: 1.4,
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: GuitarIllustration(
                kind: kind,
                width: width * 0.62,
                height: width * 0.88,
                blobColor: selected
                    ? colors.yellow
                    : colors.yellow.withValues(alpha: 0.55),
                bodyColor: colors.pink,
              ),
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                kind.label(lang),
                maxLines: 1,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  color: selected ? colors.onNavy : colors.cream,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
