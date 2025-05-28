import '../entities/visit.dart';
import '../repositories/visits_repository.dart';

class CreateVisit {
  final VisitsRepository repository;

  CreateVisit(this.repository);

  Future<Visit> call(Visit visit) async {
    return await repository.createVisit(visit);
  }
}
