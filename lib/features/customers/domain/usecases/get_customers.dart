import '../entities/customer.dart';
import '../repositories/customers_repository.dart';

class GetCustomers {
  final CustomersRepository repository;

  GetCustomers(this.repository);

  Future<List<Customer>> call() async {
    return await repository.getCustomers();
  }
}
