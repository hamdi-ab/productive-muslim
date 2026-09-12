class IntentionEntry {
  const IntentionEntry({
    required this.id,
    required this.date,
    required this.title,
    this.statement,
    this.category,
    this.completed = false,
    this.reflection,
    required this.createdAt,
  });

  final int id;
  final String date;
  final String title;
  final String? statement;
  final String? category;
  final bool completed;
  final String? reflection;
  final int createdAt;

  IntentionEntry copyWith({
    int? id,
    String? date,
    String? title,
    String? statement,
    String? category,
    bool? completed,
    String? reflection,
    int? createdAt,
  }) {
    return IntentionEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      title: title ?? this.title,
      statement: statement ?? this.statement,
      category: category ?? this.category,
      completed: completed ?? this.completed,
      reflection: reflection ?? this.reflection,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
