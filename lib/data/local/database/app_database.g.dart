// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $BarakahEntriesTable extends BarakahEntries
    with TableInfo<$BarakahEntriesTable, BarakahEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BarakahEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdsMeta = const VerificationMeta(
    'sourceIds',
  );
  @override
  late final GeneratedColumn<String> sourceIds = GeneratedColumn<String>(
    'source_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptIdMeta = const VerificationMeta(
    'promptId',
  );
  @override
  late final GeneratedColumn<String> promptId = GeneratedColumn<String>(
    'prompt_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _intensityMeta = const VerificationMeta(
    'intensity',
  );
  @override
  late final GeneratedColumn<int> intensity = GeneratedColumn<int>(
    'intensity',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skippedMeta = const VerificationMeta(
    'skipped',
  );
  @override
  late final GeneratedColumn<int> skipped = GeneratedColumn<int>(
    'skipped',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    sourceIds,
    promptId,
    intensity,
    note,
    skipped,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'barakah_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<BarakahEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('source_ids')) {
      context.handle(
        _sourceIdsMeta,
        sourceIds.isAcceptableOrUnknown(data['source_ids']!, _sourceIdsMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdsMeta);
    }
    if (data.containsKey('prompt_id')) {
      context.handle(
        _promptIdMeta,
        promptId.isAcceptableOrUnknown(data['prompt_id']!, _promptIdMeta),
      );
    }
    if (data.containsKey('intensity')) {
      context.handle(
        _intensityMeta,
        intensity.isAcceptableOrUnknown(data['intensity']!, _intensityMeta),
      );
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('skipped')) {
      context.handle(
        _skippedMeta,
        skipped.isAcceptableOrUnknown(data['skipped']!, _skippedMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BarakahEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BarakahEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      sourceIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ids'],
      )!,
      promptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_id'],
      ),
      intensity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}intensity'],
      ),
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      skipped: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}skipped'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $BarakahEntriesTable createAlias(String alias) {
    return $BarakahEntriesTable(attachedDatabase, alias);
  }
}

