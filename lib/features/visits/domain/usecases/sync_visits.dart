import '../repositories/visits_repository.dart';

class SyncVisits {
  final VisitsRepository repository;

  SyncVisits(this.repository);

  Future<void> call() async {
    return await repository.syncVisits();
  }
}
