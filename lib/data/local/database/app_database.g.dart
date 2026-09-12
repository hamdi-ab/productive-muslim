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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $BarakahEntriesTable barakahEntries = $BarakahEntriesTable(this);
  late final $BarakahPromptsTable barakahPrompts = $BarakahPromptsTable(this);
  late final $HabitsTable habits = $HabitsTable(this);
  late final $TasksTable tasks = $TasksTable(this);
  late final BarakahDao barakahDao = BarakahDao(this as AppDatabase);
  late final HabitDao habitDao = HabitDao(this as AppDatabase);
  late final TaskDao taskDao = TaskDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    barakahEntries,
    barakahPrompts,
    habits,
    tasks,
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$BarakahEntriesTableTableManager get barakahEntries =>
      $$BarakahEntriesTableTableManager(_db, _db.barakahEntries);
  $$BarakahPromptsTableTableManager get barakahPrompts =>
      $$BarakahPromptsTableTableManager(_db, _db.barakahPrompts);
  $$HabitsTableTableManager get habits =>
      $$HabitsTableTableManager(_db, _db.habits);
  $$TasksTableTableManager get tasks =>
      $$TasksTableTableManager(_db, _db.tasks);
}
