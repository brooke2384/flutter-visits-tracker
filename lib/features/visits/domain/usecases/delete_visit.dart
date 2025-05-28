import '../repositories/visits_repository.dart';

class DeleteVisit {
  final VisitsRepository repository;

  DeleteVisit(this.repository);

  Future<void> call(int id) async {
    return await repository.deleteVisit(id);
  }
}
