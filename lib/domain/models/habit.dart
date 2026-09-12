class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.category,
    this.frequency = 'daily',
    this.targetDays,
    this.reminderEnabled = false,
    this.reminderTime,
    this.active = true,
    required this.createdAt,
  });

  final int id;
  final String name;
  final String category;
  final String frequency;
  final String? targetDays;
  final bool reminderEnabled;
  final int? reminderTime;
  final bool active;
  final int createdAt;

  Habit copyWith({
    int? id,
    String? name,
    String? category,
    String? frequency,
    String? targetDays,
    bool? reminderEnabled,
    int? reminderTime,
    bool? active,
    int? createdAt,
  }) {
    return Habit(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      frequency: frequency ?? this.frequency,
      targetDays: targetDays ?? this.targetDays,
      reminderEnabled: reminderEnabled ?? this.reminderEnabled,
      reminderTime: reminderTime ?? this.reminderTime,
      active: active ?? this.active,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
