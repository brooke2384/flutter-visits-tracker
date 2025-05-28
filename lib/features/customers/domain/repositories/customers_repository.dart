import '../entities/customer.dart';

abstract class CustomersRepository {
  Future<List<Customer>> getCustomers();
}
