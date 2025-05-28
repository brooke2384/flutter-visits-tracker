part of 'activities_bloc.dart';

abstract class ActivitiesState extends Equatable {
  const ActivitiesState();

  @override
  List<Object> get props => [];
}

class ActivitiesInitial extends ActivitiesState {}

class ActivitiesLoading extends ActivitiesState {}

class ActivitiesLoaded extends ActivitiesState {
  final List<Activity> activities;

  const ActivitiesLoaded(this.activities);

  @override
  List<Object> get props => [activities];
}

class ActivitiesError extends ActivitiesState {
  final String message;

  const ActivitiesError(this.message);

  @override
  List<Object> get props => [message];
}
