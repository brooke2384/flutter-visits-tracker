import '../entities/visit.dart';
import '../repositories/visits_repository.dart';

class GetVisits {
  final VisitsRepository repository;

  GetVisits(this.repository);

  Future<List<Visit>> call({int limit = 20, int offset = 0}) async {
    return await repository.getVisits(limit: limit, offset: offset);
  }
}
