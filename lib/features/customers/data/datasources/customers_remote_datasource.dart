import '../../../../core/network/api_client.dart';
import '../models/customer_model.dart';

abstract class CustomersRemoteDataSource {
  Future<List<CustomerModel>> getCustomers();
}

class CustomersRemoteDataSourceImpl implements CustomersRemoteDataSource {
  final ApiClient apiClient;

  CustomersRemoteDataSourceImpl(this.apiClient);

  @override
  Future<List<CustomerModel>> getCustomers() async {
    return await apiClient.getCustomers();
  }
}
