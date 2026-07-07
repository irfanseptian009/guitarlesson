import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'core/audio/sound_bank.dart';
import 'core/services/reminder_service.dart';
import 'providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  final soundBank = await SoundBank.create();
  await ReminderService.instance.init();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        soundBankProvider.overrideWithValue(soundBank),
      ],
      child: const StrumiApp(),
    ),
  );
}
