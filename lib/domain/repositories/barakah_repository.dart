import 'package:productive_muslim/domain/models/barakah_daily_response.dart';
import 'package:productive_muslim/domain/models/barakah_entry.dart';

abstract class BarakahRepository {
  Stream<BarakahDailyResponse?> watchDailyResponse(String date);
  Stream<List<BarakahDailyResponse>> watchDailyResponsesForRange(
    String startDate,
    String endDate,
  );
  Future<void> saveDailyResponse(BarakahDailyResponse response);
  Stream<List<BarakahEntry>> watchEntriesForDate(String date);
  Future<List<BarakahEntry>> getEntriesForDate(String date);
  Future<List<BarakahEntry>> getEntriesForRange(
    String startDate,
    String endDate,
  );
  Future<BarakahEntry?> getEntryById(int id);
  Future<int> insertEntry(BarakahEntry entry);
  Future<bool> updateEntry(BarakahEntry entry);
  Future<int> deleteEntry(int id);
}
