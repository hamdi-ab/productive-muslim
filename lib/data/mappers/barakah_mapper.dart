import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/mappers/domain_mapper.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart'
    as barakah_model;

class BarakahMapper
    implements DomainMapper<barakah_model.BarakahEntry, BarakahEntry> {
  @override
  barakah_model.BarakahEntry toDomain(BarakahEntry row) {
    return barakah_model.BarakahEntry(
      id: row.id,
      date: row.date,
      sourceIds: row.sourceIds.split(',').where((s) => s.isNotEmpty).toList(),
      promptId: row.promptId,
      intensity: row.intensity,
      note: row.note,
      skipped: row.skipped == 1,
      createdAt: row.createdAt,
    );
  }

  @override
  BarakahEntry toRow(barakah_model.BarakahEntry entry) {
    return BarakahEntry(
      id: entry.id,
      date: entry.date,
      sourceIds: entry.sourceIds.join(','),
      promptId: entry.promptId,
      intensity: entry.intensity,
      note: entry.note,
      skipped: entry.skipped ? 1 : 0,
      createdAt: entry.createdAt,
    );
  }
}
