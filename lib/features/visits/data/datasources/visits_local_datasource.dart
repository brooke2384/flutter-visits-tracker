import 'package:sqflite/sqflite.dart';
import 'package:uuid/uuid.dart';
import '../models/visit_model.dart';

abstract class VisitsLocalDataSource {
  Future<List<VisitModel>> getVisits({int limit = 20, int offset = 0});
  Future<VisitModel> createVisit(VisitModel visit);
  Future<VisitModel> updateVisit(VisitModel visit);
  Future<void> deleteVisit(int id);
  Future<List<VisitModel>> getUnsyncedVisits();
  Future<void> markAsSynced(String localId, int serverId);
  Future<List<VisitModel>> searchVisits(String query);
}

class VisitsLocalDataSourceImpl implements VisitsLocalDataSource {
  final Database database;
  final Uuid uuid = const Uuid();

  VisitsLocalDataSourceImpl(this.database);

  @override
  Future<List<VisitModel>> getVisits({int limit = 20, int offset = 0}) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'visits',
      orderBy: 'visit_date DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) {
      return VisitModel.fromLocalJson(maps[i]);
    });
  }

  @override
  Future<VisitModel> createVisit(VisitModel visit) async {
    final localId = uuid.v4();
    final visitWithLocalId = VisitModel.fromEntity(
      visit.copyWith(localId: localId, isSynced: false),
    );

    final id = await database.insert(
      'visits',
      visitWithLocalId.toLocalJson(),
    );

    return VisitModel.fromEntity(visitWithLocalId.copyWith(id: id));
  }

  @override
  Future<VisitModel> updateVisit(VisitModel visit) async {
    await database.update(
      'visits',
      visit.toLocalJson(),
      where: 'id = ?',
      whereArgs: [visit.id],
    );

    return visit;
  }

  @override
  Future<void> deleteVisit(int id) async {
    await database.delete(
      'visits',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<List<VisitModel>> getUnsyncedVisits() async {
    final List<Map<String, dynamic>> maps = await database.query(
      'visits',
      where: 'is_synced = ?',
      whereArgs: [0],
    );

    return List.generate(maps.length, (i) {
      return VisitModel.fromLocalJson(maps[i]);
    });
  }

  @override
  Future<void> markAsSynced(String localId, int serverId) async {
    await database.update(
      'visits',
      {'is_synced': 1, 'id': serverId},
      where: 'local_id = ?',
      whereArgs: [localId],
    );
  }

  @override
  Future<List<VisitModel>> searchVisits(String query) async {
    final List<Map<String, dynamic>> maps = await database.query(
      'visits',
      where: 'location LIKE ? OR notes LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'visit_date DESC',
    );

    return List.generate(maps.length, (i) {
      return VisitModel.fromLocalJson(maps[i]);
    });
  }
}
