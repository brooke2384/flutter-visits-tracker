part of 'visits_bloc.dart';

abstract class VisitsState extends Equatable {
  const VisitsState();

  @override
  List<Object> get props => [];
}

class VisitsInitial extends VisitsState {}

class VisitsLoading extends VisitsState {}

class VisitsLoaded extends VisitsState {
  final List<Visit> visits;
  final bool hasMore;

  const VisitsLoaded(this.visits, {this.hasMore = true});

  @override
  List<Object> get props => [visits, hasMore];
}

class VisitsSyncing extends VisitsState {}

class VisitsError extends VisitsState {
  final String message;

  const VisitsError(this.message);

  @override
  List<Object> get props => [message];
}
