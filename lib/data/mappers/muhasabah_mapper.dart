import 'package:productive_muslim/data/local/database/app_database.dart';
import 'package:productive_muslim/data/mappers/domain_mapper.dart';
import 'package:productive_muslim/domain/models/muhasabah_entry.dart'
    as muhasabah_model;

class MuhasabahMapper
    implements DomainMapper<muhasabah_model.MuhasabahEntry, MuhasabahEntryRow> {
  @override
  muhasabah_model.MuhasabahEntry toDomain(MuhasabahEntryRow row) {
    return muhasabah_model.MuhasabahEntry(
      id: row.id,
      date: row.date,
      promptId: row.promptId,
      promptText: row.promptText,
      content: row.content,
      tags: row.tags,
      createdAt: row.createdAt,
      updatedAt: row.updatedAt,
    );
  }

  @override
  MuhasabahEntryRow toRow(muhasabah_model.MuhasabahEntry entry) {
    return MuhasabahEntryRow(
      id: entry.id,
      date: entry.date,
      promptId: entry.promptId,
      promptText: entry.promptText,
      content: entry.content,
      tags: entry.tags,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }
}
