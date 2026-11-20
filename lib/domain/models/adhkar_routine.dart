/// Represents a user's private, personalized Adhkar routine.
class AdhkarRoutine {
  final String id;
  final String name;
  final List<String> itemIds;
  final String? preferredTime; // Optional "HH:mm" (24-hour format)
  final List<int>
  weekdays; // 1=Monday..7=Sunday (ISO 8601), empty if no schedule
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<String> retiredItemIds; // Tracked retired IDs acknowledged by user

  const AdhkarRoutine({
    required this.id,
    required this.name,
    required this.itemIds,
    this.preferredTime,
    this.weekdays = const [],
    required this.createdAt,
    required this.updatedAt,
    this.retiredItemIds = const [],
  });

  bool get hasSchedule => preferredTime != null || weekdays.isNotEmpty;

  AdhkarRoutine copyWith({
    String? id,
    String? name,
    List<String>? itemIds,
    String? preferredTime,
    bool clearPreferredTime = false,
    List<int>? weekdays,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<String>? retiredItemIds,
  }) {
    return AdhkarRoutine(
      id: id ?? this.id,
      name: name ?? this.name,
      itemIds: itemIds ?? this.itemIds,
      preferredTime: clearPreferredTime
          ? null
          : (preferredTime ?? this.preferredTime),
      weekdays: weekdays ?? this.weekdays,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      retiredItemIds: retiredItemIds ?? this.retiredItemIds,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'itemIds': itemIds,
    'preferredTime': preferredTime,
    'weekdays': weekdays,
    'createdAt': createdAt.millisecondsSinceEpoch,
    'updatedAt': updatedAt.millisecondsSinceEpoch,
    'retiredItemIds': retiredItemIds,
  };

  factory AdhkarRoutine.fromJson(Map<String, dynamic> json) {
    return AdhkarRoutine(
      id: json['id'] as String,
      name: json['name'] as String,
      itemIds:
          (json['itemIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
      preferredTime: json['preferredTime'] as String?,
      weekdays:
          (json['weekdays'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['createdAt'] as int),
      updatedAt: DateTime.fromMillisecondsSinceEpoch(json['updatedAt'] as int),
      retiredItemIds:
          (json['retiredItemIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          const [],
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AdhkarRoutine &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Represents an independent completion history entry for a personal routine.
class AdhkarRoutineCompletion {
  final int? id;
  final String routineId;
  final String routineName;
  final String date; // YYYY-MM-DD
  final DateTime completedAt;

  const AdhkarRoutineCompletion({
    this.id,
    required this.routineId,
    required this.routineName,
    required this.date,
    required this.completedAt,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'routineId': routineId,
    'routineName': routineName,
    'date': date,
    'completedAt': completedAt.millisecondsSinceEpoch,
  };

  factory AdhkarRoutineCompletion.fromJson(Map<String, dynamic> json) {
    return AdhkarRoutineCompletion(
      id: json['id'] as int?,
      routineId: json['routineId'] as String,
      routineName: json['routineName'] as String,
      date: json['date'] as String,
      completedAt: DateTime.fromMillisecondsSinceEpoch(
        json['completedAt'] as int,
      ),
    );
  }
}
