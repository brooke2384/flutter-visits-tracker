import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:visits_tracker/features/visits/domain/entities/visit.dart';
import 'package:visits_tracker/features/visits/domain/repositories/visits_repository.dart';
import 'package:visits_tracker/features/visits/domain/usecases/get_visits.dart';

class MockVisitsRepository extends Mock implements VisitsRepository {}

void main() {
  late GetVisits usecase;
  late MockVisitsRepository mockRepository;

  setUp(() {
    mockRepository = MockVisitsRepository();
    usecase = GetVisits(mockRepository);
  });

  final tVisits = [
    Visit(
      id: 1,
      customerId: 1,
      visitDate: DateTime.parse('2023-10-01T10:00:00Z'),
      status: 'Completed',
      location: '123 Main St',
      notes: 'Test visit',
      activitiesDone: [1, 2],
      createdAt: DateTime.parse('2023-10-01T09:00:00Z'),
    ),
  ];

  test('should get visits from the repository', () async {
    // arrange
    when(() => mockRepository.getVisits()).thenAnswer((_) async => tVisits);

    // act
    final result = await usecase();

    // assert
    expect(result, tVisits);
    verify(() => mockRepository.getVisits());
    verifyNoMoreInteractions(mockRepository);
  });
}
