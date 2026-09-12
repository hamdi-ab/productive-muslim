class BarakahEntry {
  const BarakahEntry({
    required this.id,
    required this.date,
    required this.sourceIds,
    this.promptId,
    this.intensity,
    this.note,
    this.skipped = false,
    required this.createdAt,
  });

  final int id;
  final String date;
  final List<String> sourceIds;
  final String? promptId;
  final int? intensity;
  final String? note;
  final bool skipped;
  final int createdAt;

  BarakahEntry copyWith({
    int? id,
    String? date,
    List<String>? sourceIds,
    String? promptId,
    int? intensity,
    String? note,
    bool? skipped,
    int? createdAt,
  }) {
    return BarakahEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      sourceIds: sourceIds ?? this.sourceIds,
      promptId: promptId ?? this.promptId,
      intensity: intensity ?? this.intensity,
      note: note ?? this.note,
      skipped: skipped ?? this.skipped,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}