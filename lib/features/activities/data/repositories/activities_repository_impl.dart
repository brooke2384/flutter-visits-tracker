import '../../domain/entities/activity.dart';
import '../../domain/repositories/activities_repository.dart';
import '../datasources/activities_remote_datasource.dart';

class ActivitiesRepositoryImpl implements ActivitiesRepository {
  final ActivitiesRemoteDataSource remoteDataSource;

  ActivitiesRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Activity>> getActivities() async {
    return await remoteDataSource.getActivities();
  }
}
