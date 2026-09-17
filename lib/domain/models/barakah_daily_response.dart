enum BarakahAnswer { yes, somewhat, no, skip }

class BarakahDailyResponse {
  BarakahDailyResponse({
    required this.date,
    required this.promptId,
    required this.answer,
    required List<String> sourceIds,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  }) : sourceIds = List.unmodifiable(sourceIds);

  final String date;
  final String promptId;
  final BarakahAnswer answer;
  final List<String> sourceIds;
  final String? note;
  final int createdAt;
  final int updatedAt;
}
