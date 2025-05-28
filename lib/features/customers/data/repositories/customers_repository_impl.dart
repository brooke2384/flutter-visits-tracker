import '../../domain/entities/customer.dart';
import '../../domain/repositories/customers_repository.dart';
import '../datasources/customers_remote_datasource.dart';

class CustomersRepositoryImpl implements CustomersRepository {
  final CustomersRemoteDataSource remoteDataSource;

  CustomersRepositoryImpl(this.remoteDataSource);

  @override
  Future<List<Customer>> getCustomers() async {
    return await remoteDataSource.getCustomers();
  }
}
