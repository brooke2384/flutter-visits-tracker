import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/visit.dart';
import '../../domain/repositories/visits_repository.dart';
import '../datasources/visits_local_datasource.dart';
import '../datasources/visits_remote_datasource.dart';
import '../models/visit_model.dart';
import 'package:flutter/foundation.dart';

class VisitsRepositoryImpl implements VisitsRepository {
  final VisitsRemoteDataSource remoteDataSource;
  final VisitsLocalDataSource? localDataSource;

  VisitsRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Visit>> getVisits({int limit = 20, int offset = 0}) async {
    if (kIsWeb || localDataSource == null) {
      // On web, only use remote
      return await remoteDataSource.getVisits();
    }
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        final remoteVisits = await remoteDataSource.getVisits();
        return remoteVisits;
      }
    } catch (e) {
      // Fall back to local data if remote fails
    }
    return await localDataSource!.getVisits(limit: limit, offset: offset);
  }

  @override
  Future<Visit> createVisit(Visit visit) async {
    if (kIsWeb || localDataSource == null) {
      // On web, only use remote
      final visitModel = VisitModel.fromEntity(visit);
      return await remoteDataSource.createVisit(visitModel);
    }
    final visitModel = VisitModel.fromEntity(visit);
    final localVisit = await localDataSource!.createVisit(visitModel);
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        final remoteVisit = await remoteDataSource.createVisit(localVisit);
        await localDataSource!.markAsSynced(
          localVisit.localId!,
          remoteVisit.id!,
        );
        return remoteVisit;
      }
    } catch (e) {
      // Visit will be synced later
    }
    return localVisit;
  }

  @override
  Future<Visit> updateVisit(Visit visit) async {
    if (kIsWeb || localDataSource == null) {
      final visitModel = VisitModel.fromEntity(visit);
      await remoteDataSource.updateVisit(visitModel);
      return visit;
    }
    final visitModel = VisitModel.fromEntity(visit);
    final updatedVisit = await localDataSource!.updateVisit(visitModel);
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none && visit.id != null) {
        await remoteDataSource.updateVisit(visitModel);
      }
    } catch (e) {
      // Update will be synced later
    }
    return updatedVisit;
  }

  @override
  Future<void> deleteVisit(int id) async {
    if (kIsWeb || localDataSource == null) {
      await remoteDataSource.deleteVisit(id);
      return;
    }
    await localDataSource!.deleteVisit(id);
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      if (connectivityResult != ConnectivityResult.none) {
        await remoteDataSource.deleteVisit(id);
      }
    } catch (e) {
      // Deletion will be synced later
    }
  }

  @override
  Future<void> syncVisits() async {
    if (kIsWeb || localDataSource == null) {
      // No local data to sync on web
      return;
    }
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      throw Exception('No internet connection');
    }
    final unsyncedVisits = await localDataSource!.getUnsyncedVisits();
    for (final visit in unsyncedVisits) {
      try {
        if (visit.id == null) {
          final remoteVisit = await remoteDataSource.createVisit(visit);
          await localDataSource!.markAsSynced(
            visit.localId!,
            remoteVisit.id!,
          );
        } else {
          await remoteDataSource.updateVisit(visit);
        }
      } catch (e) {
        continue;
      }
    }
  }

  @override
  Future<List<Visit>> searchVisits(String query) async {
    if (kIsWeb || localDataSource == null) {
      // On web, search remotely (or return all visits and filter)
      final visits = await remoteDataSource.getVisits();
      return visits.where((visit) =>
        visit.location.toLowerCase().contains(query.toLowerCase()) ||
        (visit.notes?.toLowerCase().contains(query.toLowerCase()) ?? false)
      ).toList();
    }
    return await localDataSource!.searchVisits(query);
  }

  @override
  Future<Map<String, int>> getVisitStatistics() async {
    if (kIsWeb || localDataSource == null) {
      final visits = await remoteDataSource.getVisits();
      final completed = visits.where((v) => v.status == 'Completed').length;
      final pending = visits.where((v) => v.status == 'Pending').length;
      final cancelled = visits.where((v) => v.status == 'Cancelled').length;
      return {
        'total': visits.length,
        'completed': completed,
        'pending': pending,
        'cancelled': cancelled,
      };
    }
    final visits = await localDataSource!.getVisits();
    final completed = visits.where((v) => v.status == 'Completed').length;
    final pending = visits.where((v) => v.status == 'Pending').length;
    final cancelled = visits.where((v) => v.status == 'Cancelled').length;
    return {
      'total': visits.length,
      'completed': completed,
      'pending': pending,
      'cancelled': cancelled,
    };
  }
}
