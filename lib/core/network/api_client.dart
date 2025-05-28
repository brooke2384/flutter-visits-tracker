import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';

import '../../features/visits/data/models/visit_model.dart';
import '../../features/customers/data/models/customer_model.dart';
import '../../features/activities/data/models/activity_model.dart';

part 'api_client.g.dart';

@RestApi()
abstract class ApiClient {
  factory ApiClient(Dio dio, {String baseUrl}) = _ApiClient;

  // Visits endpoints
  @GET('/visits')
  Future<List<VisitModel>> getVisits();

  @POST('/visits')
  Future<VisitModel> createVisit(@Body() Map<String, dynamic> visit);

  @PATCH('/visits')
  Future<VisitModel> updateVisit(
    @Query('id') String id,
    @Body() Map<String, dynamic> visit,
  );

  @DELETE('/visits')
  Future<void> deleteVisit(@Query('id') String id);

  // Customers endpoints
  @GET('/customers')
  Future<List<CustomerModel>> getCustomers();

  // Activities endpoints
  @GET('/activities')
  Future<List<ActivityModel>> getActivities();
}
