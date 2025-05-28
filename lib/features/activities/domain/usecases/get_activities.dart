import '../entities/activity.dart';
import '../repositories/activities_repository.dart';

class GetActivities {
  final ActivitiesRepository repository;

  GetActivities(this.repository);

  Future<List<Activity>> call() async {
    return await repository.getActivities();
  }
}
