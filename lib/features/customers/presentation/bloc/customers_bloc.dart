import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/customer.dart';
import '../../domain/usecases/get_customers.dart';

part 'customers_event.dart';
part 'customers_state.dart';

class CustomersBloc extends Bloc<CustomersEvent, CustomersState> {
  final GetCustomers getCustomers;

  CustomersBloc(this.getCustomers) : super(CustomersInitial()) {
    on<LoadCustomers>(_onLoadCustomers);
  }

  Future<void> _onLoadCustomers(
    LoadCustomers event,
    Emitter<CustomersState> emit,
  ) async {
    emit(CustomersLoading());
    try {
      final customers = await getCustomers();
      emit(CustomersLoaded(customers));
    } catch (e) {
      emit(CustomersError(e.toString()));
    }
  }
}
