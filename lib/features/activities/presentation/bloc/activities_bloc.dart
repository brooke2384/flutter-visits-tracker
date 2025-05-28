import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/activity.dart';
import '../../domain/usecases/get_activities.dart';

part 'activities_event.dart';
part 'activities_state.dart';

class ActivitiesBloc extends Bloc<ActivitiesEvent, ActivitiesState> {
  final GetActivities getActivities;

  ActivitiesBloc(this.getActivities) : super(ActivitiesInitial()) {
    on<LoadActivities>(_onLoadActivities);
  }

  Future<void> _onLoadActivities(
    LoadActivities event,
    Emitter<ActivitiesState> emit,
  ) async {
    emit(ActivitiesLoading());
    try {
      final activities = await getActivities();
      emit(ActivitiesLoaded(activities));
    } catch (e) {
      emit(ActivitiesError(e.toString()));
    }
  }
}
