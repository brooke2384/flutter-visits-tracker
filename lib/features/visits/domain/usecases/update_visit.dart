import '../entities/visit.dart';
import '../repositories/visits_repository.dart';

class UpdateVisit {
  final VisitsRepository repository;

  UpdateVisit(this.repository);

  Future<Visit> call(Visit visit) async {
    return await repository.updateVisit(visit);
  }
}
