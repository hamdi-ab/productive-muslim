class Task {
  const Task({
    required this.id,
    required this.title,
    required this.lifeArea,
    this.startMinutes,
    this.endMinutes,
    required this.date,
    this.repeatDaily = false,
    this.repeatWeekly = false,
    this.repeatDays,
    this.notes,
    this.completed = false,
    this.completedAt,
    required this.createdAt,
    this.active = true,
  });

  final int id;
  final String title;
  final String lifeArea;
  final int? startMinutes;
  final int? endMinutes;
  final String date;
  final bool repeatDaily;
  final bool repeatWeekly;
  final String? repeatDays;
  final String? notes;
  final bool completed;
  final int? completedAt;
  final int createdAt;
  final bool active;

  Task copyWith({
    int? id,
    String? title,
    String? lifeArea,
    int? startMinutes,
    int? endMinutes,
    String? date,
    bool? repeatDaily,
    bool? repeatWeekly,
    String? repeatDays,
    String? notes,
    bool? completed,
    int? completedAt,
    int? createdAt,
    bool? active,
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      lifeArea: lifeArea ?? this.lifeArea,
      startMinutes: startMinutes ?? this.startMinutes,
      endMinutes: endMinutes ?? this.endMinutes,
      date: date ?? this.date,
      repeatDaily: repeatDaily ?? this.repeatDaily,
      repeatWeekly: repeatWeekly ?? this.repeatWeekly,
      repeatDays: repeatDays ?? this.repeatDays,
      notes: notes ?? this.notes,
      completed: completed ?? this.completed,
      completedAt: completedAt ?? this.completedAt,
      createdAt: createdAt ?? this.createdAt,
      active: active ?? this.active,
    );
  }
}