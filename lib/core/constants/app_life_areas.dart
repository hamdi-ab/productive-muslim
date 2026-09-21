import 'dart:ui';

class AppLifeArea {
  AppLifeArea._();

  static const islam = Color(0xFF2E7D4F);
  static const family = Color(0xFFE67E22);
  static const work = Color(0xFF3498DB);
  static const personalDev = Color(0xFF9B59B6);

  static const Map<String, Color> all = {
    'islam': islam,
    'family': family,
    'work': work,
    'personal_dev': personalDev,
  };

  static const Map<String, String> labels = {
    'islam': 'Islam',
    'family': 'Family',
    'work': 'Work',
    'personal_dev': 'Personal Development',
  };
}
