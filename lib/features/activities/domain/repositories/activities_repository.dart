import '../entities/activity.dart';

abstract class ActivitiesRepository {
  Future<List<Activity>> getActivities();
}
