import '../../../../core/network/api_client.dart';
import '../models/activity_model.dart';

abstract class ActivitiesRemoteDataSource {
  Future<List<ActivityModel>> getActivities();
}

class ActivitiesRemoteDataSourceImpl implements ActivitiesRemoteDataSource {
  final ApiClient apiClient;

  ActivitiesRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<ActivityModel>> getActivities() async {
    return await apiClient.getActivities();
  }
}
