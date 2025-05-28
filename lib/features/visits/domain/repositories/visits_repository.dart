import '../entities/visit.dart';

abstract class VisitsRepository {
  Future<List<Visit>> getVisits({int limit = 20, int offset = 0});
  Future<Visit> createVisit(Visit visit);
  Future<Visit> updateVisit(Visit visit);
  Future<void> deleteVisit(int id);
  Future<void> syncVisits();
  Future<List<Visit>> searchVisits(String query);
  Future<Map<String, int>> getVisitStatistics();
}
