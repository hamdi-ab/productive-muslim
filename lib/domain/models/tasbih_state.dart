/// Represents the state of the independent offline Tasbih counter.
class TasbihState {
  final int currentCount;
  final int? targetCount; // Nullable: optional personal target
  final String? dhikrId; // Nullable: approved library remembrance ID
  final String? customLabel; // Nullable: user's custom personal label
  final int? lastCount; // Prior count for undoing the latest increment
  final DateTime updatedAt;

  const TasbihState({
    this.currentCount = 0,
    this.targetCount,
    this.dhikrId,
    this.customLabel,
    this.lastCount,
    required this.updatedAt,
  });

  bool get hasTarget => targetCount != null && targetCount! > 0;
  bool get isTargetReached => hasTarget && currentCount >= targetCount!;
  bool get hasDhikr => dhikrId != null && dhikrId!.trim().isNotEmpty;
  bool get hasCustomLabel =>
      customLabel != null && customLabel!.trim().isNotEmpty;

  TasbihState copyWith({
    int? currentCount,
    int? targetCount,
    bool clearTarget = false,
    String? dhikrId,
    bool clearDhikr = false,
    String? customLabel,
    bool clearCustomLabel = false,
    int? lastCount,
    bool clearLastCount = false,
    DateTime? updatedAt,
  }) {
    return TasbihState(
      currentCount: currentCount ?? this.currentCount,
      targetCount: clearTarget ? null : (targetCount ?? this.targetCount),
      dhikrId: clearDhikr ? null : (dhikrId ?? this.dhikrId),
      customLabel: clearCustomLabel ? null : (customLabel ?? this.customLabel),
      lastCount: clearLastCount ? null : (lastCount ?? this.lastCount),
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() => {
    'currentCount': currentCount,
    'targetCount': targetCount,
    'dhikrId': dhikrId,
    'customLabel': customLabel,
    'lastCount': lastCount,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
  };

  factory TasbihState.fromJson(Map<String, dynamic> json) {
    return TasbihState(
      currentCount: (json['currentCount'] as num?)?.toInt() ?? 0,
      targetCount: (json['targetCount'] as num?)?.toInt(),
      dhikrId: json['dhikrId'] as String?,
      customLabel: json['customLabel'] as String?,
      lastCount: (json['lastCount'] as num?)?.toInt(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int)
          : DateTime.now(),
    );
  }

  static TasbihState initial() =>
      TasbihState(currentCount: 0, updatedAt: DateTime.now());

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TasbihState &&
          runtimeType == other.runtimeType &&
          currentCount == other.currentCount &&
          targetCount == other.targetCount &&
          dhikrId == other.dhikrId &&
          customLabel == other.customLabel &&
          lastCount == other.lastCount;

  @override
  int get hashCode =>
      Object.hash(currentCount, targetCount, dhikrId, customLabel, lastCount);
}
