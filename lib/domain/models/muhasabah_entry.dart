class MuhasabahEntry {
  const MuhasabahEntry({
    required this.id,
    required this.date,
    this.promptId,
    this.promptText,
    required this.content,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });

  final int id;
  final String date;
  final String? promptId;
  final String? promptText;
  final String content;
  final String? tags;
  final int createdAt;
  final int updatedAt;

  MuhasabahEntry copyWith({
    int? id,
    String? date,
    String? promptId,
    String? promptText,
    String? content,
    String? tags,
    int? createdAt,
    int? updatedAt,
  }) {
    return MuhasabahEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      promptId: promptId ?? this.promptId,
      promptText: promptText ?? this.promptText,
      content: content ?? this.content,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
