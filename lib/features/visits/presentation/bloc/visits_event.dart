part of 'visits_bloc.dart';

abstract class VisitsEvent extends Equatable {
  const VisitsEvent();

  @override
  List<Object> get props => [];
}

class LoadVisits extends VisitsEvent {}

class CreateVisitEvent extends VisitsEvent {
  final Visit visit;

  const CreateVisitEvent(this.visit);

  @override
  List<Object> get props => [visit];
}

class UpdateVisitEvent extends VisitsEvent {
  final Visit visit;

  const UpdateVisitEvent(this.visit);

  @override
  List<Object> get props => [visit];
}

class DeleteVisitEvent extends VisitsEvent {
  final int id;

  const DeleteVisitEvent(this.id);

  @override
  List<Object> get props => [id];
}

class SyncVisitsEvent extends VisitsEvent {}

class SearchVisitsEvent extends VisitsEvent {
  final String query;

  const SearchVisitsEvent(this.query);

  @override
  List<Object> get props => [query];
}

class LoadMoreVisits extends VisitsEvent {}
