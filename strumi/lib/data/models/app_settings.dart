import 'package:flutter/material.dart';

import '../../core/music/guitars.dart';

/// User-tweakable settings (Profile screen + onboarding).
@immutable
class AppSettings {
  const AppSettings({
    this.onboardingDone = false,
    this.userName = 'Gitaris Strumi',
    this.guitarKindId = 'acousticSteel',
    this.languageCode = 'en',
    this.avatarEmoji = '',
    this.avatarPath = '',
    this.dailyGoalMinutes = 30,
    this.reminderEnabled = true,
    this.reminderHour = 19,
    this.reminderMinute = 0,
    this.a4Calibration = 440.0,
    this.tuningIndex = 0,
    this.metronomeBpm = 96,
    this.metronomeSignatureIndex = 2,
    this.metronomeStyleIndex = 0,
    this.isDarkMode = false,
  });

  final bool onboardingDone;
  final String userName;

  /// [GuitarKind.id] of the player's instrument.
  final String guitarKindId;

  /// UI language: 'en' (default) or 'id'.
  final String languageCode;

  /// Emoji avatar; empty = fall back to photo/initials.
  final String avatarEmoji;

  /// File path of a gallery photo avatar; empty = none.
  final String avatarPath;
  final int dailyGoalMinutes;
  final bool reminderEnabled;
  final int reminderHour;
  final int reminderMinute;

  /// Concert pitch used by the tuner and all synthesized audio.
  final double a4Calibration;

  /// Index into [kTunings].
  final int tuningIndex;

  /// Last-used metronome state, restored on the next visit.
  final int metronomeBpm;
  final int metronomeSignatureIndex;
  final int metronomeStyleIndex;

  /// True = dark palette. Defaults to false (light is the default theme).
  final bool isDarkMode;

  int get weeklyGoalMinutes => dailyGoalMinutes * 7;

  GuitarKind get guitarKind => GuitarKind.fromStored(guitarKindId);

  TimeOfDay get reminderTime =>
      TimeOfDay(hour: reminderHour, minute: reminderMinute);

  /// Initials for the avatar badge (e.g. "Raka Pratama" → "RP").
  String get initials {
    final parts =
        userName.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty);
    if (parts.isEmpty) return 'S';
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  AppSettings copyWith({
    bool? onboardingDone,
    String? userName,
    String? guitarKindId,
    String? languageCode,
    String? avatarEmoji,
    String? avatarPath,
    int? dailyGoalMinutes,
    bool? reminderEnabled,
    int? reminderHour,
    int? reminderMinute,
    double? a4Calibration,
    int? tuningIndex,
    int? metronomeBpm,
    int? metronomeSignatureIndex,
    int? metronomeStyleIndex,
    bool? isDarkMode,
  }) {
    return AppSettings(
      onboardingDone: onboardingDone ?? this.onboardingDone,
      userName: userName ?? this.userName,
      guitarKindId: guitarKindId ?? this.guitarKindId,
      languageCode: languageCode ?? this.languageCode,
      avatarEmoji: avatarEmoji ?? this.avatarEmoji,
      avatarPath: avatarPath ?? this.avatarPath,
      dailyGoalMinutes: dailyGoalMinutes ?? this.dailyGoalMinutes,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      a4Calibration: a4Calibration ?? this.a4Calibration,
      tuningIndex: tuningIndex ?? this.tuningIndex,
      metronomeBpm: metronomeBpm ?? this.metronomeBpm,
      metronomeSignatureIndex:
          metronomeSignatureIndex ?? this.metronomeSignatureIndex,
      metronomeStyleIndex: metronomeStyleIndex ?? this.metronomeStyleIndex,
      isDarkMode: isDarkMode ?? this.isDarkMode,
    );
  }

  Map<String, dynamic> toJson() => {
        'onboardingDone': onboardingDone,
        'userName': userName,
        'guitarKindId': guitarKindId,
        'languageCode': languageCode,
        'avatarEmoji': avatarEmoji,
        'avatarPath': avatarPath,
        'dailyGoalMinutes': dailyGoalMinutes,
        'reminderEnabled': reminderEnabled,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'a4Calibration': a4Calibration,
        'tuningIndex': tuningIndex,
        'metronomeBpm': metronomeBpm,
        'metronomeSignatureIndex': metronomeSignatureIndex,
        'metronomeStyleIndex': metronomeStyleIndex,
        'isDarkMode': isDarkMode,
      };

  factory AppSettings.fromJson(Map<String, dynamic> json) => AppSettings(
        onboardingDone: json['onboardingDone'] as bool? ?? false,
        userName: json['userName'] as String? ?? 'Gitaris Strumi',
        // Falls back to the legacy 'guitarType' label for older installs.
        guitarKindId: GuitarKind.fromStored(json['guitarKindId'] as String? ??
                json['guitarType'] as String?)
            .id,
        languageCode: json['languageCode'] as String? ?? 'en',
        avatarEmoji: json['avatarEmoji'] as String? ?? '',
        avatarPath: json['avatarPath'] as String? ?? '',
        dailyGoalMinutes: json['dailyGoalMinutes'] as int? ?? 30,
        reminderEnabled: json['reminderEnabled'] as bool? ?? true,
        reminderHour: json['reminderHour'] as int? ?? 19,
        reminderMinute: json['reminderMinute'] as int? ?? 0,
        a4Calibration: (json['a4Calibration'] as num?)?.toDouble() ?? 440.0,
        tuningIndex: json['tuningIndex'] as int? ?? 0,
        metronomeBpm: json['metronomeBpm'] as int? ?? 96,
        metronomeSignatureIndex:
            json['metronomeSignatureIndex'] as int? ?? 2,
        metronomeStyleIndex: json['metronomeStyleIndex'] as int? ?? 0,
        isDarkMode: json['isDarkMode'] as bool? ?? false,
      );
}
