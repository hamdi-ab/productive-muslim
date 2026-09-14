import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/mappers/domain_mapper.dart';
import 'package:productive_muslim/domain/models/intention_entry.dart'
    as intention_model;

class IntentionMapper
    implements DomainMapper<intention_model.IntentionEntry, IntentionEntry> {
  @override
  intention_model.IntentionEntry toDomain(IntentionEntry row) {
    return intention_model.IntentionEntry(
      id: row.id,
      date: row.date,
      title: row.title,
      statement: row.statement,
      category: row.category,
      completed: row.completed == 1,
      reflection: row.reflection,
      createdAt: row.createdAt,
    );
  }

  @override
  IntentionEntry toRow(intention_model.IntentionEntry entry) {
    return IntentionEntry(
      id: entry.id,
      date: entry.date,
      title: entry.title,
      statement: entry.statement,
      category: entry.category,
      completed: entry.completed ? 1 : 0,
      reflection: entry.reflection,
      createdAt: entry.createdAt,
    );
  }
}
