import 'dart:ui';

class AppLifeArea {
  AppLifeArea._();

  // 3 Spheres of Islamic Productivity (Productive Muslim Framework)
  static const spiritual = Color(0xFF2E7D4F);
  static const physical = Color(0xFFE67E22);
  static const social = Color(0xFF3498DB);
  static const personalDev = Color(0xFF9B59B6);

  // Backward-compatible life area aliases
  static const islam = spiritual;
  static const family = social;
  static const work = social;

  static const Map<String, Color> all = {
    'spiritual': spiritual,
    'physical': physical,
    'social': social,
    'personal_dev': personalDev,
    'islam': islam,
    'family': family,
    'work': work,
  };

  static const Map<String, String> labels = {
    'spiritual': 'Spiritual Sphere',
    'physical': 'Physical Sphere',
    'social': 'Social Sphere',
    'personal_dev': 'Personal Development',
    'islam': 'Islam',
    'family': 'Family',
    'work': 'Work',
  };

  static String sphereOf(String category) {
    return switch (category) {
      'spiritual' || 'islam' => 'spiritual',
      'physical' || 'personal_dev' => 'physical',
      'social' || 'family' || 'work' => 'social',
      _ => 'spiritual',
    };
  }
}
