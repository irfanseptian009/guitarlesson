import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:strumi/widgets/glass_card.dart';
import 'package:strumi/widgets/pill_chip.dart';
import 'package:strumi/widgets/primary_button.dart';

void main() {
  Widget wrap(Widget child) =>
      MaterialApp(home: Scaffold(body: Center(child: child)));

  testWidgets('GlassCard renders child and handles taps', (tester) async {
    var tapped = false;
    await tester.pumpWidget(wrap(
      GlassCard(onTap: () => tapped = true, child: const Text('halo')),
    ));
    expect(find.text('halo'), findsOneWidget);
    await tester.tap(find.text('halo'));
    expect(tapped, isTrue);
  });

  testWidgets('PillChip shows label and reacts to taps', (tester) async {
    var selected = false;
    await tester.pumpWidget(wrap(
      StatefulBuilder(
        builder: (context, setState) => PillChip(
          label: 'Beginner',
          selected: selected,
          onTap: () => setState(() => selected = true),
        ),
      ),
    ));
    expect(find.text('Beginner'), findsOneWidget);
    await tester.tap(find.text('Beginner'));
    await tester.pump();
    expect(selected, isTrue);
  });

  testWidgets('PrimaryButton fires onTap', (tester) async {
    var pressed = 0;
    await tester.pumpWidget(wrap(
      PrimaryButton(label: 'MULAI BELAJAR', onTap: () => pressed++),
    ));
    expect(find.text('MULAI BELAJAR'), findsOneWidget);
    await tester.tap(find.text('MULAI BELAJAR'));
    expect(pressed, 1);
  });
}
