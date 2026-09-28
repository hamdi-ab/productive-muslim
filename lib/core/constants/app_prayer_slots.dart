import 'package:flutter/material.dart';

class BarakahSlot {
  final String id;
  final String labelKey;
  final String descriptionKey;
  final IconData icon;
  final int defaultStartMinutes;
  final int defaultEndMinutes;

  const BarakahSlot({
    required this.id,
    required this.labelKey,
    required this.descriptionKey,
    required this.icon,
    required this.defaultStartMinutes,
    required this.defaultEndMinutes,
  });

  static const earlyMorning = BarakahSlot(
    id: 'early_morning',
    labelKey: 'slotEarlyMorning',
    descriptionKey: 'slotEarlyMorningDesc',
    icon: Icons.wb_twilight_rounded,
    defaultStartMinutes: 330, // 5:30 AM
    defaultEndMinutes: 420, // 7:00 AM
  );

  static const duha = BarakahSlot(
    id: 'duha',
    labelKey: 'slotDuha',
    descriptionKey: 'slotDuhaDesc',
    icon: Icons.wb_sunny_rounded,
    defaultStartMinutes: 540, // 9:00 AM
    defaultEndMinutes: 690, // 11:30 AM
  );

  static const dhuhr = BarakahSlot(
    id: 'dhuhr',
    labelKey: 'slotDhuhr',
    descriptionKey: 'slotDhuhrDesc',
    icon: Icons.light_mode_rounded,
    defaultStartMinutes: 780, // 1:00 PM
    defaultEndMinutes: 900, // 3:00 PM
  );

  static const asr = BarakahSlot(
    id: 'asr',
    labelKey: 'slotAsr',
    descriptionKey: 'slotAsrDesc',
    icon: Icons.wb_sunny_outlined,
    defaultStartMinutes: 990, // 4:30 PM
    defaultEndMinutes: 1080, // 6:00 PM
  );

  static const maghrib = BarakahSlot(
    id: 'maghrib',
    labelKey: 'slotMaghrib',
    descriptionKey: 'slotMaghribDesc',
    icon: Icons.nights_stay_outlined,
    defaultStartMinutes: 1110, // 6:30 PM
    defaultEndMinutes: 1185, // 7:45 PM
  );

  static const isha = BarakahSlot(
    id: 'isha',
    labelKey: 'slotIsha',
    descriptionKey: 'slotIshaDesc',
    icon: Icons.bedtime_rounded,
    defaultStartMinutes: 1230, // 8:30 PM
    defaultEndMinutes: 1320, // 10:00 PM
  );

  static const List<BarakahSlot> all = [
    earlyMorning,
    duha,
    dhuhr,
    asr,
    maghrib,
    isha,
  ];

  static BarakahSlot? fromId(String? id) {
    if (id == null) return null;
    return all.cast<BarakahSlot?>().firstWhere(
      (slot) => slot?.id == id,
      orElse: () => null,
    );
  }
}
