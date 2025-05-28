import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:visits_tracker/features/visits/domain/entities/visit.dart';
import 'package:visits_tracker/features/visits/domain/usecases/get_visits.dart';
import 'package:visits_tracker/features/visits/domain/usecases/create_visit.dart';
import 'package:visits_tracker/features/visits/domain/usecases/update_visit.dart';
import 'package:visits_tracker/features/visits/domain/usecases/delete_visit.dart';
import 'package:visits_tracker/features/visits/domain/usecases/sync_visits.dart';
import 'package:visits_tracker/features/visits/presentation/bloc/visits_bloc.dart';

class MockGetVisits extends Mock implements GetVisits {}
class MockCreateVisit extends Mock implements CreateVisit {}
class MockUpdateVisit extends Mock implements UpdateVisit {}
class MockDeleteVisit extends Mock implements DeleteVisit {}
class MockSyncVisits extends Mock implements SyncVisits {}

void main() {
  late VisitsBloc bloc;
  late MockGetVisits mockGetVisits;
  late MockCreateVisit mockCreateVisit;
  late MockUpdateVisit mockUpdateVisit;
  late MockDeleteVisit mockDeleteVisit;
  late MockSyncVisits mockSyncVisits;

  setUp(() {
    mockGetVisits = MockGetVisits();
    mockCreateVisit = MockCreateVisit();
    mockUpdateVisit = MockUpdateVisit();
    mockDeleteVisit = MockDeleteVisit();
    mockSyncVisits = MockSyncVisits();
    
    bloc = VisitsBloc(
      getVisits: mockGetVisits,
      createVisit: mockCreateVisit,
      updateVisit: mockUpdateVisit,
      deleteVisit: mockDeleteVisit,
      syncVisits: mockSyncVisits,
    );
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

  group('LoadVisits', () {
    blocTest<VisitsBloc, VisitsState>(
      'emits [VisitsLoading, VisitsLoaded] when LoadVisits is added',
      build: () {
        when(() => mockGetVisits()).thenAnswer((_) async => tVisits);
        return bloc;
      },
      act: (bloc) => bloc.add(LoadVisits()),
      expect: () => [
        VisitsLoading(),
        VisitsLoaded(tVisits),
      ],
    );

    blocTest<VisitsBloc, VisitsState>(
      'emits [VisitsLoading, VisitsError] when LoadVisits fails',
      build: () {
        when(() => mockGetVisits()).thenThrow(Exception('Failed to load visits'));
        return bloc;
      },
      act: (bloc) => bloc.add(LoadVisits()),
      expect: () => [
        VisitsLoading(),
        const VisitsError('Exception: Failed to load visits'),
      ],
    );
  });
}
