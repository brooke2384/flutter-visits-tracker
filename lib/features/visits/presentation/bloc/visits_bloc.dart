import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/visit.dart';
import '../../domain/usecases/get_visits.dart';
import '../../domain/usecases/create_visit.dart';
import '../../domain/usecases/update_visit.dart';
import '../../domain/usecases/delete_visit.dart';
import '../../domain/usecases/sync_visits.dart';

part 'visits_event.dart';
part 'visits_state.dart';

class VisitsBloc extends Bloc<VisitsEvent, VisitsState> {
  final GetVisits getVisits;
  final CreateVisit createVisit;
  final UpdateVisit updateVisit;
  final DeleteVisit deleteVisit;
  final SyncVisits syncVisits;

  int _currentOffset = 0;
  static const int _pageSize = 10;
  bool _hasMore = true;
  List<Visit> _allVisits = [];

  VisitsBloc({
    required this.getVisits,
    required this.createVisit,
    required this.updateVisit,
    required this.deleteVisit,
    required this.syncVisits,
  }) : super(VisitsInitial()) {
    on<LoadVisits>(_onLoadVisits);
    on<LoadMoreVisits>(_onLoadMoreVisits);
    on<CreateVisitEvent>(_onCreateVisit);
    on<UpdateVisitEvent>(_onUpdateVisit);
    on<DeleteVisitEvent>(_onDeleteVisit);
    on<SyncVisitsEvent>(_onSyncVisits);
    on<SearchVisitsEvent>(_onSearchVisits);
  }

  Future<void> _onLoadVisits(
    LoadVisits event,
    Emitter<VisitsState> emit,
  ) async {
    emit(VisitsLoading());
    _currentOffset = 0;
    _allVisits = [];
    _hasMore = true;
    try {
      final visits = await getVisits.call(limit: _pageSize, offset: 0);
      _allVisits = visits;
      _hasMore = visits.length == _pageSize;
      emit(VisitsLoaded(_allVisits, hasMore: _hasMore));
    } catch (e) {
      emit(VisitsError(e.toString()));
    }
  }

  Future<void> _onLoadMoreVisits(
    LoadMoreVisits event,
    Emitter<VisitsState> emit,
  ) async {
    if (!_hasMore) return;
    try {
      final nextOffset = _allVisits.length;
      final visits = await getVisits.call(limit: _pageSize, offset: nextOffset);
      _allVisits.addAll(visits);
      _hasMore = visits.length == _pageSize;
      emit(VisitsLoaded(_allVisits, hasMore: _hasMore));
    } catch (e) {
      emit(VisitsError(e.toString()));
    }
  }

  Future<void> _onCreateVisit(
    CreateVisitEvent event,
    Emitter<VisitsState> emit,
  ) async {
    try {
      await createVisit(event.visit);
      add(LoadVisits());
    } catch (e) {
      emit(VisitsError(e.toString()));
    }
  }

  Future<void> _onUpdateVisit(
    UpdateVisitEvent event,
    Emitter<VisitsState> emit,
  ) async {
    try {
      await updateVisit(event.visit);
      add(LoadVisits());
    } catch (e) {
      emit(VisitsError(e.toString()));
    }
  }

  Future<void> _onDeleteVisit(
    DeleteVisitEvent event,
    Emitter<VisitsState> emit,
  ) async {
    try {
      await deleteVisit(event.id);
      add(LoadVisits());
    } catch (e) {
      emit(VisitsError(e.toString()));
    }
  }

  Future<void> _onSyncVisits(
    SyncVisitsEvent event,
    Emitter<VisitsState> emit,
  ) async {
    emit(VisitsSyncing());
    try {
      await syncVisits();
      add(LoadVisits());
    } catch (e) {
      emit(VisitsError(e.toString()));
    }
  }

  Future<void> _onSearchVisits(
    SearchVisitsEvent event,
    Emitter<VisitsState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(LoadVisits());
      return;
    }

    emit(VisitsLoading());
    try {
      final visits = await getVisits.call();
      final filteredVisits = visits.where((visit) =>
          visit.location.toLowerCase().contains(event.query.toLowerCase()) ||
          (visit.notes?.toLowerCase().contains(event.query.toLowerCase()) ?? false)
      ).toList();
      emit(VisitsLoaded(filteredVisits));
    } catch (e) {
      emit(VisitsError(e.toString()));
    }
  }
}
