class AdhkarSessionRecord {
  final String collectionId;
  final int lastPageIndex;
  final Map<String, int> counts;
  final DateTime lastAccessedAt;
  final bool isCompleted;

  const AdhkarSessionRecord({
    required this.collectionId,
    required this.lastPageIndex,
    required this.counts,
    required this.lastAccessedAt,
    this.isCompleted = false,
  });

  AdhkarSessionRecord copyWith({
    String? collectionId,
    int? lastPageIndex,
    Map<String, int>? counts,
    DateTime? lastAccessedAt,
    bool? isCompleted,
  }) {
    return AdhkarSessionRecord(
      collectionId: collectionId ?? this.collectionId,
      lastPageIndex: lastPageIndex ?? this.lastPageIndex,
      counts: counts ?? this.counts,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }
}
