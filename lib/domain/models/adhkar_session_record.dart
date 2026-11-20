class AdhkarSessionRecord {
  final String collectionId;
  final int lastPageIndex;
  final Map<String, int> counts;
  final DateTime lastAccessedAt;
  final bool isCompleted;
  final Set<String> skippedItemIds;

  const AdhkarSessionRecord({
    required this.collectionId,
    required this.lastPageIndex,
    required this.counts,
    required this.lastAccessedAt,
    this.isCompleted = false,
    this.skippedItemIds = const {},
  });

  AdhkarSessionRecord copyWith({
    String? collectionId,
    int? lastPageIndex,
    Map<String, int>? counts,
    DateTime? lastAccessedAt,
    bool? isCompleted,
    Set<String>? skippedItemIds,
  }) {
    return AdhkarSessionRecord(
      collectionId: collectionId ?? this.collectionId,
      lastPageIndex: lastPageIndex ?? this.lastPageIndex,
      counts: counts ?? this.counts,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      skippedItemIds: skippedItemIds ?? this.skippedItemIds,
    );
  }
}