class BarakahEntry extends DataClass implements Insertable<BarakahEntry> {
  final int id;
  final String date;
  final String sourceIds;
  final String? promptId;
  final int? intensity;
  final String? note;
  final int skipped;
  final int createdAt;
  const BarakahEntry({
    required this.id,
    required this.date,
    required this.sourceIds,
    this.promptId,
    this.intensity,
    this.note,
    required this.skipped,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['source_ids'] = Variable<String>(sourceIds);
    if (!nullToAbsent || promptId != null) {
      map['prompt_id'] = Variable<String>(promptId);
    }
    if (!nullToAbsent || intensity != null) {
      map['intensity'] = Variable<int>(intensity);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['skipped'] = Variable<int>(skipped);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  BarakahEntriesCompanion toCompanion(bool nullToAbsent) {
    return BarakahEntriesCompanion(
      id: Value(id),
      date: Value(date),
      sourceIds: Value(sourceIds),
      promptId: promptId == null && nullToAbsent
          ? const Value.absent()
          : Value(promptId),
      intensity: intensity == null && nullToAbsent
          ? const Value.absent()
          : Value(intensity),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      skipped: Value(skipped),
      createdAt: Value(createdAt),
    );
  }

  factory BarakahEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BarakahEntry(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      sourceIds: serializer.fromJson<String>(json['sourceIds']),
      promptId: serializer.fromJson<String?>(json['promptId']),
      intensity: serializer.fromJson<int?>(json['intensity']),
      note: serializer.fromJson<String?>(json['note']),
      skipped: serializer.fromJson<int>(json['skipped']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'sourceIds': serializer.toJson<String>(sourceIds),
      'promptId': serializer.toJson<String?>(promptId),
      'intensity': serializer.toJson<int?>(intensity),
      'note': serializer.toJson<String?>(note),
      'skipped': serializer.toJson<int>(skipped),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  BarakahEntry copyWith({
    int? id,
    String? date,
    String? sourceIds,
    Value<String?> promptId = const Value.absent(),
    Value<int?> intensity = const Value.absent(),
    Value<String?> note = const Value.absent(),
    int? skipped,
    int? createdAt,
  }) => BarakahEntry(
    id: id ?? this.id,
    date: date ?? this.date,
    sourceIds: sourceIds ?? this.sourceIds,
    promptId: promptId.present ? promptId.value : this.promptId,
    intensity: intensity.present ? intensity.value : this.intensity,
    note: note.present ? note.value : this.note,
    skipped: skipped ?? this.skipped,
    createdAt: createdAt ?? this.createdAt,
  );
  BarakahEntry copyWithCompanion(BarakahEntriesCompanion data) {
    return BarakahEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      sourceIds: data.sourceIds.present ? data.sourceIds.value : this.sourceIds,
      promptId: data.promptId.present ? data.promptId.value : this.promptId,
      intensity: data.intensity.present ? data.intensity.value : this.intensity,
      note: data.note.present ? data.note.value : this.note,
      skipped: data.skipped.present ? data.skipped.value : this.skipped,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BarakahEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('sourceIds: $sourceIds, ')
          ..write('promptId: $promptId, ')
          ..write('intensity: $intensity, ')
          ..write('note: $note, ')
          ..write('skipped: $skipped, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    sourceIds,
    promptId,
    intensity,
    note,
    skipped,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BarakahEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.sourceIds == this.sourceIds &&
          other.promptId == this.promptId &&
          other.intensity == this.intensity &&
          other.note == this.note &&
          other.skipped == this.skipped &&
          other.createdAt == this.createdAt);
}

class BarakahEntriesCompanion extends UpdateCompanion<BarakahEntry> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> sourceIds;
  final Value<String?> promptId;
  final Value<int?> intensity;
  final Value<String?> note;
  final Value<int> skipped;
  final Value<int> createdAt;
  const BarakahEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.sourceIds = const Value.absent(),
    this.promptId = const Value.absent(),
    this.intensity = const Value.absent(),
    this.note = const Value.absent(),
    this.skipped = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  BarakahEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String sourceIds,
    this.promptId = const Value.absent(),
    this.intensity = const Value.absent(),
    this.note = const Value.absent(),
    this.skipped = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : date = Value(date),
       sourceIds = Value(sourceIds);
  static Insertable<BarakahEntry> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? sourceIds,
    Expression<String>? promptId,
    Expression<int>? intensity,
    Expression<String>? note,
    Expression<int>? skipped,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (sourceIds != null) 'source_ids': sourceIds,
      if (promptId != null) 'prompt_id': promptId,
      if (intensity != null) 'intensity': intensity,
      if (note != null) 'note': note,
      if (skipped != null) 'skipped': skipped,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  BarakahEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String>? sourceIds,
    Value<String?>? promptId,
    Value<int?>? intensity,
    Value<String?>? note,
    Value<int>? skipped,
    Value<int>? createdAt,
  }) {
    return BarakahEntriesCompanion(
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

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (sourceIds.present) {
      map['source_ids'] = Variable<String>(sourceIds.value);
    }
    if (promptId.present) {
      map['prompt_id'] = Variable<String>(promptId.value);
    }
    if (intensity.present) {
      map['intensity'] = Variable<int>(intensity.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (skipped.present) {
      map['skipped'] = Variable<int>(skipped.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BarakahEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('sourceIds: $sourceIds, ')
          ..write('promptId: $promptId, ')
          ..write('intensity: $intensity, ')
          ..write('note: $note, ')
          ..write('skipped: $skipped, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BarakahPromptsTable extends BarakahPrompts
    with TableInfo<$BarakahPromptsTable, BarakahPrompt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BarakahPromptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _sourceIdsMeta = const VerificationMeta(
    'sourceIds',
  );
  @override
  late final GeneratedColumn<String> sourceIds = GeneratedColumn<String>(
    'source_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionMeta = const VerificationMeta(
    'question',
  );
  @override
  late final GeneratedColumn<String> question = GeneratedColumn<String>(
    'question',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<int> active = GeneratedColumn<int>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _displayOrderMeta = const VerificationMeta(
    'displayOrder',
  );
  @override
  late final GeneratedColumn<int> displayOrder = GeneratedColumn<int>(
    'display_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    sourceIds,
    question,
    active,
    displayOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'barakah_prompts';
  @override
  VerificationContext validateIntegrity(
    Insertable<BarakahPrompt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('source_ids')) {
      context.handle(
        _sourceIdsMeta,
        sourceIds.isAcceptableOrUnknown(data['source_ids']!, _sourceIdsMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdsMeta);
    }
    if (data.containsKey('question')) {
      context.handle(
        _questionMeta,
        question.isAcceptableOrUnknown(data['question']!, _questionMeta),
      );
    } else if (isInserting) {
      context.missing(_questionMeta);
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('display_order')) {
      context.handle(
        _displayOrderMeta,
        displayOrder.isAcceptableOrUnknown(
          data['display_order']!,
          _displayOrderMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_displayOrderMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  BarakahPrompt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BarakahPrompt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      sourceIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ids'],
      )!,
      question: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active'],
      )!,
      displayOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}display_order'],
      )!,
    );
  }

  @override
  $BarakahPromptsTable createAlias(String alias) {
    return $BarakahPromptsTable(attachedDatabase, alias);
  }
}

class BarakahPrompt extends DataClass implements Insertable<BarakahPrompt> {
  final int id;
  final String sourceIds;
  final String question;
  final int active;
  final int displayOrder;
  const BarakahPrompt({
    required this.id,
    required this.sourceIds,
    required this.question,
    required this.active,
    required this.displayOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['source_ids'] = Variable<String>(sourceIds);
    map['question'] = Variable<String>(question);
    map['active'] = Variable<int>(active);
    map['display_order'] = Variable<int>(displayOrder);
    return map;
  }

  BarakahPromptsCompanion toCompanion(bool nullToAbsent) {
    return BarakahPromptsCompanion(
      id: Value(id),
      sourceIds: Value(sourceIds),
      question: Value(question),
      active: Value(active),
      displayOrder: Value(displayOrder),
    );
  }

  factory BarakahPrompt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BarakahPrompt(
      id: serializer.fromJson<int>(json['id']),
      sourceIds: serializer.fromJson<String>(json['sourceIds']),
      question: serializer.fromJson<String>(json['question']),
      active: serializer.fromJson<int>(json['active']),
      displayOrder: serializer.fromJson<int>(json['displayOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'sourceIds': serializer.toJson<String>(sourceIds),
      'question': serializer.toJson<String>(question),
      'active': serializer.toJson<int>(active),
      'displayOrder': serializer.toJson<int>(displayOrder),
    };
  }

  BarakahPrompt copyWith({
    int? id,
    String? sourceIds,
    String? question,
    int? active,
    int? displayOrder,
  }) => BarakahPrompt(
    id: id ?? this.id,
    sourceIds: sourceIds ?? this.sourceIds,
    question: question ?? this.question,
    active: active ?? this.active,
    displayOrder: displayOrder ?? this.displayOrder,
  );
  BarakahPrompt copyWithCompanion(BarakahPromptsCompanion data) {
    return BarakahPrompt(
      id: data.id.present ? data.id.value : this.id,
      sourceIds: data.sourceIds.present ? data.sourceIds.value : this.sourceIds,
      question: data.question.present ? data.question.value : this.question,
      active: data.active.present ? data.active.value : this.active,
      displayOrder: data.displayOrder.present
          ? data.displayOrder.value
          : this.displayOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BarakahPrompt(')
          ..write('id: $id, ')
          ..write('sourceIds: $sourceIds, ')
          ..write('question: $question, ')
          ..write('active: $active, ')
          ..write('displayOrder: $displayOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, sourceIds, question, active, displayOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BarakahPrompt &&
          other.id == this.id &&
          other.sourceIds == this.sourceIds &&
          other.question == this.question &&
          other.active == this.active &&
          other.displayOrder == this.displayOrder);
}

class BarakahPromptsCompanion extends UpdateCompanion<BarakahPrompt> {
  final Value<int> id;
  final Value<String> sourceIds;
  final Value<String> question;
  final Value<int> active;
  final Value<int> displayOrder;
  const BarakahPromptsCompanion({
    this.id = const Value.absent(),
    this.sourceIds = const Value.absent(),
    this.question = const Value.absent(),
    this.active = const Value.absent(),
    this.displayOrder = const Value.absent(),
  });
  BarakahPromptsCompanion.insert({
    this.id = const Value.absent(),
    required String sourceIds,
    required String question,
    this.active = const Value.absent(),
    required int displayOrder,
  }) : sourceIds = Value(sourceIds),
       question = Value(question),
       displayOrder = Value(displayOrder);
  static Insertable<BarakahPrompt> custom({
    Expression<int>? id,
    Expression<String>? sourceIds,
    Expression<String>? question,
    Expression<int>? active,
    Expression<int>? displayOrder,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (sourceIds != null) 'source_ids': sourceIds,
      if (question != null) 'question': question,
      if (active != null) 'active': active,
      if (displayOrder != null) 'display_order': displayOrder,
    });
  }

  BarakahPromptsCompanion copyWith({
    Value<int>? id,
    Value<String>? sourceIds,
    Value<String>? question,
    Value<int>? active,
    Value<int>? displayOrder,
  }) {
    return BarakahPromptsCompanion(
      id: id ?? this.id,
      sourceIds: sourceIds ?? this.sourceIds,
      question: question ?? this.question,
      active: active ?? this.active,
      displayOrder: displayOrder ?? this.displayOrder,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (sourceIds.present) {
      map['source_ids'] = Variable<String>(sourceIds.value);
    }
    if (question.present) {
      map['question'] = Variable<String>(question.value);
    }
    if (active.present) {
      map['active'] = Variable<int>(active.value);
    }
    if (displayOrder.present) {
      map['display_order'] = Variable<int>(displayOrder.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BarakahPromptsCompanion(')
          ..write('id: $id, ')
          ..write('sourceIds: $sourceIds, ')
          ..write('question: $question, ')
          ..write('active: $active, ')
          ..write('displayOrder: $displayOrder')
          ..write(')'))
        .toString();
  }
}

class $HabitsTable extends Habits with TableInfo<$HabitsTable, Habit> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _frequencyMeta = const VerificationMeta(
    'frequency',
  );
  @override
  late final GeneratedColumn<String> frequency = GeneratedColumn<String>(
    'frequency',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('daily'),
  );
  static const VerificationMeta _targetDaysMeta = const VerificationMeta(
    'targetDays',
  );
  @override
  late final GeneratedColumn<String> targetDays = GeneratedColumn<String>(
    'target_days',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _reminderEnabledMeta = const VerificationMeta(
    'reminderEnabled',
  );
  @override
  late final GeneratedColumn<int> reminderEnabled = GeneratedColumn<int>(
    'reminder_enabled',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reminderTimeMeta = const VerificationMeta(
    'reminderTime',
  );
  @override
  late final GeneratedColumn<int> reminderTime = GeneratedColumn<int>(
    'reminder_time',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<int> active = GeneratedColumn<int>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    category,
    frequency,
    targetDays,
    reminderEnabled,
    reminderTime,
    active,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habits';
  @override
  VerificationContext validateIntegrity(
    Insertable<Habit> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('frequency')) {
      context.handle(
        _frequencyMeta,
        frequency.isAcceptableOrUnknown(data['frequency']!, _frequencyMeta),
      );
    }
    if (data.containsKey('target_days')) {
      context.handle(
        _targetDaysMeta,
        targetDays.isAcceptableOrUnknown(data['target_days']!, _targetDaysMeta),
      );
    }
    if (data.containsKey('reminder_enabled')) {
      context.handle(
        _reminderEnabledMeta,
        reminderEnabled.isAcceptableOrUnknown(
          data['reminder_enabled']!,
          _reminderEnabledMeta,
        ),
      );
    }
    if (data.containsKey('reminder_time')) {
      context.handle(
        _reminderTimeMeta,
        reminderTime.isAcceptableOrUnknown(
          data['reminder_time']!,
          _reminderTimeMeta,
        ),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Habit map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Habit(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      )!,
      frequency: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}frequency'],
      )!,
      targetDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_days'],
      ),
      reminderEnabled: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_enabled'],
      )!,
      reminderTime: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reminder_time'],
      ),
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $HabitsTable createAlias(String alias) {
    return $HabitsTable(attachedDatabase, alias);
  }
}

class Habit extends DataClass implements Insertable<Habit> {
  final int id;
  final String name;
  final String category;
  final String frequency;
  final String? targetDays;
  final int reminderEnabled;
  final int? reminderTime;
  final int active;
  final int createdAt;
  const Habit({
    required this.id,
    required this.name,
    required this.category,
    required this.frequency,
    this.targetDays,
    required this.reminderEnabled,
    this.reminderTime,
    required this.active,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['category'] = Variable<String>(category);
    map['frequency'] = Variable<String>(frequency);
    if (!nullToAbsent || targetDays != null) {
      map['target_days'] = Variable<String>(targetDays);
    }
    map['reminder_enabled'] = Variable<int>(reminderEnabled);
    if (!nullToAbsent || reminderTime != null) {
      map['reminder_time'] = Variable<int>(reminderTime);
    }
    map['active'] = Variable<int>(active);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  HabitsCompanion toCompanion(bool nullToAbsent) {
    return HabitsCompanion(
      id: Value(id),
      name: Value(name),
      category: Value(category),
      frequency: Value(frequency),
      targetDays: targetDays == null && nullToAbsent
          ? const Value.absent()
          : Value(targetDays),
      reminderEnabled: Value(reminderEnabled),
      reminderTime: reminderTime == null && nullToAbsent
          ? const Value.absent()
          : Value(reminderTime),
      active: Value(active),
      createdAt: Value(createdAt),
    );
  }

  factory Habit.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Habit(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      category: serializer.fromJson<String>(json['category']),
      frequency: serializer.fromJson<String>(json['frequency']),
      targetDays: serializer.fromJson<String?>(json['targetDays']),
      reminderEnabled: serializer.fromJson<int>(json['reminderEnabled']),
      reminderTime: serializer.fromJson<int?>(json['reminderTime']),
      active: serializer.fromJson<int>(json['active']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'category': serializer.toJson<String>(category),
      'frequency': serializer.toJson<String>(frequency),
      'targetDays': serializer.toJson<String?>(targetDays),
      'reminderEnabled': serializer.toJson<int>(reminderEnabled),
      'reminderTime': serializer.toJson<int?>(reminderTime),
      'active': serializer.toJson<int>(active),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  Habit copyWith({
    int? id,
    String? name,
    String? category,
    String? frequency,
    Value<String?> targetDays = const Value.absent(),
    int? reminderEnabled,
    Value<int?> reminderTime = const Value.absent(),
    int? active,
    int? createdAt,
  }) => Habit(
    id: id ?? this.id,
    name: name ?? this.name,
    category: category ?? this.category,
    frequency: frequency ?? this.frequency,
    targetDays: targetDays.present ? targetDays.value : this.targetDays,
    reminderEnabled: reminderEnabled ?? this.reminderEnabled,
    reminderTime: reminderTime.present ? reminderTime.value : this.reminderTime,
    active: active ?? this.active,
    createdAt: createdAt ?? this.createdAt,
  );
  Habit copyWithCompanion(HabitsCompanion data) {
    return Habit(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      category: data.category.present ? data.category.value : this.category,
      frequency: data.frequency.present ? data.frequency.value : this.frequency,
      targetDays: data.targetDays.present
          ? data.targetDays.value
          : this.targetDays,
      reminderEnabled: data.reminderEnabled.present
          ? data.reminderEnabled.value
          : this.reminderEnabled,
      reminderTime: data.reminderTime.present
          ? data.reminderTime.value
          : this.reminderTime,
      active: data.active.present ? data.active.value : this.active,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Habit(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('frequency: $frequency, ')
          ..write('targetDays: $targetDays, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    name,
    category,
    frequency,
    targetDays,
    reminderEnabled,
    reminderTime,
    active,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Habit &&
          other.id == this.id &&
          other.name == this.name &&
          other.category == this.category &&
          other.frequency == this.frequency &&
          other.targetDays == this.targetDays &&
          other.reminderEnabled == this.reminderEnabled &&
          other.reminderTime == this.reminderTime &&
          other.active == this.active &&
          other.createdAt == this.createdAt);
}

class HabitsCompanion extends UpdateCompanion<Habit> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> category;
  final Value<String> frequency;
  final Value<String?> targetDays;
  final Value<int> reminderEnabled;
  final Value<int?> reminderTime;
  final Value<int> active;
  final Value<int> createdAt;
  const HabitsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.category = const Value.absent(),
    this.frequency = const Value.absent(),
    this.targetDays = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  HabitsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String category,
    this.frequency = const Value.absent(),
    this.targetDays = const Value.absent(),
    this.reminderEnabled = const Value.absent(),
    this.reminderTime = const Value.absent(),
    this.active = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : name = Value(name),
       category = Value(category);
  static Insertable<Habit> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? category,
    Expression<String>? frequency,
    Expression<String>? targetDays,
    Expression<int>? reminderEnabled,
    Expression<int>? reminderTime,
    Expression<int>? active,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (category != null) 'category': category,
      if (frequency != null) 'frequency': frequency,
      if (targetDays != null) 'target_days': targetDays,
      if (reminderEnabled != null) 'reminder_enabled': reminderEnabled,
      if (reminderTime != null) 'reminder_time': reminderTime,
      if (active != null) 'active': active,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  HabitsCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<String>? category,
    Value<String>? frequency,
    Value<String?>? targetDays,
    Value<int>? reminderEnabled,
    Value<int?>? reminderTime,
    Value<int>? active,
    Value<int>? createdAt,
  }) {
    return HabitsCompanion(
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

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (frequency.present) {
      map['frequency'] = Variable<String>(frequency.value);
    }
    if (targetDays.present) {
      map['target_days'] = Variable<String>(targetDays.value);
    }
    if (reminderEnabled.present) {
      map['reminder_enabled'] = Variable<int>(reminderEnabled.value);
    }
    if (reminderTime.present) {
      map['reminder_time'] = Variable<int>(reminderTime.value);
    }
    if (active.present) {
      map['active'] = Variable<int>(active.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('category: $category, ')
          ..write('frequency: $frequency, ')
          ..write('targetDays: $targetDays, ')
          ..write('reminderEnabled: $reminderEnabled, ')
          ..write('reminderTime: $reminderTime, ')
          ..write('active: $active, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $HabitCompletionsTable extends HabitCompletions
    with TableInfo<$HabitCompletionsTable, HabitCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $HabitCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _habitIdMeta = const VerificationMeta(
    'habitId',
  );
  @override
  late final GeneratedColumn<int> habitId = GeneratedColumn<int>(
    'habit_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<int> completed = GeneratedColumn<int>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [id, habitId, date, completed];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'habit_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<HabitCompletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('habit_id')) {
      context.handle(
        _habitIdMeta,
        habitId.isAcceptableOrUnknown(data['habit_id']!, _habitIdMeta),
      );
    } else if (isInserting) {
      context.missing(_habitIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {habitId, date},
  ];
  @override
  HabitCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return HabitCompletion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      habitId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}habit_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed'],
      )!,
    );
  }

  @override
  $HabitCompletionsTable createAlias(String alias) {
    return $HabitCompletionsTable(attachedDatabase, alias);
  }
}

class HabitCompletion extends DataClass implements Insertable<HabitCompletion> {
  final int id;
  final int habitId;
  final String date;
  final int completed;
  const HabitCompletion({
    required this.id,
    required this.habitId,
    required this.date,
    required this.completed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['habit_id'] = Variable<int>(habitId);
    map['date'] = Variable<String>(date);
    map['completed'] = Variable<int>(completed);
    return map;
  }

  HabitCompletionsCompanion toCompanion(bool nullToAbsent) {
    return HabitCompletionsCompanion(
      id: Value(id),
      habitId: Value(habitId),
      date: Value(date),
      completed: Value(completed),
    );
  }

  factory HabitCompletion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return HabitCompletion(
      id: serializer.fromJson<int>(json['id']),
      habitId: serializer.fromJson<int>(json['habitId']),
      date: serializer.fromJson<String>(json['date']),
      completed: serializer.fromJson<int>(json['completed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'habitId': serializer.toJson<int>(habitId),
      'date': serializer.toJson<String>(date),
      'completed': serializer.toJson<int>(completed),
    };
  }

  HabitCompletion copyWith({
    int? id,
    int? habitId,
    String? date,
    int? completed,
  }) => HabitCompletion(
    id: id ?? this.id,
    habitId: habitId ?? this.habitId,
    date: date ?? this.date,
    completed: completed ?? this.completed,
  );
  HabitCompletion copyWithCompanion(HabitCompletionsCompanion data) {
    return HabitCompletion(
      id: data.id.present ? data.id.value : this.id,
      habitId: data.habitId.present ? data.habitId.value : this.habitId,
      date: data.date.present ? data.date.value : this.date,
      completed: data.completed.present ? data.completed.value : this.completed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('HabitCompletion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, habitId, date, completed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is HabitCompletion &&
          other.id == this.id &&
          other.habitId == this.habitId &&
          other.date == this.date &&
          other.completed == this.completed);
}

class HabitCompletionsCompanion extends UpdateCompanion<HabitCompletion> {
  final Value<int> id;
  final Value<int> habitId;
  final Value<String> date;
  final Value<int> completed;
  const HabitCompletionsCompanion({
    this.id = const Value.absent(),
    this.habitId = const Value.absent(),
    this.date = const Value.absent(),
    this.completed = const Value.absent(),
  });
  HabitCompletionsCompanion.insert({
    this.id = const Value.absent(),
    required int habitId,
    required String date,
    this.completed = const Value.absent(),
  }) : habitId = Value(habitId),
       date = Value(date);
  static Insertable<HabitCompletion> custom({
    Expression<int>? id,
    Expression<int>? habitId,
    Expression<String>? date,
    Expression<int>? completed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (habitId != null) 'habit_id': habitId,
      if (date != null) 'date': date,
      if (completed != null) 'completed': completed,
    });
  }

  HabitCompletionsCompanion copyWith({
    Value<int>? id,
    Value<int>? habitId,
    Value<String>? date,
    Value<int>? completed,
  }) {
    return HabitCompletionsCompanion(
      id: id ?? this.id,
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      completed: completed ?? this.completed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (habitId.present) {
      map['habit_id'] = Variable<int>(habitId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (completed.present) {
      map['completed'] = Variable<int>(completed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('HabitCompletionsCompanion(')
          ..write('id: $id, ')
          ..write('habitId: $habitId, ')
          ..write('date: $date, ')
          ..write('completed: $completed')
          ..write(')'))
        .toString();
  }
}

class $TasksTable extends Tasks with TableInfo<$TasksTable, Task> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TasksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lifeAreaMeta = const VerificationMeta(
    'lifeArea',
  );
  @override
  late final GeneratedColumn<String> lifeArea = GeneratedColumn<String>(
    'life_area',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startMinutesMeta = const VerificationMeta(
    'startMinutes',
  );
  @override
  late final GeneratedColumn<int> startMinutes = GeneratedColumn<int>(
    'start_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _endMinutesMeta = const VerificationMeta(
    'endMinutes',
  );
  @override
  late final GeneratedColumn<int> endMinutes = GeneratedColumn<int>(
    'end_minutes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _repeatDailyMeta = const VerificationMeta(
    'repeatDaily',
  );
  @override
  late final GeneratedColumn<int> repeatDaily = GeneratedColumn<int>(
    'repeat_daily',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repeatWeeklyMeta = const VerificationMeta(
    'repeatWeekly',
  );
  @override
  late final GeneratedColumn<int> repeatWeekly = GeneratedColumn<int>(
    'repeat_weekly',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _repeatDaysMeta = const VerificationMeta(
    'repeatDays',
  );
  @override
  late final GeneratedColumn<String> repeatDays = GeneratedColumn<String>(
    'repeat_days',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<int> completed = GeneratedColumn<int>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _activeMeta = const VerificationMeta('active');
  @override
  late final GeneratedColumn<int> active = GeneratedColumn<int>(
    'active',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    lifeArea,
    startMinutes,
    endMinutes,
    date,
    repeatDaily,
    repeatWeekly,
    repeatDays,
    notes,
    completed,
    completedAt,
    createdAt,
    active,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tasks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Task> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('life_area')) {
      context.handle(
        _lifeAreaMeta,
        lifeArea.isAcceptableOrUnknown(data['life_area']!, _lifeAreaMeta),
      );
    } else if (isInserting) {
      context.missing(_lifeAreaMeta);
    }
    if (data.containsKey('start_minutes')) {
      context.handle(
        _startMinutesMeta,
        startMinutes.isAcceptableOrUnknown(
          data['start_minutes']!,
          _startMinutesMeta,
        ),
      );
    }
    if (data.containsKey('end_minutes')) {
      context.handle(
        _endMinutesMeta,
        endMinutes.isAcceptableOrUnknown(data['end_minutes']!, _endMinutesMeta),
      );
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('repeat_daily')) {
      context.handle(
        _repeatDailyMeta,
        repeatDaily.isAcceptableOrUnknown(
          data['repeat_daily']!,
          _repeatDailyMeta,
        ),
      );
    }
    if (data.containsKey('repeat_weekly')) {
      context.handle(
        _repeatWeeklyMeta,
        repeatWeekly.isAcceptableOrUnknown(
          data['repeat_weekly']!,
          _repeatWeeklyMeta,
        ),
      );
    }
    if (data.containsKey('repeat_days')) {
      context.handle(
        _repeatDaysMeta,
        repeatDays.isAcceptableOrUnknown(data['repeat_days']!, _repeatDaysMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('active')) {
      context.handle(
        _activeMeta,
        active.isAcceptableOrUnknown(data['active']!, _activeMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Task map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Task(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      lifeArea: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}life_area'],
      )!,
      startMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}start_minutes'],
      ),
      endMinutes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}end_minutes'],
      ),
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      repeatDaily: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_daily'],
      )!,
      repeatWeekly: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}repeat_weekly'],
      )!,
      repeatDays: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}repeat_days'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      active: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}active'],
      )!,
    );
  }

  @override
  $TasksTable createAlias(String alias) {
    return $TasksTable(attachedDatabase, alias);
  }
}

class Task extends DataClass implements Insertable<Task> {
  final int id;
  final String title;
  final String lifeArea;
  final int? startMinutes;
  final int? endMinutes;
  final String date;
  final int repeatDaily;
  final int repeatWeekly;
  final String? repeatDays;
  final String? notes;
  final int completed;
  final int? completedAt;
  final int createdAt;
  final int active;
  const Task({
    required this.id,
    required this.title,
    required this.lifeArea,
    this.startMinutes,
    this.endMinutes,
    required this.date,
    required this.repeatDaily,
    required this.repeatWeekly,
    this.repeatDays,
    this.notes,
    required this.completed,
    this.completedAt,
    required this.createdAt,
    required this.active,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['life_area'] = Variable<String>(lifeArea);
    if (!nullToAbsent || startMinutes != null) {
      map['start_minutes'] = Variable<int>(startMinutes);
    }
    if (!nullToAbsent || endMinutes != null) {
      map['end_minutes'] = Variable<int>(endMinutes);
    }
    map['date'] = Variable<String>(date);
    map['repeat_daily'] = Variable<int>(repeatDaily);
    map['repeat_weekly'] = Variable<int>(repeatWeekly);
    if (!nullToAbsent || repeatDays != null) {
      map['repeat_days'] = Variable<String>(repeatDays);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['completed'] = Variable<int>(completed);
    if (!nullToAbsent || completedAt != null) {
      map['completed_at'] = Variable<int>(completedAt);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['active'] = Variable<int>(active);
    return map;
  }

  TasksCompanion toCompanion(bool nullToAbsent) {
    return TasksCompanion(
      id: Value(id),
      title: Value(title),
      lifeArea: Value(lifeArea),
      startMinutes: startMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(startMinutes),
      endMinutes: endMinutes == null && nullToAbsent
          ? const Value.absent()
          : Value(endMinutes),
      date: Value(date),
      repeatDaily: Value(repeatDaily),
      repeatWeekly: Value(repeatWeekly),
      repeatDays: repeatDays == null && nullToAbsent
          ? const Value.absent()
          : Value(repeatDays),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      completed: Value(completed),
      completedAt: completedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(completedAt),
      createdAt: Value(createdAt),
      active: Value(active),
    );
  }

  factory Task.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Task(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      lifeArea: serializer.fromJson<String>(json['lifeArea']),
      startMinutes: serializer.fromJson<int?>(json['startMinutes']),
      endMinutes: serializer.fromJson<int?>(json['endMinutes']),
      date: serializer.fromJson<String>(json['date']),
      repeatDaily: serializer.fromJson<int>(json['repeatDaily']),
      repeatWeekly: serializer.fromJson<int>(json['repeatWeekly']),
      repeatDays: serializer.fromJson<String?>(json['repeatDays']),
      notes: serializer.fromJson<String?>(json['notes']),
      completed: serializer.fromJson<int>(json['completed']),
      completedAt: serializer.fromJson<int?>(json['completedAt']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      active: serializer.fromJson<int>(json['active']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'lifeArea': serializer.toJson<String>(lifeArea),
      'startMinutes': serializer.toJson<int?>(startMinutes),
      'endMinutes': serializer.toJson<int?>(endMinutes),
      'date': serializer.toJson<String>(date),
      'repeatDaily': serializer.toJson<int>(repeatDaily),
      'repeatWeekly': serializer.toJson<int>(repeatWeekly),
      'repeatDays': serializer.toJson<String?>(repeatDays),
      'notes': serializer.toJson<String?>(notes),
      'completed': serializer.toJson<int>(completed),
      'completedAt': serializer.toJson<int?>(completedAt),
      'createdAt': serializer.toJson<int>(createdAt),
      'active': serializer.toJson<int>(active),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? lifeArea,
    Value<int?> startMinutes = const Value.absent(),
    Value<int?> endMinutes = const Value.absent(),
    String? date,
    int? repeatDaily,
    int? repeatWeekly,
    Value<String?> repeatDays = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    int? completed,
    Value<int?> completedAt = const Value.absent(),
    int? createdAt,
    int? active,
  }) => Task(
    id: id ?? this.id,
    title: title ?? this.title,
    lifeArea: lifeArea ?? this.lifeArea,
    startMinutes: startMinutes.present ? startMinutes.value : this.startMinutes,
    endMinutes: endMinutes.present ? endMinutes.value : this.endMinutes,
    date: date ?? this.date,
    repeatDaily: repeatDaily ?? this.repeatDaily,
    repeatWeekly: repeatWeekly ?? this.repeatWeekly,
    repeatDays: repeatDays.present ? repeatDays.value : this.repeatDays,
    notes: notes.present ? notes.value : this.notes,
    completed: completed ?? this.completed,
    completedAt: completedAt.present ? completedAt.value : this.completedAt,
    createdAt: createdAt ?? this.createdAt,
    active: active ?? this.active,
  );
  Task copyWithCompanion(TasksCompanion data) {
    return Task(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      lifeArea: data.lifeArea.present ? data.lifeArea.value : this.lifeArea,
      startMinutes: data.startMinutes.present
          ? data.startMinutes.value
          : this.startMinutes,
      endMinutes: data.endMinutes.present
          ? data.endMinutes.value
          : this.endMinutes,
      date: data.date.present ? data.date.value : this.date,
      repeatDaily: data.repeatDaily.present
          ? data.repeatDaily.value
          : this.repeatDaily,
      repeatWeekly: data.repeatWeekly.present
          ? data.repeatWeekly.value
          : this.repeatWeekly,
      repeatDays: data.repeatDays.present
          ? data.repeatDays.value
          : this.repeatDays,
      notes: data.notes.present ? data.notes.value : this.notes,
      completed: data.completed.present ? data.completed.value : this.completed,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      active: data.active.present ? data.active.value : this.active,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Task(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('lifeArea: $lifeArea, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('date: $date, ')
          ..write('repeatDaily: $repeatDaily, ')
          ..write('repeatWeekly: $repeatWeekly, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('notes: $notes, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    lifeArea,
    startMinutes,
    endMinutes,
    date,
    repeatDaily,
    repeatWeekly,
    repeatDays,
    notes,
    completed,
    completedAt,
    createdAt,
    active,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Task &&
          other.id == this.id &&
          other.title == this.title &&
          other.lifeArea == this.lifeArea &&
          other.startMinutes == this.startMinutes &&
          other.endMinutes == this.endMinutes &&
          other.date == this.date &&
          other.repeatDaily == this.repeatDaily &&
          other.repeatWeekly == this.repeatWeekly &&
          other.repeatDays == this.repeatDays &&
          other.notes == this.notes &&
          other.completed == this.completed &&
          other.completedAt == this.completedAt &&
          other.createdAt == this.createdAt &&
          other.active == this.active);
}

class TasksCompanion extends UpdateCompanion<Task> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> lifeArea;
  final Value<int?> startMinutes;
  final Value<int?> endMinutes;
  final Value<String> date;
  final Value<int> repeatDaily;
  final Value<int> repeatWeekly;
  final Value<String?> repeatDays;
  final Value<String?> notes;
  final Value<int> completed;
  final Value<int?> completedAt;
  final Value<int> createdAt;
  final Value<int> active;
  const TasksCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.lifeArea = const Value.absent(),
    this.startMinutes = const Value.absent(),
    this.endMinutes = const Value.absent(),
    this.date = const Value.absent(),
    this.repeatDaily = const Value.absent(),
    this.repeatWeekly = const Value.absent(),
    this.repeatDays = const Value.absent(),
    this.notes = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.active = const Value.absent(),
  });
  TasksCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    required String lifeArea,
    this.startMinutes = const Value.absent(),
    this.endMinutes = const Value.absent(),
    required String date,
    this.repeatDaily = const Value.absent(),
    this.repeatWeekly = const Value.absent(),
    this.repeatDays = const Value.absent(),
    this.notes = const Value.absent(),
    this.completed = const Value.absent(),
    this.completedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.active = const Value.absent(),
  }) : title = Value(title),
       lifeArea = Value(lifeArea),
       date = Value(date);
  static Insertable<Task> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? lifeArea,
    Expression<int>? startMinutes,
    Expression<int>? endMinutes,
    Expression<String>? date,
    Expression<int>? repeatDaily,
    Expression<int>? repeatWeekly,
    Expression<String>? repeatDays,
    Expression<String>? notes,
    Expression<int>? completed,
    Expression<int>? completedAt,
    Expression<int>? createdAt,
    Expression<int>? active,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (lifeArea != null) 'life_area': lifeArea,
      if (startMinutes != null) 'start_minutes': startMinutes,
      if (endMinutes != null) 'end_minutes': endMinutes,
      if (date != null) 'date': date,
      if (repeatDaily != null) 'repeat_daily': repeatDaily,
      if (repeatWeekly != null) 'repeat_weekly': repeatWeekly,
      if (repeatDays != null) 'repeat_days': repeatDays,
      if (notes != null) 'notes': notes,
      if (completed != null) 'completed': completed,
      if (completedAt != null) 'completed_at': completedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (active != null) 'active': active,
    });
  }

  TasksCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? lifeArea,
    Value<int?>? startMinutes,
    Value<int?>? endMinutes,
    Value<String>? date,
    Value<int>? repeatDaily,
    Value<int>? repeatWeekly,
    Value<String?>? repeatDays,
    Value<String?>? notes,
    Value<int>? completed,
    Value<int?>? completedAt,
    Value<int>? createdAt,
    Value<int>? active,
  }) {
    return TasksCompanion(
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

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (lifeArea.present) {
      map['life_area'] = Variable<String>(lifeArea.value);
    }
    if (startMinutes.present) {
      map['start_minutes'] = Variable<int>(startMinutes.value);
    }
    if (endMinutes.present) {
      map['end_minutes'] = Variable<int>(endMinutes.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (repeatDaily.present) {
      map['repeat_daily'] = Variable<int>(repeatDaily.value);
    }
    if (repeatWeekly.present) {
      map['repeat_weekly'] = Variable<int>(repeatWeekly.value);
    }
    if (repeatDays.present) {
      map['repeat_days'] = Variable<String>(repeatDays.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (completed.present) {
      map['completed'] = Variable<int>(completed.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (active.present) {
      map['active'] = Variable<int>(active.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TasksCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('lifeArea: $lifeArea, ')
          ..write('startMinutes: $startMinutes, ')
          ..write('endMinutes: $endMinutes, ')
          ..write('date: $date, ')
          ..write('repeatDaily: $repeatDaily, ')
          ..write('repeatWeekly: $repeatWeekly, ')
          ..write('repeatDays: $repeatDays, ')
          ..write('notes: $notes, ')
          ..write('completed: $completed, ')
          ..write('completedAt: $completedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('active: $active')
          ..write(')'))
        .toString();
  }
}

class $IntentionEntriesTable extends IntentionEntries
    with TableInfo<$IntentionEntriesTable, IntentionEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $IntentionEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statementMeta = const VerificationMeta(
    'statement',
  );
  @override
  late final GeneratedColumn<String> statement = GeneratedColumn<String>(
    'statement',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _categoryMeta = const VerificationMeta(
    'category',
  );
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
    'category',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<int> completed = GeneratedColumn<int>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reflectionMeta = const VerificationMeta(
    'reflection',
  );
  @override
  late final GeneratedColumn<String> reflection = GeneratedColumn<String>(
    'reflection',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    title,
    statement,
    category,
    completed,
    reflection,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'intention_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<IntentionEntry> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('statement')) {
      context.handle(
        _statementMeta,
        statement.isAcceptableOrUnknown(data['statement']!, _statementMeta),
      );
    }
    if (data.containsKey('category')) {
      context.handle(
        _categoryMeta,
        category.isAcceptableOrUnknown(data['category']!, _categoryMeta),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('reflection')) {
      context.handle(
        _reflectionMeta,
        reflection.isAcceptableOrUnknown(data['reflection']!, _reflectionMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  IntentionEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return IntentionEntry(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      statement: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}statement'],
      ),
      category: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}category'],
      ),
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed'],
      )!,
      reflection: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}reflection'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $IntentionEntriesTable createAlias(String alias) {
    return $IntentionEntriesTable(attachedDatabase, alias);
  }
}

class IntentionEntry extends DataClass implements Insertable<IntentionEntry> {
  final int id;
  final String date;
  final String title;
  final String? statement;
  final String? category;
  final int completed;
  final String? reflection;
  final int createdAt;
  const IntentionEntry({
    required this.id,
    required this.date,
    required this.title,
    this.statement,
    this.category,
    required this.completed,
    this.reflection,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || statement != null) {
      map['statement'] = Variable<String>(statement);
    }
    if (!nullToAbsent || category != null) {
      map['category'] = Variable<String>(category);
    }
    map['completed'] = Variable<int>(completed);
    if (!nullToAbsent || reflection != null) {
      map['reflection'] = Variable<String>(reflection);
    }
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  IntentionEntriesCompanion toCompanion(bool nullToAbsent) {
    return IntentionEntriesCompanion(
      id: Value(id),
      date: Value(date),
      title: Value(title),
      statement: statement == null && nullToAbsent
          ? const Value.absent()
          : Value(statement),
      category: category == null && nullToAbsent
          ? const Value.absent()
          : Value(category),
      completed: Value(completed),
      reflection: reflection == null && nullToAbsent
          ? const Value.absent()
          : Value(reflection),
      createdAt: Value(createdAt),
    );
  }

  factory IntentionEntry.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return IntentionEntry(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      title: serializer.fromJson<String>(json['title']),
      statement: serializer.fromJson<String?>(json['statement']),
      category: serializer.fromJson<String?>(json['category']),
      completed: serializer.fromJson<int>(json['completed']),
      reflection: serializer.fromJson<String?>(json['reflection']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'title': serializer.toJson<String>(title),
      'statement': serializer.toJson<String?>(statement),
      'category': serializer.toJson<String?>(category),
      'completed': serializer.toJson<int>(completed),
      'reflection': serializer.toJson<String?>(reflection),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  IntentionEntry copyWith({
    int? id,
    String? date,
    String? title,
    Value<String?> statement = const Value.absent(),
    Value<String?> category = const Value.absent(),
    int? completed,
    Value<String?> reflection = const Value.absent(),
    int? createdAt,
  }) => IntentionEntry(
    id: id ?? this.id,
    date: date ?? this.date,
    title: title ?? this.title,
    statement: statement.present ? statement.value : this.statement,
    category: category.present ? category.value : this.category,
    completed: completed ?? this.completed,
    reflection: reflection.present ? reflection.value : this.reflection,
    createdAt: createdAt ?? this.createdAt,
  );
  IntentionEntry copyWithCompanion(IntentionEntriesCompanion data) {
    return IntentionEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      title: data.title.present ? data.title.value : this.title,
      statement: data.statement.present ? data.statement.value : this.statement,
      category: data.category.present ? data.category.value : this.category,
      completed: data.completed.present ? data.completed.value : this.completed,
      reflection: data.reflection.present
          ? data.reflection.value
          : this.reflection,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('IntentionEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('statement: $statement, ')
          ..write('category: $category, ')
          ..write('completed: $completed, ')
          ..write('reflection: $reflection, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    title,
    statement,
    category,
    completed,
    reflection,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is IntentionEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.title == this.title &&
          other.statement == this.statement &&
          other.category == this.category &&
          other.completed == this.completed &&
          other.reflection == this.reflection &&
          other.createdAt == this.createdAt);
}

class IntentionEntriesCompanion extends UpdateCompanion<IntentionEntry> {
  final Value<int> id;
  final Value<String> date;
  final Value<String> title;
  final Value<String?> statement;
  final Value<String?> category;
  final Value<int> completed;
  final Value<String?> reflection;
  final Value<int> createdAt;
  const IntentionEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.title = const Value.absent(),
    this.statement = const Value.absent(),
    this.category = const Value.absent(),
    this.completed = const Value.absent(),
    this.reflection = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  IntentionEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    required String title,
    this.statement = const Value.absent(),
    this.category = const Value.absent(),
    this.completed = const Value.absent(),
    this.reflection = const Value.absent(),
    this.createdAt = const Value.absent(),
  }) : date = Value(date),
       title = Value(title);
  static Insertable<IntentionEntry> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? title,
    Expression<String>? statement,
    Expression<String>? category,
    Expression<int>? completed,
    Expression<String>? reflection,
    Expression<int>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (title != null) 'title': title,
      if (statement != null) 'statement': statement,
      if (category != null) 'category': category,
      if (completed != null) 'completed': completed,
      if (reflection != null) 'reflection': reflection,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  IntentionEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String>? title,
    Value<String?>? statement,
    Value<String?>? category,
    Value<int>? completed,
    Value<String?>? reflection,
    Value<int>? createdAt,
  }) {
    return IntentionEntriesCompanion(
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

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (statement.present) {
      map['statement'] = Variable<String>(statement.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (completed.present) {
      map['completed'] = Variable<int>(completed.value);
    }
    if (reflection.present) {
      map['reflection'] = Variable<String>(reflection.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('IntentionEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('title: $title, ')
          ..write('statement: $statement, ')
          ..write('category: $category, ')
          ..write('completed: $completed, ')
          ..write('reflection: $reflection, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $BarakahDailyResponsesTable extends BarakahDailyResponses
    with TableInfo<$BarakahDailyResponsesTable, BarakahDailyResponseRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $BarakahDailyResponsesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptIdMeta = const VerificationMeta(
    'promptId',
  );
  @override
  late final GeneratedColumn<String> promptId = GeneratedColumn<String>(
    'prompt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answerMeta = const VerificationMeta('answer');
  @override
  late final GeneratedColumn<String> answer = GeneratedColumn<String>(
    'answer',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceIdsMeta = const VerificationMeta(
    'sourceIds',
  );
  @override
  late final GeneratedColumn<String> sourceIds = GeneratedColumn<String>(
    'source_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
    'note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const CustomExpression<int>("(strftime('%s','now') * 1000)"),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    date,
    promptId,
    answer,
    sourceIds,
    note,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'barakah_daily_responses';
  @override
  VerificationContext validateIntegrity(
    Insertable<BarakahDailyResponseRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('prompt_id')) {
      context.handle(
        _promptIdMeta,
        promptId.isAcceptableOrUnknown(data['prompt_id']!, _promptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_promptIdMeta);
    }
    if (data.containsKey('answer')) {
      context.handle(
        _answerMeta,
        answer.isAcceptableOrUnknown(data['answer']!, _answerMeta),
      );
    } else if (isInserting) {
      context.missing(_answerMeta);
    }
    if (data.containsKey('source_ids')) {
      context.handle(
        _sourceIdsMeta,
        sourceIds.isAcceptableOrUnknown(data['source_ids']!, _sourceIdsMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceIdsMeta);
    }
    if (data.containsKey('note')) {
      context.handle(
        _noteMeta,
        note.isAcceptableOrUnknown(data['note']!, _noteMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {date};
  @override
  BarakahDailyResponseRow map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return BarakahDailyResponseRow(
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      promptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_id'],
      )!,
      answer: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answer'],
      )!,
      sourceIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_ids'],
      )!,
      note: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}note'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $BarakahDailyResponsesTable createAlias(String alias) {
    return $BarakahDailyResponsesTable(attachedDatabase, alias);
  }
}

class BarakahDailyResponseRow extends DataClass
    implements Insertable<BarakahDailyResponseRow> {
  final String date;
  final String promptId;
  final String answer;
  final String sourceIds;
  final String? note;
  final int createdAt;
  final int updatedAt;
  const BarakahDailyResponseRow({
    required this.date,
    required this.promptId,
    required this.answer,
    required this.sourceIds,
    this.note,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['date'] = Variable<String>(date);
    map['prompt_id'] = Variable<String>(promptId);
    map['answer'] = Variable<String>(answer);
    map['source_ids'] = Variable<String>(sourceIds);
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  BarakahDailyResponsesCompanion toCompanion(bool nullToAbsent) {
    return BarakahDailyResponsesCompanion(
      date: Value(date),
      promptId: Value(promptId),
      answer: Value(answer),
      sourceIds: Value(sourceIds),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory BarakahDailyResponseRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return BarakahDailyResponseRow(
      date: serializer.fromJson<String>(json['date']),
      promptId: serializer.fromJson<String>(json['promptId']),
      answer: serializer.fromJson<String>(json['answer']),
      sourceIds: serializer.fromJson<String>(json['sourceIds']),
      note: serializer.fromJson<String?>(json['note']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'date': serializer.toJson<String>(date),
      'promptId': serializer.toJson<String>(promptId),
      'answer': serializer.toJson<String>(answer),
      'sourceIds': serializer.toJson<String>(sourceIds),
      'note': serializer.toJson<String?>(note),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  BarakahDailyResponseRow copyWith({
    String? date,
    String? promptId,
    String? answer,
    String? sourceIds,
    Value<String?> note = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => BarakahDailyResponseRow(
    date: date ?? this.date,
    promptId: promptId ?? this.promptId,
    answer: answer ?? this.answer,
    sourceIds: sourceIds ?? this.sourceIds,
    note: note.present ? note.value : this.note,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  BarakahDailyResponseRow copyWithCompanion(
    BarakahDailyResponsesCompanion data,
  ) {
    return BarakahDailyResponseRow(
      date: data.date.present ? data.date.value : this.date,
      promptId: data.promptId.present ? data.promptId.value : this.promptId,
      answer: data.answer.present ? data.answer.value : this.answer,
      sourceIds: data.sourceIds.present ? data.sourceIds.value : this.sourceIds,
      note: data.note.present ? data.note.value : this.note,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('BarakahDailyResponseRow(')
          ..write('date: $date, ')
          ..write('promptId: $promptId, ')
          ..write('answer: $answer, ')
          ..write('sourceIds: $sourceIds, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    date,
    promptId,
    answer,
    sourceIds,
    note,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is BarakahDailyResponseRow &&
          other.date == this.date &&
          other.promptId == this.promptId &&
          other.answer == this.answer &&
          other.sourceIds == this.sourceIds &&
          other.note == this.note &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class BarakahDailyResponsesCompanion
    extends UpdateCompanion<BarakahDailyResponseRow> {
  final Value<String> date;
  final Value<String> promptId;
  final Value<String> answer;
  final Value<String> sourceIds;
  final Value<String?> note;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  final Value<int> rowid;
  const BarakahDailyResponsesCompanion({
    this.date = const Value.absent(),
    this.promptId = const Value.absent(),
    this.answer = const Value.absent(),
    this.sourceIds = const Value.absent(),
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  BarakahDailyResponsesCompanion.insert({
    required String date,
    required String promptId,
    required String answer,
    required String sourceIds,
    this.note = const Value.absent(),
    this.createdAt = const Value.absent(),
    required int updatedAt,
    this.rowid = const Value.absent(),
  }) : date = Value(date),
       promptId = Value(promptId),
       answer = Value(answer),
       sourceIds = Value(sourceIds),
       updatedAt = Value(updatedAt);
  static Insertable<BarakahDailyResponseRow> custom({
    Expression<String>? date,
    Expression<String>? promptId,
    Expression<String>? answer,
    Expression<String>? sourceIds,
    Expression<String>? note,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (date != null) 'date': date,
      if (promptId != null) 'prompt_id': promptId,
      if (answer != null) 'answer': answer,
      if (sourceIds != null) 'source_ids': sourceIds,
      if (note != null) 'note': note,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  BarakahDailyResponsesCompanion copyWith({
    Value<String>? date,
    Value<String>? promptId,
    Value<String>? answer,
    Value<String>? sourceIds,
    Value<String?>? note,
    Value<int>? createdAt,
    Value<int>? updatedAt,
    Value<int>? rowid,
  }) {
    return BarakahDailyResponsesCompanion(
      date: date ?? this.date,
      promptId: promptId ?? this.promptId,
      answer: answer ?? this.answer,
      sourceIds: sourceIds ?? this.sourceIds,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (promptId.present) {
      map['prompt_id'] = Variable<String>(promptId.value);
    }
    if (answer.present) {
      map['answer'] = Variable<String>(answer.value);
    }
    if (sourceIds.present) {
      map['source_ids'] = Variable<String>(sourceIds.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('BarakahDailyResponsesCompanion(')
          ..write('date: $date, ')
          ..write('promptId: $promptId, ')
          ..write('answer: $answer, ')
          ..write('sourceIds: $sourceIds, ')
          ..write('note: $note, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MuhasabahEntriesTable extends MuhasabahEntries
    with TableInfo<$MuhasabahEntriesTable, MuhasabahEntryRow> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MuhasabahEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _promptIdMeta = const VerificationMeta(
    'promptId',
  );
  @override
  late final GeneratedColumn<String> promptId = GeneratedColumn<String>(
    'prompt_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _promptTextMeta = const VerificationMeta(
    'promptText',
  );
  @override
  late final GeneratedColumn<String> promptText = GeneratedColumn<String>(
    'prompt_text',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _contentMeta = const VerificationMeta(
    'content',
  );
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
    'content',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagsMeta = const VerificationMeta('tags');
  @override
  late final GeneratedColumn<String> tags = GeneratedColumn<String>(
    'tags',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<int> updatedAt = GeneratedColumn<int>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    date,
    promptId,
    promptText,
    content,
    tags,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'muhasabah_entries';
  @override
  VerificationContext validateIntegrity(
    Insertable<MuhasabahEntryRow> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('prompt_id')) {
      context.handle(
        _promptIdMeta,
        promptId.isAcceptableOrUnknown(data['prompt_id']!, _promptIdMeta),
      );
    }
    if (data.containsKey('prompt_text')) {
      context.handle(
        _promptTextMeta,
        promptText.isAcceptableOrUnknown(data['prompt_text']!, _promptTextMeta),
      );
    }
    if (data.containsKey('content')) {
      context.handle(
        _contentMeta,
        content.isAcceptableOrUnknown(data['content']!, _contentMeta),
      );
    } else if (isInserting) {
      context.missing(_contentMeta);
    }
    if (data.containsKey('tags')) {
      context.handle(
        _tagsMeta,
        tags.isAcceptableOrUnknown(data['tags']!, _tagsMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MuhasabahEntryRow map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MuhasabahEntryRow(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      promptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_id'],
      ),
      promptText: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}prompt_text'],
      ),
      content: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content'],
      )!,
      tags: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tags'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MuhasabahEntriesTable createAlias(String alias) {
    return $MuhasabahEntriesTable(attachedDatabase, alias);
  }
}

class MuhasabahEntryRow extends DataClass
    implements Insertable<MuhasabahEntryRow> {
  final int id;
  final String date;
  final String? promptId;
  final String? promptText;
  final String content;
  final String? tags;
  final int createdAt;
  final int updatedAt;
  const MuhasabahEntryRow({
    required this.id,
    required this.date,
    this.promptId,
    this.promptText,
    required this.content,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['date'] = Variable<String>(date);
    if (!nullToAbsent || promptId != null) {
      map['prompt_id'] = Variable<String>(promptId);
    }
    if (!nullToAbsent || promptText != null) {
      map['prompt_text'] = Variable<String>(promptText);
    }
    map['content'] = Variable<String>(content);
    if (!nullToAbsent || tags != null) {
      map['tags'] = Variable<String>(tags);
    }
    map['created_at'] = Variable<int>(createdAt);
    map['updated_at'] = Variable<int>(updatedAt);
    return map;
  }

  MuhasabahEntriesCompanion toCompanion(bool nullToAbsent) {
    return MuhasabahEntriesCompanion(
      id: Value(id),
      date: Value(date),
      promptId: promptId == null && nullToAbsent
          ? const Value.absent()
          : Value(promptId),
      promptText: promptText == null && nullToAbsent
          ? const Value.absent()
          : Value(promptText),
      content: Value(content),
      tags: tags == null && nullToAbsent ? const Value.absent() : Value(tags),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory MuhasabahEntryRow.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MuhasabahEntryRow(
      id: serializer.fromJson<int>(json['id']),
      date: serializer.fromJson<String>(json['date']),
      promptId: serializer.fromJson<String?>(json['promptId']),
      promptText: serializer.fromJson<String?>(json['promptText']),
      content: serializer.fromJson<String>(json['content']),
      tags: serializer.fromJson<String?>(json['tags']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
      updatedAt: serializer.fromJson<int>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'date': serializer.toJson<String>(date),
      'promptId': serializer.toJson<String?>(promptId),
      'promptText': serializer.toJson<String?>(promptText),
      'content': serializer.toJson<String>(content),
      'tags': serializer.toJson<String?>(tags),
      'createdAt': serializer.toJson<int>(createdAt),
      'updatedAt': serializer.toJson<int>(updatedAt),
    };
  }

  MuhasabahEntryRow copyWith({
    int? id,
    String? date,
    Value<String?> promptId = const Value.absent(),
    Value<String?> promptText = const Value.absent(),
    String? content,
    Value<String?> tags = const Value.absent(),
    int? createdAt,
    int? updatedAt,
  }) => MuhasabahEntryRow(
    id: id ?? this.id,
    date: date ?? this.date,
    promptId: promptId.present ? promptId.value : this.promptId,
    promptText: promptText.present ? promptText.value : this.promptText,
    content: content ?? this.content,
    tags: tags.present ? tags.value : this.tags,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MuhasabahEntryRow copyWithCompanion(MuhasabahEntriesCompanion data) {
    return MuhasabahEntryRow(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      promptId: data.promptId.present ? data.promptId.value : this.promptId,
      promptText: data.promptText.present
          ? data.promptText.value
          : this.promptText,
      content: data.content.present ? data.content.value : this.content,
      tags: data.tags.present ? data.tags.value : this.tags,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MuhasabahEntryRow(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('promptId: $promptId, ')
          ..write('promptText: $promptText, ')
          ..write('content: $content, ')
          ..write('tags: $tags, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    date,
    promptId,
    promptText,
    content,
    tags,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MuhasabahEntryRow &&
          other.id == this.id &&
          other.date == this.date &&
          other.promptId == this.promptId &&
          other.promptText == this.promptText &&
          other.content == this.content &&
          other.tags == this.tags &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class MuhasabahEntriesCompanion extends UpdateCompanion<MuhasabahEntryRow> {
  final Value<int> id;
  final Value<String> date;
  final Value<String?> promptId;
  final Value<String?> promptText;
  final Value<String> content;
  final Value<String?> tags;
  final Value<int> createdAt;
  final Value<int> updatedAt;
  const MuhasabahEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.promptId = const Value.absent(),
    this.promptText = const Value.absent(),
    this.content = const Value.absent(),
    this.tags = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  MuhasabahEntriesCompanion.insert({
    this.id = const Value.absent(),
    required String date,
    this.promptId = const Value.absent(),
    this.promptText = const Value.absent(),
    required String content,
    this.tags = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : date = Value(date),
       content = Value(content);
  static Insertable<MuhasabahEntryRow> custom({
    Expression<int>? id,
    Expression<String>? date,
    Expression<String>? promptId,
    Expression<String>? promptText,
    Expression<String>? content,
    Expression<String>? tags,
    Expression<int>? createdAt,
    Expression<int>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (promptId != null) 'prompt_id': promptId,
      if (promptText != null) 'prompt_text': promptText,
      if (content != null) 'content': content,
      if (tags != null) 'tags': tags,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  MuhasabahEntriesCompanion copyWith({
    Value<int>? id,
    Value<String>? date,
    Value<String?>? promptId,
    Value<String?>? promptText,
    Value<String>? content,
    Value<String?>? tags,
    Value<int>? createdAt,
    Value<int>? updatedAt,
  }) {
    return MuhasabahEntriesCompanion(
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

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (promptId.present) {
      map['prompt_id'] = Variable<String>(promptId.value);
    }
    if (promptText.present) {
      map['prompt_text'] = Variable<String>(promptText.value);
    }
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (tags.present) {
      map['tags'] = Variable<String>(tags.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<int>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MuhasabahEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('promptId: $promptId, ')
          ..write('promptText: $promptText, ')
          ..write('content: $content, ')
          ..write('tags: $tags, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $AdhkarBookmarksTable extends AdhkarBookmarks
    with TableInfo<$AdhkarBookmarksTable, AdhkarBookmark> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdhkarBookmarksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _dhikrIdMeta = const VerificationMeta(
    'dhikrId',
  );
  @override
  late final GeneratedColumn<String> dhikrId = GeneratedColumn<String>(
    'dhikr_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<int> createdAt = GeneratedColumn<int>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [dhikrId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adhkar_bookmarks';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdhkarBookmark> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('dhikr_id')) {
      context.handle(
        _dhikrIdMeta,
        dhikrId.isAcceptableOrUnknown(data['dhikr_id']!, _dhikrIdMeta),
      );
    } else if (isInserting) {
      context.missing(_dhikrIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {dhikrId};
  @override
  AdhkarBookmark map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdhkarBookmark(
      dhikrId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dhikr_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $AdhkarBookmarksTable createAlias(String alias) {
    return $AdhkarBookmarksTable(attachedDatabase, alias);
  }
}

class AdhkarBookmark extends DataClass implements Insertable<AdhkarBookmark> {
  final String dhikrId;
  final int createdAt;
  const AdhkarBookmark({required this.dhikrId, required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['dhikr_id'] = Variable<String>(dhikrId);
    map['created_at'] = Variable<int>(createdAt);
    return map;
  }

  AdhkarBookmarksCompanion toCompanion(bool nullToAbsent) {
    return AdhkarBookmarksCompanion(
      dhikrId: Value(dhikrId),
      createdAt: Value(createdAt),
    );
  }

  factory AdhkarBookmark.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdhkarBookmark(
      dhikrId: serializer.fromJson<String>(json['dhikrId']),
      createdAt: serializer.fromJson<int>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'dhikrId': serializer.toJson<String>(dhikrId),
      'createdAt': serializer.toJson<int>(createdAt),
    };
  }

  AdhkarBookmark copyWith({String? dhikrId, int? createdAt}) => AdhkarBookmark(
    dhikrId: dhikrId ?? this.dhikrId,
    createdAt: createdAt ?? this.createdAt,
  );
  AdhkarBookmark copyWithCompanion(AdhkarBookmarksCompanion data) {
    return AdhkarBookmark(
      dhikrId: data.dhikrId.present ? data.dhikrId.value : this.dhikrId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarBookmark(')
          ..write('dhikrId: $dhikrId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(dhikrId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdhkarBookmark &&
          other.dhikrId == this.dhikrId &&
          other.createdAt == this.createdAt);
}

class AdhkarBookmarksCompanion extends UpdateCompanion<AdhkarBookmark> {
  final Value<String> dhikrId;
  final Value<int> createdAt;
  final Value<int> rowid;
  const AdhkarBookmarksCompanion({
    this.dhikrId = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdhkarBookmarksCompanion.insert({
    required String dhikrId,
    required int createdAt,
    this.rowid = const Value.absent(),
  }) : dhikrId = Value(dhikrId),
       createdAt = Value(createdAt);
  static Insertable<AdhkarBookmark> custom({
    Expression<String>? dhikrId,
    Expression<int>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (dhikrId != null) 'dhikr_id': dhikrId,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdhkarBookmarksCompanion copyWith({
    Value<String>? dhikrId,
    Value<int>? createdAt,
    Value<int>? rowid,
  }) {
    return AdhkarBookmarksCompanion(
      dhikrId: dhikrId ?? this.dhikrId,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (dhikrId.present) {
      map['dhikr_id'] = Variable<String>(dhikrId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<int>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarBookmarksCompanion(')
          ..write('dhikrId: $dhikrId, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AdhkarSessionsTable extends AdhkarSessions
    with TableInfo<$AdhkarSessionsTable, AdhkarSession> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdhkarSessionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _lastPageIndexMeta = const VerificationMeta(
    'lastPageIndex',
  );
  @override
  late final GeneratedColumn<int> lastPageIndex = GeneratedColumn<int>(
    'last_page_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _countsJsonMeta = const VerificationMeta(
    'countsJson',
  );
  @override
  late final GeneratedColumn<String> countsJson = GeneratedColumn<String>(
    'counts_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _lastAccessedAtMeta = const VerificationMeta(
    'lastAccessedAt',
  );
  @override
  late final GeneratedColumn<int> lastAccessedAt = GeneratedColumn<int>(
    'last_accessed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isCompletedMeta = const VerificationMeta(
    'isCompleted',
  );
  @override
  late final GeneratedColumn<bool> isCompleted = GeneratedColumn<bool>(
    'is_completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    collectionId,
    lastPageIndex,
    countsJson,
    lastAccessedAt,
    isCompleted,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adhkar_sessions';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdhkarSession> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('last_page_index')) {
      context.handle(
        _lastPageIndexMeta,
        lastPageIndex.isAcceptableOrUnknown(
          data['last_page_index']!,
          _lastPageIndexMeta,
        ),
      );
    }
    if (data.containsKey('counts_json')) {
      context.handle(
        _countsJsonMeta,
        countsJson.isAcceptableOrUnknown(data['counts_json']!, _countsJsonMeta),
      );
    }
    if (data.containsKey('last_accessed_at')) {
      context.handle(
        _lastAccessedAtMeta,
        lastAccessedAt.isAcceptableOrUnknown(
          data['last_accessed_at']!,
          _lastAccessedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_lastAccessedAtMeta);
    }
    if (data.containsKey('is_completed')) {
      context.handle(
        _isCompletedMeta,
        isCompleted.isAcceptableOrUnknown(
          data['is_completed']!,
          _isCompletedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {collectionId};
  @override
  AdhkarSession map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdhkarSession(
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      )!,
      lastPageIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_page_index'],
      )!,
      countsJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}counts_json'],
      )!,
      lastAccessedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}last_accessed_at'],
      )!,
      isCompleted: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_completed'],
      )!,
    );
  }

  @override
  $AdhkarSessionsTable createAlias(String alias) {
    return $AdhkarSessionsTable(attachedDatabase, alias);
  }
}

class AdhkarSession extends DataClass implements Insertable<AdhkarSession> {
  final String collectionId;
  final int lastPageIndex;
  final String countsJson;
  final int lastAccessedAt;
  final bool isCompleted;
  const AdhkarSession({
    required this.collectionId,
    required this.lastPageIndex,
    required this.countsJson,
    required this.lastAccessedAt,
    required this.isCompleted,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['collection_id'] = Variable<String>(collectionId);
    map['last_page_index'] = Variable<int>(lastPageIndex);
    map['counts_json'] = Variable<String>(countsJson);
    map['last_accessed_at'] = Variable<int>(lastAccessedAt);
    map['is_completed'] = Variable<bool>(isCompleted);
    return map;
  }

  AdhkarSessionsCompanion toCompanion(bool nullToAbsent) {
    return AdhkarSessionsCompanion(
      collectionId: Value(collectionId),
      lastPageIndex: Value(lastPageIndex),
      countsJson: Value(countsJson),
      lastAccessedAt: Value(lastAccessedAt),
      isCompleted: Value(isCompleted),
    );
  }

  factory AdhkarSession.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdhkarSession(
      collectionId: serializer.fromJson<String>(json['collectionId']),
      lastPageIndex: serializer.fromJson<int>(json['lastPageIndex']),
      countsJson: serializer.fromJson<String>(json['countsJson']),
      lastAccessedAt: serializer.fromJson<int>(json['lastAccessedAt']),
      isCompleted: serializer.fromJson<bool>(json['isCompleted']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'collectionId': serializer.toJson<String>(collectionId),
      'lastPageIndex': serializer.toJson<int>(lastPageIndex),
      'countsJson': serializer.toJson<String>(countsJson),
      'lastAccessedAt': serializer.toJson<int>(lastAccessedAt),
      'isCompleted': serializer.toJson<bool>(isCompleted),
    };
  }

  AdhkarSession copyWith({
    String? collectionId,
    int? lastPageIndex,
    String? countsJson,
    int? lastAccessedAt,
    bool? isCompleted,
  }) => AdhkarSession(
    collectionId: collectionId ?? this.collectionId,
    lastPageIndex: lastPageIndex ?? this.lastPageIndex,
    countsJson: countsJson ?? this.countsJson,
    lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
    isCompleted: isCompleted ?? this.isCompleted,
  );
  AdhkarSession copyWithCompanion(AdhkarSessionsCompanion data) {
    return AdhkarSession(
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      lastPageIndex: data.lastPageIndex.present
          ? data.lastPageIndex.value
          : this.lastPageIndex,
      countsJson: data.countsJson.present
          ? data.countsJson.value
          : this.countsJson,
      lastAccessedAt: data.lastAccessedAt.present
          ? data.lastAccessedAt.value
          : this.lastAccessedAt,
      isCompleted: data.isCompleted.present
          ? data.isCompleted.value
          : this.isCompleted,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarSession(')
          ..write('collectionId: $collectionId, ')
          ..write('lastPageIndex: $lastPageIndex, ')
          ..write('countsJson: $countsJson, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('isCompleted: $isCompleted')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    collectionId,
    lastPageIndex,
    countsJson,
    lastAccessedAt,
    isCompleted,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdhkarSession &&
          other.collectionId == this.collectionId &&
          other.lastPageIndex == this.lastPageIndex &&
          other.countsJson == this.countsJson &&
          other.lastAccessedAt == this.lastAccessedAt &&
          other.isCompleted == this.isCompleted);
}

class AdhkarSessionsCompanion extends UpdateCompanion<AdhkarSession> {
  final Value<String> collectionId;
  final Value<int> lastPageIndex;
  final Value<String> countsJson;
  final Value<int> lastAccessedAt;
  final Value<bool> isCompleted;
  final Value<int> rowid;
  const AdhkarSessionsCompanion({
    this.collectionId = const Value.absent(),
    this.lastPageIndex = const Value.absent(),
    this.countsJson = const Value.absent(),
    this.lastAccessedAt = const Value.absent(),
    this.isCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AdhkarSessionsCompanion.insert({
    required String collectionId,
    this.lastPageIndex = const Value.absent(),
    this.countsJson = const Value.absent(),
    required int lastAccessedAt,
    this.isCompleted = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : collectionId = Value(collectionId),
       lastAccessedAt = Value(lastAccessedAt);
  static Insertable<AdhkarSession> custom({
    Expression<String>? collectionId,
    Expression<int>? lastPageIndex,
    Expression<String>? countsJson,
    Expression<int>? lastAccessedAt,
    Expression<bool>? isCompleted,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (collectionId != null) 'collection_id': collectionId,
      if (lastPageIndex != null) 'last_page_index': lastPageIndex,
      if (countsJson != null) 'counts_json': countsJson,
      if (lastAccessedAt != null) 'last_accessed_at': lastAccessedAt,
      if (isCompleted != null) 'is_completed': isCompleted,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AdhkarSessionsCompanion copyWith({
    Value<String>? collectionId,
    Value<int>? lastPageIndex,
    Value<String>? countsJson,
    Value<int>? lastAccessedAt,
    Value<bool>? isCompleted,
    Value<int>? rowid,
  }) {
    return AdhkarSessionsCompanion(
      collectionId: collectionId ?? this.collectionId,
      lastPageIndex: lastPageIndex ?? this.lastPageIndex,
      countsJson: countsJson ?? this.countsJson,
      lastAccessedAt: lastAccessedAt ?? this.lastAccessedAt,
      isCompleted: isCompleted ?? this.isCompleted,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (lastPageIndex.present) {
      map['last_page_index'] = Variable<int>(lastPageIndex.value);
    }
    if (countsJson.present) {
      map['counts_json'] = Variable<String>(countsJson.value);
    }
    if (lastAccessedAt.present) {
      map['last_accessed_at'] = Variable<int>(lastAccessedAt.value);
    }
    if (isCompleted.present) {
      map['is_completed'] = Variable<bool>(isCompleted.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarSessionsCompanion(')
          ..write('collectionId: $collectionId, ')
          ..write('lastPageIndex: $lastPageIndex, ')
          ..write('countsJson: $countsJson, ')
          ..write('lastAccessedAt: $lastAccessedAt, ')
          ..write('isCompleted: $isCompleted, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AdhkarCompletionsTable extends AdhkarCompletions
    with TableInfo<$AdhkarCompletionsTable, AdhkarCompletion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AdhkarCompletionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _collectionIdMeta = const VerificationMeta(
    'collectionId',
  );
  @override
  late final GeneratedColumn<String> collectionId = GeneratedColumn<String>(
    'collection_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<String> date = GeneratedColumn<String>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _completedAtMeta = const VerificationMeta(
    'completedAt',
  );
  @override
  late final GeneratedColumn<int> completedAt = GeneratedColumn<int>(
    'completed_at',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, collectionId, date, completedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'adhkar_completions';
  @override
  VerificationContext validateIntegrity(
    Insertable<AdhkarCompletion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('collection_id')) {
      context.handle(
        _collectionIdMeta,
        collectionId.isAcceptableOrUnknown(
          data['collection_id']!,
          _collectionIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_collectionIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('completed_at')) {
      context.handle(
        _completedAtMeta,
        completedAt.isAcceptableOrUnknown(
          data['completed_at']!,
          _completedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_completedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {collectionId, date},
  ];
  @override
  AdhkarCompletion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AdhkarCompletion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      collectionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}collection_id'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}date'],
      )!,
      completedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}completed_at'],
      )!,
    );
  }

  @override
  $AdhkarCompletionsTable createAlias(String alias) {
    return $AdhkarCompletionsTable(attachedDatabase, alias);
  }
}

class AdhkarCompletion extends DataClass
    implements Insertable<AdhkarCompletion> {
  final int id;
  final String collectionId;
  final String date;
  final int completedAt;
  const AdhkarCompletion({
    required this.id,
    required this.collectionId,
    required this.date,
    required this.completedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['collection_id'] = Variable<String>(collectionId);
    map['date'] = Variable<String>(date);
    map['completed_at'] = Variable<int>(completedAt);
    return map;
  }

  AdhkarCompletionsCompanion toCompanion(bool nullToAbsent) {
    return AdhkarCompletionsCompanion(
      id: Value(id),
      collectionId: Value(collectionId),
      date: Value(date),
      completedAt: Value(completedAt),
    );
  }

  factory AdhkarCompletion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AdhkarCompletion(
      id: serializer.fromJson<int>(json['id']),
      collectionId: serializer.fromJson<String>(json['collectionId']),
      date: serializer.fromJson<String>(json['date']),
      completedAt: serializer.fromJson<int>(json['completedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'collectionId': serializer.toJson<String>(collectionId),
      'date': serializer.toJson<String>(date),
      'completedAt': serializer.toJson<int>(completedAt),
    };
  }

  AdhkarCompletion copyWith({
    int? id,
    String? collectionId,
    String? date,
    int? completedAt,
  }) => AdhkarCompletion(
    id: id ?? this.id,
    collectionId: collectionId ?? this.collectionId,
    date: date ?? this.date,
    completedAt: completedAt ?? this.completedAt,
  );
  AdhkarCompletion copyWithCompanion(AdhkarCompletionsCompanion data) {
    return AdhkarCompletion(
      id: data.id.present ? data.id.value : this.id,
      collectionId: data.collectionId.present
          ? data.collectionId.value
          : this.collectionId,
      date: data.date.present ? data.date.value : this.date,
      completedAt: data.completedAt.present
          ? data.completedAt.value
          : this.completedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarCompletion(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('date: $date, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, collectionId, date, completedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AdhkarCompletion &&
          other.id == this.id &&
          other.collectionId == this.collectionId &&
          other.date == this.date &&
          other.completedAt == this.completedAt);
}

class AdhkarCompletionsCompanion extends UpdateCompanion<AdhkarCompletion> {
  final Value<int> id;
  final Value<String> collectionId;
  final Value<String> date;
  final Value<int> completedAt;
  const AdhkarCompletionsCompanion({
    this.id = const Value.absent(),
    this.collectionId = const Value.absent(),
    this.date = const Value.absent(),
    this.completedAt = const Value.absent(),
  });
  AdhkarCompletionsCompanion.insert({
    this.id = const Value.absent(),
    required String collectionId,
    required String date,
    required int completedAt,
  }) : collectionId = Value(collectionId),
       date = Value(date),
       completedAt = Value(completedAt);
  static Insertable<AdhkarCompletion> custom({
    Expression<int>? id,
    Expression<String>? collectionId,
    Expression<String>? date,
    Expression<int>? completedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (collectionId != null) 'collection_id': collectionId,
      if (date != null) 'date': date,
      if (completedAt != null) 'completed_at': completedAt,
    });
  }

  AdhkarCompletionsCompanion copyWith({
    Value<int>? id,
    Value<String>? collectionId,
    Value<String>? date,
    Value<int>? completedAt,
  }) {
    return AdhkarCompletionsCompanion(
      id: id ?? this.id,
      collectionId: collectionId ?? this.collectionId,
      date: date ?? this.date,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (collectionId.present) {
      map['collection_id'] = Variable<String>(collectionId.value);
    }
    if (date.present) {
      map['date'] = Variable<String>(date.value);
    }
    if (completedAt.present) {
      map['completed_at'] = Variable<int>(completedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AdhkarCompletionsCompanion(')
          ..write('id: $id, ')
          ..write('collectionId: $collectionId, ')
          ..write('date: $date, ')
          ..write('completedAt: $completedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BarakahEntriesTable barakahEntries = $BarakahEntriesTable(this);
  late final $BarakahPromptsTable barakahPrompts = $BarakahPromptsTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $HabitCompletionsTable habitCompletions = $HabitCompletionsTable(
    this,
  );
  late final $TasksTable tasks = $TasksTable(this);
  late final $IntentionEntriesTable intentionEntries = $IntentionEntriesTable(
    this,
  );
  late final $BarakahDailyResponsesTable barakahDailyResponses =
      $BarakahDailyResponsesTable(this);
  late final $MuhasabahEntriesTable muhasabahEntries = $MuhasabahEntriesTable(
    this,
  );
  late final $AdhkarBookmarksTable adhkarBookmarks = $AdhkarBookmarksTable(
    this,
  );
  late final $AdhkarSessionsTable adhkarSessions = $AdhkarSessionsTable(this);
  late final $AdhkarCompletionsTable adhkarCompletions =
      $AdhkarCompletionsTable(this);
  late final BarakahDao barakahDao = BarakahDao(this as AppDatabase);
  late final HabitDao habitDao = HabitDao(this as AppDatabase);
  late final HabitCompletionsDao habitCompletionsDao = HabitCompletionsDao(
    this as AppDatabase,
  );
  late final TaskDao taskDao = TaskDao(this as AppDatabase);
  late final IntentionDao intentionDao = IntentionDao(this as AppDatabase);
  late final MuhasabahDao muhasabahDao = MuhasabahDao(this as AppDatabase);
  late final AdhkarDao adhkarDao = AdhkarDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    barakahEntries,
    barakahPrompts,
    habits,
    habitCompletions,
    tasks,
    intentionEntries,
    barakahDailyResponses,
    muhasabahEntries,
    adhkarBookmarks,
    adhkarSessions,
    adhkarCompletions,
  ];
}

typedef $$BarakahEntriesTableCreateCompanionBuilder =
    BarakahEntriesCompanion Function({
      Value<int> id,
      required String date,
      required String sourceIds,
      Value<String?> promptId,
      Value<int?> intensity,
      Value<String?> note,
      Value<int> skipped,
      Value<int> createdAt,
    });
typedef $$BarakahEntriesTableUpdateCompanionBuilder =
    BarakahEntriesCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String> sourceIds,
      Value<String?> promptId,
      Value<int?> intensity,
      Value<String?> note,
      Value<int> skipped,
      Value<int> createdAt,
    });

class $$BarakahEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $BarakahEntriesTable> {
  $$BarakahEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceIds => $composableBuilder(
    column: $table.sourceIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promptId => $composableBuilder(
    column: $table.promptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BarakahEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $BarakahEntriesTable> {
  $$BarakahEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceIds => $composableBuilder(
    column: $table.sourceIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promptId => $composableBuilder(
    column: $table.promptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get intensity => $composableBuilder(
    column: $table.intensity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get skipped => $composableBuilder(
    column: $table.skipped,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BarakahEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BarakahEntriesTable> {
  $$BarakahEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get sourceIds =>
      $composableBuilder(column: $table.sourceIds, builder: (column) => column);

  GeneratedColumn<String> get promptId =>
      $composableBuilder(column: $table.promptId, builder: (column) => column);

  GeneratedColumn<int> get intensity =>
      $composableBuilder(column: $table.intensity, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get skipped =>
      $composableBuilder(column: $table.skipped, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$BarakahEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BarakahEntriesTable,
          BarakahEntry,
          $$BarakahEntriesTableFilterComposer,
          $$BarakahEntriesTableOrderingComposer,
          $$BarakahEntriesTableAnnotationComposer,
          $$BarakahEntriesTableCreateCompanionBuilder,
          $$BarakahEntriesTableUpdateCompanionBuilder,
          (
            BarakahEntry,
            BaseReferences<_$AppDatabase, $BarakahEntriesTable, BarakahEntry>,
          ),
          BarakahEntry,
          PrefetchHooks Function()
        > {
  $$BarakahEntriesTableTableManager(
    _$AppDatabase db,
    $BarakahEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BarakahEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BarakahEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BarakahEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> sourceIds = const Value.absent(),
                Value<String?> promptId = const Value.absent(),
                Value<int?> intensity = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> skipped = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => BarakahEntriesCompanion(
                id: id,
                date: date,
                sourceIds: sourceIds,
                promptId: promptId,
                intensity: intensity,
                note: note,
                skipped: skipped,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required String sourceIds,
                Value<String?> promptId = const Value.absent(),
                Value<int?> intensity = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> skipped = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => BarakahEntriesCompanion.insert(
                id: id,
                date: date,
                sourceIds: sourceIds,
                promptId: promptId,
                intensity: intensity,
                note: note,
                skipped: skipped,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BarakahEntriesTable, BarakahEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BarakahEntriesTable,
                    BarakahEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BarakahEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BarakahEntriesTable,
      BarakahEntry,
      $$BarakahEntriesTableFilterComposer,
      $$BarakahEntriesTableOrderingComposer,
      $$BarakahEntriesTableAnnotationComposer,
      $$BarakahEntriesTableCreateCompanionBuilder,
      $$BarakahEntriesTableUpdateCompanionBuilder,
      (
        BarakahEntry,
        BaseReferences<_$AppDatabase, $BarakahEntriesTable, BarakahEntry>,
      ),
      BarakahEntry,
      PrefetchHooks Function()
    >;
typedef $$BarakahPromptsTableCreateCompanionBuilder =
    BarakahPromptsCompanion Function({
      Value<int> id,
      required String sourceIds,
      required String question,
      Value<int> active,
      required int displayOrder,
    });
typedef $$BarakahPromptsTableUpdateCompanionBuilder =
    BarakahPromptsCompanion Function({
      Value<int> id,
      Value<String> sourceIds,
      Value<String> question,
      Value<int> active,
      Value<int> displayOrder,
    });

class $$BarakahPromptsTableFilterComposer
    extends Composer<_$AppDatabase, $BarakahPromptsTable> {
  $$BarakahPromptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceIds => $composableBuilder(
    column: $table.sourceIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BarakahPromptsTableOrderingComposer
    extends Composer<_$AppDatabase, $BarakahPromptsTable> {
  $$BarakahPromptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceIds => $composableBuilder(
    column: $table.sourceIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get question => $composableBuilder(
    column: $table.question,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BarakahPromptsTableAnnotationComposer
    extends Composer<_$AppDatabase, $BarakahPromptsTable> {
  $$BarakahPromptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get sourceIds =>
      $composableBuilder(column: $table.sourceIds, builder: (column) => column);

  GeneratedColumn<String> get question =>
      $composableBuilder(column: $table.question, builder: (column) => column);

  GeneratedColumn<int> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<int> get displayOrder => $composableBuilder(
    column: $table.displayOrder,
    builder: (column) => column,
  );
}

class $$BarakahPromptsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BarakahPromptsTable,
          BarakahPrompt,
          $$BarakahPromptsTableFilterComposer,
          $$BarakahPromptsTableOrderingComposer,
          $$BarakahPromptsTableAnnotationComposer,
          $$BarakahPromptsTableCreateCompanionBuilder,
          $$BarakahPromptsTableUpdateCompanionBuilder,
          (
            BarakahPrompt,
            BaseReferences<_$AppDatabase, $BarakahPromptsTable, BarakahPrompt>,
          ),
          BarakahPrompt,
          PrefetchHooks Function()
        > {
  $$BarakahPromptsTableTableManager(
    _$AppDatabase db,
    $BarakahPromptsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BarakahPromptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$BarakahPromptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$BarakahPromptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> sourceIds = const Value.absent(),
                Value<String> question = const Value.absent(),
                Value<int> active = const Value.absent(),
                Value<int> displayOrder = const Value.absent(),
              }) => BarakahPromptsCompanion(
                id: id,
                sourceIds: sourceIds,
                question: question,
                active: active,
                displayOrder: displayOrder,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String sourceIds,
                required String question,
                Value<int> active = const Value.absent(),
                required int displayOrder,
              }) => BarakahPromptsCompanion.insert(
                id: id,
                sourceIds: sourceIds,
                question: question,
                active: active,
                displayOrder: displayOrder,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$BarakahPromptsTable, BarakahPrompt>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BarakahPromptsTable,
                    BarakahPrompt
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BarakahPromptsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BarakahPromptsTable,
      BarakahPrompt,
      $$BarakahPromptsTableFilterComposer,
      $$BarakahPromptsTableOrderingComposer,
      $$BarakahPromptsTableAnnotationComposer,
      $$BarakahPromptsTableCreateCompanionBuilder,
      $$BarakahPromptsTableUpdateCompanionBuilder,
      (
        BarakahPrompt,
        BaseReferences<_$AppDatabase, $BarakahPromptsTable, BarakahPrompt>,
      ),
      BarakahPrompt,
      PrefetchHooks Function()
    >;
typedef $$HabitsTableCreateCompanionBuilder = HabitsCompanion Function({
  Value<int> id,
  required String name,
  required String category,
  Value<String> frequency,
  Value<String?> targetDays,
  Value<int> reminderEnabled,
  Value<int?> reminderTime,
  Value<int> active,
  Value<int> createdAt,
});
typedef $$HabitsTableUpdateCompanionBuilder = HabitsCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<String> category,
  Value<String> frequency,
  Value<String?> targetDays,
  Value<int> reminderEnabled,
  Value<int?> reminderTime,
  Value<int> active,
  Value<int> createdAt,
});

class $$HabitsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetDays => $composableBuilder(
    column: $table.targetDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get frequency => $composableBuilder(
    column: $table.frequency,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetDays => $composableBuilder(
    column: $table.targetDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitsTable> {
  $$HabitsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get frequency =>
      $composableBuilder(column: $table.frequency, builder: (column) => column);

  GeneratedColumn<String> get targetDays => $composableBuilder(
    column: $table.targetDays,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderEnabled => $composableBuilder(
    column: $table.reminderEnabled,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reminderTime => $composableBuilder(
    column: $table.reminderTime,
    builder: (column) => column,
  );

  GeneratedColumn<int> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$HabitsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitsTable,
          Habit,
          $$HabitsTableFilterComposer,
          $$HabitsTableOrderingComposer,
          $$HabitsTableAnnotationComposer,
          $$HabitsTableCreateCompanionBuilder,
          $$HabitsTableUpdateCompanionBuilder,
          (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
          Habit,
          PrefetchHooks Function()
        > {
  $$HabitsTableTableManager(_$AppDatabase db, $HabitsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> category = const Value.absent(),
                Value<String> frequency = const Value.absent(),
                Value<String?> targetDays = const Value.absent(),
                Value<int> reminderEnabled = const Value.absent(),
                Value<int?> reminderTime = const Value.absent(),
                Value<int> active = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => HabitsCompanion(
                id: id,
                name: name,
                category: category,
                frequency: frequency,
                targetDays: targetDays,
                reminderEnabled: reminderEnabled,
                reminderTime: reminderTime,
                active: active,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required String category,
                Value<String> frequency = const Value.absent(),
                Value<String?> targetDays = const Value.absent(),
                Value<int> reminderEnabled = const Value.absent(),
                Value<int?> reminderTime = const Value.absent(),
                Value<int> active = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => HabitsCompanion.insert(
                id: id,
                name: name,
                category: category,
                frequency: frequency,
                targetDays: targetDays,
                reminderEnabled: reminderEnabled,
                reminderTime: reminderTime,
                active: active,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitsTable, Habit>(table),
                  BaseReferences<_$AppDatabase, $HabitsTable, Habit>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitsTable,
      Habit,
      $$HabitsTableFilterComposer,
      $$HabitsTableOrderingComposer,
      $$HabitsTableAnnotationComposer,
      $$HabitsTableCreateCompanionBuilder,
      $$HabitsTableUpdateCompanionBuilder,
      (Habit, BaseReferences<_$AppDatabase, $HabitsTable, Habit>),
      Habit,
      PrefetchHooks Function()
    >;
typedef $$HabitCompletionsTableCreateCompanionBuilder =
    HabitCompletionsCompanion Function({
      Value<int> id,
      required int habitId,
      required String date,
      Value<int> completed,
    });
typedef $$HabitCompletionsTableUpdateCompanionBuilder =
    HabitCompletionsCompanion Function({
      Value<int> id,
      Value<int> habitId,
      Value<String> date,
      Value<int> completed,
    });

class $$HabitCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$HabitCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get habitId => $composableBuilder(
    column: $table.habitId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$HabitCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $HabitCompletionsTable> {
  $$HabitCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get habitId =>
      $composableBuilder(column: $table.habitId, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);
}

class $$HabitCompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $HabitCompletionsTable,
          HabitCompletion,
          $$HabitCompletionsTableFilterComposer,
          $$HabitCompletionsTableOrderingComposer,
          $$HabitCompletionsTableAnnotationComposer,
          $$HabitCompletionsTableCreateCompanionBuilder,
          $$HabitCompletionsTableUpdateCompanionBuilder,
          (
            HabitCompletion,
            BaseReferences<
              _$AppDatabase,
              $HabitCompletionsTable,
              HabitCompletion
            >,
          ),
          HabitCompletion,
          PrefetchHooks Function()
        > {
  $$HabitCompletionsTableTableManager(
    _$AppDatabase db,
    $HabitCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$HabitCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$HabitCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$HabitCompletionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> habitId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> completed = const Value.absent(),
              }) => HabitCompletionsCompanion(
                id: id,
                habitId: habitId,
                date: date,
                completed: completed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int habitId,
                required String date,
                Value<int> completed = const Value.absent(),
              }) => HabitCompletionsCompanion.insert(
                id: id,
                habitId: habitId,
                date: date,
                completed: completed,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$HabitCompletionsTable, HabitCompletion>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $HabitCompletionsTable,
                    HabitCompletion
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$HabitCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $HabitCompletionsTable,
      HabitCompletion,
      $$HabitCompletionsTableFilterComposer,
      $$HabitCompletionsTableOrderingComposer,
      $$HabitCompletionsTableAnnotationComposer,
      $$HabitCompletionsTableCreateCompanionBuilder,
      $$HabitCompletionsTableUpdateCompanionBuilder,
      (
        HabitCompletion,
        BaseReferences<_$AppDatabase, $HabitCompletionsTable, HabitCompletion>,
      ),
      HabitCompletion,
      PrefetchHooks Function()
    >;
typedef $$TasksTableCreateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  required String title,
  required String lifeArea,
  Value<int?> startMinutes,
  Value<int?> endMinutes,
  required String date,
  Value<int> repeatDaily,
  Value<int> repeatWeekly,
  Value<String?> repeatDays,
  Value<String?> notes,
  Value<int> completed,
  Value<int?> completedAt,
  Value<int> createdAt,
  Value<int> active,
});
typedef $$TasksTableUpdateCompanionBuilder = TasksCompanion Function({
  Value<int> id,
  Value<String> title,
  Value<String> lifeArea,
  Value<int?> startMinutes,
  Value<int?> endMinutes,
  Value<String> date,
  Value<int> repeatDaily,
  Value<int> repeatWeekly,
  Value<String?> repeatDays,
  Value<String?> notes,
  Value<int> completed,
  Value<int?> completedAt,
  Value<int> createdAt,
  Value<int> active,
});

class $$TasksTableFilterComposer extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lifeArea => $composableBuilder(
    column: $table.lifeArea,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatDaily => $composableBuilder(
    column: $table.repeatDaily,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get repeatWeekly => $composableBuilder(
    column: $table.repeatWeekly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TasksTableOrderingComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lifeArea => $composableBuilder(
    column: $table.lifeArea,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatDaily => $composableBuilder(
    column: $table.repeatDaily,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get repeatWeekly => $composableBuilder(
    column: $table.repeatWeekly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get active => $composableBuilder(
    column: $table.active,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TasksTableAnnotationComposer
    extends Composer<_$AppDatabase, $TasksTable> {
  $$TasksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get lifeArea =>
      $composableBuilder(column: $table.lifeArea, builder: (column) => column);

  GeneratedColumn<int> get startMinutes => $composableBuilder(
    column: $table.startMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<int> get endMinutes => $composableBuilder(
    column: $table.endMinutes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get repeatDaily => $composableBuilder(
    column: $table.repeatDaily,
    builder: (column) => column,
  );

  GeneratedColumn<int> get repeatWeekly => $composableBuilder(
    column: $table.repeatWeekly,
    builder: (column) => column,
  );

  GeneratedColumn<String> get repeatDays => $composableBuilder(
    column: $table.repeatDays,
    builder: (column) => column,
  );

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<int> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get active =>
      $composableBuilder(column: $table.active, builder: (column) => column);
}

class $$TasksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TasksTable,
          Task,
          $$TasksTableFilterComposer,
          $$TasksTableOrderingComposer,
          $$TasksTableAnnotationComposer,
          $$TasksTableCreateCompanionBuilder,
          $$TasksTableUpdateCompanionBuilder,
          (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
          Task,
          PrefetchHooks Function()
        > {
  $$TasksTableTableManager(_$AppDatabase db, $TasksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TasksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TasksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TasksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> lifeArea = const Value.absent(),
                Value<int?> startMinutes = const Value.absent(),
                Value<int?> endMinutes = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> repeatDaily = const Value.absent(),
                Value<int> repeatWeekly = const Value.absent(),
                Value<String?> repeatDays = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> completed = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> active = const Value.absent(),
              }) => TasksCompanion(
                id: id,
                title: title,
                lifeArea: lifeArea,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                date: date,
                repeatDaily: repeatDaily,
                repeatWeekly: repeatWeekly,
                repeatDays: repeatDays,
                notes: notes,
                completed: completed,
                completedAt: completedAt,
                createdAt: createdAt,
                active: active,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                required String lifeArea,
                Value<int?> startMinutes = const Value.absent(),
                Value<int?> endMinutes = const Value.absent(),
                required String date,
                Value<int> repeatDaily = const Value.absent(),
                Value<int> repeatWeekly = const Value.absent(),
                Value<String?> repeatDays = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> completed = const Value.absent(),
                Value<int?> completedAt = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> active = const Value.absent(),
              }) => TasksCompanion.insert(
                id: id,
                title: title,
                lifeArea: lifeArea,
                startMinutes: startMinutes,
                endMinutes: endMinutes,
                date: date,
                repeatDaily: repeatDaily,
                repeatWeekly: repeatWeekly,
                repeatDays: repeatDays,
                notes: notes,
                completed: completed,
                completedAt: completedAt,
                createdAt: createdAt,
                active: active,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$TasksTable, Task>(table),
                  BaseReferences<_$AppDatabase, $TasksTable, Task>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TasksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TasksTable,
      Task,
      $$TasksTableFilterComposer,
      $$TasksTableOrderingComposer,
      $$TasksTableAnnotationComposer,
      $$TasksTableCreateCompanionBuilder,
      $$TasksTableUpdateCompanionBuilder,
      (Task, BaseReferences<_$AppDatabase, $TasksTable, Task>),
      Task,
      PrefetchHooks Function()
    >;
typedef $$IntentionEntriesTableCreateCompanionBuilder =
    IntentionEntriesCompanion Function({
      Value<int> id,
      required String date,
      required String title,
      Value<String?> statement,
      Value<String?> category,
      Value<int> completed,
      Value<String?> reflection,
      Value<int> createdAt,
    });
typedef $$IntentionEntriesTableUpdateCompanionBuilder =
    IntentionEntriesCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String> title,
      Value<String?> statement,
      Value<String?> category,
      Value<int> completed,
      Value<String?> reflection,
      Value<int> createdAt,
    });

class $$IntentionEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $IntentionEntriesTable> {
  $$IntentionEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get statement => $composableBuilder(
    column: $table.statement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$IntentionEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $IntentionEntriesTable> {
  $$IntentionEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get statement => $composableBuilder(
    column: $table.statement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get category => $composableBuilder(
    column: $table.category,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$IntentionEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $IntentionEntriesTable> {
  $$IntentionEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get statement =>
      $composableBuilder(column: $table.statement, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<int> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<String> get reflection => $composableBuilder(
    column: $table.reflection,
    builder: (column) => column,
  );

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$IntentionEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $IntentionEntriesTable,
          IntentionEntry,
          $$IntentionEntriesTableFilterComposer,
          $$IntentionEntriesTableOrderingComposer,
          $$IntentionEntriesTableAnnotationComposer,
          $$IntentionEntriesTableCreateCompanionBuilder,
          $$IntentionEntriesTableUpdateCompanionBuilder,
          (
            IntentionEntry,
            BaseReferences<
              _$AppDatabase,
              $IntentionEntriesTable,
              IntentionEntry
            >,
          ),
          IntentionEntry,
          PrefetchHooks Function()
        > {
  $$IntentionEntriesTableTableManager(
    _$AppDatabase db,
    $IntentionEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$IntentionEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$IntentionEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$IntentionEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> statement = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> completed = const Value.absent(),
                Value<String?> reflection = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => IntentionEntriesCompanion(
                id: id,
                date: date,
                title: title,
                statement: statement,
                category: category,
                completed: completed,
                reflection: reflection,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                required String title,
                Value<String?> statement = const Value.absent(),
                Value<String?> category = const Value.absent(),
                Value<int> completed = const Value.absent(),
                Value<String?> reflection = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
              }) => IntentionEntriesCompanion.insert(
                id: id,
                date: date,
                title: title,
                statement: statement,
                category: category,
                completed: completed,
                reflection: reflection,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$IntentionEntriesTable, IntentionEntry>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $IntentionEntriesTable,
                    IntentionEntry
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$IntentionEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $IntentionEntriesTable,
      IntentionEntry,
      $$IntentionEntriesTableFilterComposer,
      $$IntentionEntriesTableOrderingComposer,
      $$IntentionEntriesTableAnnotationComposer,
      $$IntentionEntriesTableCreateCompanionBuilder,
      $$IntentionEntriesTableUpdateCompanionBuilder,
      (
        IntentionEntry,
        BaseReferences<_$AppDatabase, $IntentionEntriesTable, IntentionEntry>,
      ),
      IntentionEntry,
      PrefetchHooks Function()
    >;
typedef $$BarakahDailyResponsesTableCreateCompanionBuilder =
    BarakahDailyResponsesCompanion Function({
      required String date,
      required String promptId,
      required String answer,
      required String sourceIds,
      Value<String?> note,
      Value<int> createdAt,
      required int updatedAt,
      Value<int> rowid,
    });
typedef $$BarakahDailyResponsesTableUpdateCompanionBuilder =
    BarakahDailyResponsesCompanion Function({
      Value<String> date,
      Value<String> promptId,
      Value<String> answer,
      Value<String> sourceIds,
      Value<String?> note,
      Value<int> createdAt,
      Value<int> updatedAt,
      Value<int> rowid,
    });

class $$BarakahDailyResponsesTableFilterComposer
    extends Composer<_$AppDatabase, $BarakahDailyResponsesTable> {
  $$BarakahDailyResponsesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promptId => $composableBuilder(
    column: $table.promptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get sourceIds => $composableBuilder(
    column: $table.sourceIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$BarakahDailyResponsesTableOrderingComposer
    extends Composer<_$AppDatabase, $BarakahDailyResponsesTable> {
  $$BarakahDailyResponsesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promptId => $composableBuilder(
    column: $table.promptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answer => $composableBuilder(
    column: $table.answer,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get sourceIds => $composableBuilder(
    column: $table.sourceIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get note => $composableBuilder(
    column: $table.note,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$BarakahDailyResponsesTableAnnotationComposer
    extends Composer<_$AppDatabase, $BarakahDailyResponsesTable> {
  $$BarakahDailyResponsesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get promptId =>
      $composableBuilder(column: $table.promptId, builder: (column) => column);

  GeneratedColumn<String> get answer =>
      $composableBuilder(column: $table.answer, builder: (column) => column);

  GeneratedColumn<String> get sourceIds =>
      $composableBuilder(column: $table.sourceIds, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$BarakahDailyResponsesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $BarakahDailyResponsesTable,
          BarakahDailyResponseRow,
          $$BarakahDailyResponsesTableFilterComposer,
          $$BarakahDailyResponsesTableOrderingComposer,
          $$BarakahDailyResponsesTableAnnotationComposer,
          $$BarakahDailyResponsesTableCreateCompanionBuilder,
          $$BarakahDailyResponsesTableUpdateCompanionBuilder,
          (
            BarakahDailyResponseRow,
            BaseReferences<
              _$AppDatabase,
              $BarakahDailyResponsesTable,
              BarakahDailyResponseRow
            >,
          ),
          BarakahDailyResponseRow,
          PrefetchHooks Function()
        > {
  $$BarakahDailyResponsesTableTableManager(
    _$AppDatabase db,
    $BarakahDailyResponsesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$BarakahDailyResponsesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$BarakahDailyResponsesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$BarakahDailyResponsesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> date = const Value.absent(),
                Value<String> promptId = const Value.absent(),
                Value<String> answer = const Value.absent(),
                Value<String> sourceIds = const Value.absent(),
                Value<String?> note = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => BarakahDailyResponsesCompanion(
                date: date,
                promptId: promptId,
                answer: answer,
                sourceIds: sourceIds,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String date,
                required String promptId,
                required String answer,
                required String sourceIds,
                Value<String?> note = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                required int updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => BarakahDailyResponsesCompanion.insert(
                date: date,
                promptId: promptId,
                answer: answer,
                sourceIds: sourceIds,
                note: note,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $BarakahDailyResponsesTable,
                    BarakahDailyResponseRow
                  >(table),
                  BaseReferences<
                    _$AppDatabase,
                    $BarakahDailyResponsesTable,
                    BarakahDailyResponseRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$BarakahDailyResponsesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $BarakahDailyResponsesTable,
      BarakahDailyResponseRow,
      $$BarakahDailyResponsesTableFilterComposer,
      $$BarakahDailyResponsesTableOrderingComposer,
      $$BarakahDailyResponsesTableAnnotationComposer,
      $$BarakahDailyResponsesTableCreateCompanionBuilder,
      $$BarakahDailyResponsesTableUpdateCompanionBuilder,
      (
        BarakahDailyResponseRow,
        BaseReferences<
          _$AppDatabase,
          $BarakahDailyResponsesTable,
          BarakahDailyResponseRow
        >,
      ),
      BarakahDailyResponseRow,
      PrefetchHooks Function()
    >;
typedef $$MuhasabahEntriesTableCreateCompanionBuilder =
    MuhasabahEntriesCompanion Function({
      Value<int> id,
      required String date,
      Value<String?> promptId,
      Value<String?> promptText,
      required String content,
      Value<String?> tags,
      Value<int> createdAt,
      Value<int> updatedAt,
    });
typedef $$MuhasabahEntriesTableUpdateCompanionBuilder =
    MuhasabahEntriesCompanion Function({
      Value<int> id,
      Value<String> date,
      Value<String?> promptId,
      Value<String?> promptText,
      Value<String> content,
      Value<String?> tags,
      Value<int> createdAt,
      Value<int> updatedAt,
    });

class $$MuhasabahEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MuhasabahEntriesTable> {
  $$MuhasabahEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promptId => $composableBuilder(
    column: $table.promptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get promptText => $composableBuilder(
    column: $table.promptText,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MuhasabahEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MuhasabahEntriesTable> {
  $$MuhasabahEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promptId => $composableBuilder(
    column: $table.promptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get promptText => $composableBuilder(
    column: $table.promptText,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get content => $composableBuilder(
    column: $table.content,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get tags => $composableBuilder(
    column: $table.tags,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MuhasabahEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MuhasabahEntriesTable> {
  $$MuhasabahEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get promptId =>
      $composableBuilder(column: $table.promptId, builder: (column) => column);

  GeneratedColumn<String> get promptText => $composableBuilder(
    column: $table.promptText,
    builder: (column) => column,
  );

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get tags =>
      $composableBuilder(column: $table.tags, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MuhasabahEntriesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MuhasabahEntriesTable,
          MuhasabahEntryRow,
          $$MuhasabahEntriesTableFilterComposer,
          $$MuhasabahEntriesTableOrderingComposer,
          $$MuhasabahEntriesTableAnnotationComposer,
          $$MuhasabahEntriesTableCreateCompanionBuilder,
          $$MuhasabahEntriesTableUpdateCompanionBuilder,
          (
            MuhasabahEntryRow,
            BaseReferences<
              _$AppDatabase,
              $MuhasabahEntriesTable,
              MuhasabahEntryRow
            >,
          ),
          MuhasabahEntryRow,
          PrefetchHooks Function()
        > {
  $$MuhasabahEntriesTableTableManager(
    _$AppDatabase db,
    $MuhasabahEntriesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MuhasabahEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MuhasabahEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MuhasabahEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<String?> promptId = const Value.absent(),
                Value<String?> promptText = const Value.absent(),
                Value<String> content = const Value.absent(),
                Value<String?> tags = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => MuhasabahEntriesCompanion(
                id: id,
                date: date,
                promptId: promptId,
                promptText: promptText,
                content: content,
                tags: tags,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String date,
                Value<String?> promptId = const Value.absent(),
                Value<String?> promptText = const Value.absent(),
                required String content,
                Value<String?> tags = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> updatedAt = const Value.absent(),
              }) => MuhasabahEntriesCompanion.insert(
                id: id,
                date: date,
                promptId: promptId,
                promptText: promptText,
                content: content,
                tags: tags,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MuhasabahEntriesTable, MuhasabahEntryRow>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MuhasabahEntriesTable,
                    MuhasabahEntryRow
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MuhasabahEntriesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MuhasabahEntriesTable,
      MuhasabahEntryRow,
      $$MuhasabahEntriesTableFilterComposer,
      $$MuhasabahEntriesTableOrderingComposer,
      $$MuhasabahEntriesTableAnnotationComposer,
      $$MuhasabahEntriesTableCreateCompanionBuilder,
      $$MuhasabahEntriesTableUpdateCompanionBuilder,
      (
        MuhasabahEntryRow,
        BaseReferences<
          _$AppDatabase,
          $MuhasabahEntriesTable,
          MuhasabahEntryRow
        >,
      ),
      MuhasabahEntryRow,
      PrefetchHooks Function()
    >;
typedef $$AdhkarBookmarksTableCreateCompanionBuilder =
    AdhkarBookmarksCompanion Function({
      required String dhikrId,
      required int createdAt,
      Value<int> rowid,
    });
typedef $$AdhkarBookmarksTableUpdateCompanionBuilder =
    AdhkarBookmarksCompanion Function({
      Value<String> dhikrId,
      Value<int> createdAt,
      Value<int> rowid,
    });

class $$AdhkarBookmarksTableFilterComposer
    extends Composer<_$AppDatabase, $AdhkarBookmarksTable> {
  $$AdhkarBookmarksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get dhikrId => $composableBuilder(
    column: $table.dhikrId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AdhkarBookmarksTableOrderingComposer
    extends Composer<_$AppDatabase, $AdhkarBookmarksTable> {
  $$AdhkarBookmarksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get dhikrId => $composableBuilder(
    column: $table.dhikrId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdhkarBookmarksTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdhkarBookmarksTable> {
  $$AdhkarBookmarksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get dhikrId =>
      $composableBuilder(column: $table.dhikrId, builder: (column) => column);

  GeneratedColumn<int> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$AdhkarBookmarksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdhkarBookmarksTable,
          AdhkarBookmark,
          $$AdhkarBookmarksTableFilterComposer,
          $$AdhkarBookmarksTableOrderingComposer,
          $$AdhkarBookmarksTableAnnotationComposer,
          $$AdhkarBookmarksTableCreateCompanionBuilder,
          $$AdhkarBookmarksTableUpdateCompanionBuilder,
          (
            AdhkarBookmark,
            BaseReferences<
              _$AppDatabase,
              $AdhkarBookmarksTable,
              AdhkarBookmark
            >,
          ),
          AdhkarBookmark,
          PrefetchHooks Function()
        > {
  $$AdhkarBookmarksTableTableManager(
    _$AppDatabase db,
    $AdhkarBookmarksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdhkarBookmarksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdhkarBookmarksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdhkarBookmarksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> dhikrId = const Value.absent(),
                Value<int> createdAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdhkarBookmarksCompanion(
                dhikrId: dhikrId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String dhikrId,
                required int createdAt,
                Value<int> rowid = const Value.absent(),
              }) => AdhkarBookmarksCompanion.insert(
                dhikrId: dhikrId,
                createdAt: createdAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AdhkarBookmarksTable, AdhkarBookmark>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AdhkarBookmarksTable,
                    AdhkarBookmark
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AdhkarBookmarksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdhkarBookmarksTable,
      AdhkarBookmark,
      $$AdhkarBookmarksTableFilterComposer,
      $$AdhkarBookmarksTableOrderingComposer,
      $$AdhkarBookmarksTableAnnotationComposer,
      $$AdhkarBookmarksTableCreateCompanionBuilder,
      $$AdhkarBookmarksTableUpdateCompanionBuilder,
      (
        AdhkarBookmark,
        BaseReferences<_$AppDatabase, $AdhkarBookmarksTable, AdhkarBookmark>,
      ),
      AdhkarBookmark,
      PrefetchHooks Function()
    >;
typedef $$AdhkarSessionsTableCreateCompanionBuilder =
    AdhkarSessionsCompanion Function({
      required String collectionId,
      Value<int> lastPageIndex,
      Value<String> countsJson,
      required int lastAccessedAt,
      Value<bool> isCompleted,
      Value<int> rowid,
    });
typedef $$AdhkarSessionsTableUpdateCompanionBuilder =
    AdhkarSessionsCompanion Function({
      Value<String> collectionId,
      Value<int> lastPageIndex,
      Value<String> countsJson,
      Value<int> lastAccessedAt,
      Value<bool> isCompleted,
      Value<int> rowid,
    });

class $$AdhkarSessionsTableFilterComposer
    extends Composer<_$AppDatabase, $AdhkarSessionsTable> {
  $$AdhkarSessionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastPageIndex => $composableBuilder(
    column: $table.lastPageIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get countsJson => $composableBuilder(
    column: $table.countsJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AdhkarSessionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AdhkarSessionsTable> {
  $$AdhkarSessionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastPageIndex => $composableBuilder(
    column: $table.lastPageIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get countsJson => $composableBuilder(
    column: $table.countsJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdhkarSessionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdhkarSessionsTable> {
  $$AdhkarSessionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastPageIndex => $composableBuilder(
    column: $table.lastPageIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get countsJson => $composableBuilder(
    column: $table.countsJson,
    builder: (column) => column,
  );

  GeneratedColumn<int> get lastAccessedAt => $composableBuilder(
    column: $table.lastAccessedAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCompleted => $composableBuilder(
    column: $table.isCompleted,
    builder: (column) => column,
  );
}

class $$AdhkarSessionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdhkarSessionsTable,
          AdhkarSession,
          $$AdhkarSessionsTableFilterComposer,
          $$AdhkarSessionsTableOrderingComposer,
          $$AdhkarSessionsTableAnnotationComposer,
          $$AdhkarSessionsTableCreateCompanionBuilder,
          $$AdhkarSessionsTableUpdateCompanionBuilder,
          (
            AdhkarSession,
            BaseReferences<_$AppDatabase, $AdhkarSessionsTable, AdhkarSession>,
          ),
          AdhkarSession,
          PrefetchHooks Function()
        > {
  $$AdhkarSessionsTableTableManager(
    _$AppDatabase db,
    $AdhkarSessionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdhkarSessionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdhkarSessionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdhkarSessionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> collectionId = const Value.absent(),
                Value<int> lastPageIndex = const Value.absent(),
                Value<String> countsJson = const Value.absent(),
                Value<int> lastAccessedAt = const Value.absent(),
                Value<bool> isCompleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdhkarSessionsCompanion(
                collectionId: collectionId,
                lastPageIndex: lastPageIndex,
                countsJson: countsJson,
                lastAccessedAt: lastAccessedAt,
                isCompleted: isCompleted,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String collectionId,
                Value<int> lastPageIndex = const Value.absent(),
                Value<String> countsJson = const Value.absent(),
                required int lastAccessedAt,
                Value<bool> isCompleted = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AdhkarSessionsCompanion.insert(
                collectionId: collectionId,
                lastPageIndex: lastPageIndex,
                countsJson: countsJson,
                lastAccessedAt: lastAccessedAt,
                isCompleted: isCompleted,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AdhkarSessionsTable, AdhkarSession>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AdhkarSessionsTable,
                    AdhkarSession
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AdhkarSessionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdhkarSessionsTable,
      AdhkarSession,
      $$AdhkarSessionsTableFilterComposer,
      $$AdhkarSessionsTableOrderingComposer,
      $$AdhkarSessionsTableAnnotationComposer,
      $$AdhkarSessionsTableCreateCompanionBuilder,
      $$AdhkarSessionsTableUpdateCompanionBuilder,
      (
        AdhkarSession,
        BaseReferences<_$AppDatabase, $AdhkarSessionsTable, AdhkarSession>,
      ),
      AdhkarSession,
      PrefetchHooks Function()
    >;
typedef $$AdhkarCompletionsTableCreateCompanionBuilder =
    AdhkarCompletionsCompanion Function({
      Value<int> id,
      required String collectionId,
      required String date,
      required int completedAt,
    });
typedef $$AdhkarCompletionsTableUpdateCompanionBuilder =
    AdhkarCompletionsCompanion Function({
      Value<int> id,
      Value<String> collectionId,
      Value<String> date,
      Value<int> completedAt,
    });

class $$AdhkarCompletionsTableFilterComposer
    extends Composer<_$AppDatabase, $AdhkarCompletionsTable> {
  $$AdhkarCompletionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AdhkarCompletionsTableOrderingComposer
    extends Composer<_$AppDatabase, $AdhkarCompletionsTable> {
  $$AdhkarCompletionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AdhkarCompletionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AdhkarCompletionsTable> {
  $$AdhkarCompletionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get collectionId => $composableBuilder(
    column: $table.collectionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<int> get completedAt => $composableBuilder(
    column: $table.completedAt,
    builder: (column) => column,
  );
}

class $$AdhkarCompletionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AdhkarCompletionsTable,
          AdhkarCompletion,
          $$AdhkarCompletionsTableFilterComposer,
          $$AdhkarCompletionsTableOrderingComposer,
          $$AdhkarCompletionsTableAnnotationComposer,
          $$AdhkarCompletionsTableCreateCompanionBuilder,
          $$AdhkarCompletionsTableUpdateCompanionBuilder,
          (
            AdhkarCompletion,
            BaseReferences<
              _$AppDatabase,
              $AdhkarCompletionsTable,
              AdhkarCompletion
            >,
          ),
          AdhkarCompletion,
          PrefetchHooks Function()
        > {
  $$AdhkarCompletionsTableTableManager(
    _$AppDatabase db,
    $AdhkarCompletionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AdhkarCompletionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AdhkarCompletionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AdhkarCompletionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> collectionId = const Value.absent(),
                Value<String> date = const Value.absent(),
                Value<int> completedAt = const Value.absent(),
              }) => AdhkarCompletionsCompanion(
                id: id,
                collectionId: collectionId,
                date: date,
                completedAt: completedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String collectionId,
                required String date,
                required int completedAt,
              }) => AdhkarCompletionsCompanion.insert(
                id: id,
                collectionId: collectionId,
                date: date,
                completedAt: completedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AdhkarCompletionsTable, AdhkarCompletion>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $AdhkarCompletionsTable,
                    AdhkarCompletion
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AdhkarCompletionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AdhkarCompletionsTable,
      AdhkarCompletion,
      $$AdhkarCompletionsTableFilterComposer,
      $$AdhkarCompletionsTableOrderingComposer,
      $$AdhkarCompletionsTableAnnotationComposer,
      $$AdhkarCompletionsTableCreateCompanionBuilder,
      $$AdhkarCompletionsTableUpdateCompanionBuilder,
      (
        AdhkarCompletion,
        BaseReferences<
          _$AppDatabase,
          $AdhkarCompletionsTable,
          AdhkarCompletion
        >,
      ),
      AdhkarCompletion,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BarakahEntriesTableTableManager get barakahEntries =>
      $$BarakahEntriesTableTableManager(_db, _db.barakahEntries);
  $$BarakahPromptsTableTableManager get barakahPrompts =>
      $$BarakahPromptsTableTableManager(_db, _db.barakahPrompts);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$HabitCompletionsTableTableManager get habitCompletions =>
      $$HabitCompletionsTableTableManager(_db, _db.habitCompletions);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
  $$IntentionEntriesTableTableManager get intentionEntries =>
      $$IntentionEntriesTableTableManager(_db, _db.intentionEntries);
  $$BarakahDailyResponsesTableTableManager get barakahDailyResponses =>
      $$BarakahDailyResponsesTableTableManager(_db, _db.barakahDailyResponses);
  $$MuhasabahEntriesTableTableManager get muhasabahEntries =>
      $$MuhasabahEntriesTableTableManager(_db, _db.muhasabahEntries);
  $$AdhkarBookmarksTableTableManager get adhkarBookmarks =>
      $$AdhkarBookmarksTableTableManager(_db, _db.adhkarBookmarks);
  $$AdhkarSessionsTableTableManager get adhkarSessions =>
      $$AdhkarSessionsTableTableManager(_db, _db.adhkarSessions);
  $$AdhkarCompletionsTableTableManager get adhkarCompletions =>
      $$AdhkarCompletionsTableTableManager(_db, _db.adhkarCompletions);
}
