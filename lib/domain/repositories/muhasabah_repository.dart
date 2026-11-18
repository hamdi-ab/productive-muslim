import 'package:productive_muslim/domain/models/muhasabah_entry.dart';

abstract class MuhasabahRepository {
  Stream<List<MuhasabahEntry>> watchEntriesForDate(String date);
  Future<List<MuhasabahEntry>> getEntriesForDate(String date);
  Future<List<MuhasabahEntry>> getEntriesForRange(
    String startDate,
    String endDate,
  );
  Future<MuhasabahEntry?> getEntryById(int id);
  Future<int> insertEntry(MuhasabahEntry entry);
  Future<bool> updateEntry(MuhasabahEntry entry);
  Future<int> deleteEntry(int id);
}
