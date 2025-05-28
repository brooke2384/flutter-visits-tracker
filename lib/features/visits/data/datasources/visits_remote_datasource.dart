import '../../../../core/network/api_client.dart';
import '../models/visit_model.dart';

abstract class VisitsRemoteDataSource {
  Future<List<VisitModel>> getVisits();
  Future<VisitModel> createVisit(VisitModel visit);
  Future<VisitModel> updateVisit(VisitModel visit);
  Future<void> deleteVisit(int id);
}

class VisitsRemoteDataSourceImpl implements VisitsRemoteDataSource {
  final ApiClient apiClient;

  VisitsRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<VisitModel>> getVisits() async {
    return await apiClient.getVisits();
  }

  @override
  Future<VisitModel> createVisit(VisitModel visit) async {
    return await apiClient.createVisit(visit.toJson());
  }

  @override
  Future<VisitModel> updateVisit(VisitModel visit) async {
    return await apiClient.updateVisit(visit.id.toString(), visit.toJson());
  }

  @override
  Future<void> deleteVisit(int id) async {
    return await apiClient.deleteVisit(id.toString());
  }
}
