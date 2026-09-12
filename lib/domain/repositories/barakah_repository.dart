abstract class BarakahRepository {
  Stream<List<BarakahEntry>> watchEntriesForDate(String date);
  Future<List<BarakahEntry>> getEntriesForDate(String date);
  Future<List<BarakahEntry>> getEntriesForRange(String startDate, String endDate);
  Future<BarakahEntry?> getEntryById(int id);
  Future<int> insertEntry(BarakahEntry entry);
  Future<bool> updateEntry(BarakahEntry entry);
  Future<int> deleteEntry(int id);
}