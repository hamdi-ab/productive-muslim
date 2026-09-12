import 'package:productive_muslim/domain/models/intention_entry.dart';

abstract class IntentionRepository {
  Stream<List<IntentionEntry>> watchEntriesForDate(String date);
  Future<List<IntentionEntry>> getEntriesForDate(String date);
  Future<List<IntentionEntry>> getEntriesForRange(String startDate, String endDate);
  Future<IntentionEntry?> getEntryById(int id);
  Future<int> insertEntry(IntentionEntry entry);
  Future<bool> updateEntry(IntentionEntry entry);
  Future<int> deleteEntry(int id);
}