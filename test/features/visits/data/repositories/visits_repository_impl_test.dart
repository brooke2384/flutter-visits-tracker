import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:visits_tracker/features/visits/data/datasources/visits_local_datasource.dart';
import 'package:visits_tracker/features/visits/data/datasources/visits_remote_datasource.dart';
import 'package:visits_tracker/features/visits/data/models/visit_model.dart';
import 'package:visits_tracker/features/visits/data/repositories/visits_repository_impl.dart';
import 'package:visits_tracker/features/visits/domain/entities/visit.dart';

class MockVisitsRemoteDataSource extends Mock implements VisitsRemoteDataSource {}
class MockVisitsLocalDataSource extends Mock implements VisitsLocalDataSource {}

void main() {
  late VisitsRepositoryImpl repository;
  late MockVisitsRemoteDataSource mockRemoteDataSource;
  late MockVisitsLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockVisitsRemoteDataSource();
    mockLocalDataSource = MockVisitsLocalDataSource();
    repository = VisitsRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  final tVisitModel = VisitModel(
    id: 1,
    customerId: 1,
    visitDate: DateTime.parse('2023-10-01T10:00:00Z'),
    status: 'Completed',
    location: '123 Main St',
    notes: 'Test visit',
    activitiesDone: [1, 2],
    createdAt: DateTime.parse('2023-10-01T09:00:00Z'),
  );

  final tVisit = Visit(
    id: 1,
    customerId: 1,
    visitDate: DateTime.parse('2023-10-01T10:00:00Z'),
    status: 'Completed',
    location: '123 Main St',
    notes: 'Test visit',
    activitiesDone: [1, 2],
    createdAt: DateTime.parse('2023-10-01T09:00:00Z'),
  );

  group('getVisits', () {
    test('should return visits from local data source when remote fails', () async {
      // arrange
      when(() => mockRemoteDataSource.getVisits()).thenThrow(Exception());
      when(() => mockLocalDataSource.getVisits()).thenAnswer((_) async => [tVisitModel]);

      // act
      final result = await repository.getVisits();

      // assert
      expect(result, [tVisitModel]);
      verify(() => mockLocalDataSource.getVisits());
    });
  });

  group('createVisit', () {
    test('should create visit locally and return it', () async {
      // arrange
      when(() => mockLocalDataSource.createVisit(any())).thenAnswer((_) async => tVisitModel);

      // act
      final result = await repository.createVisit(tVisit);

      // assert
      expect(result, tVisitModel);
      verify(() => mockLocalDataSource.createVisit(any()));
    });
  });
}
