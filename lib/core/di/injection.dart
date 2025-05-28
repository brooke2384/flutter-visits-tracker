import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:sqflite/sqflite.dart';
import 'package:flutter/foundation.dart';

import '../database/database_helper.dart';
import '../network/api_client.dart';
import '../network/dio_client.dart';
import '../../features/visits/data/datasources/visits_local_datasource.dart';
import '../../features/visits/data/datasources/visits_remote_datasource.dart';
import '../../features/visits/data/repositories/visits_repository_impl.dart';
import '../../features/visits/domain/repositories/visits_repository.dart';
import '../../features/visits/domain/usecases/get_visits.dart';
import '../../features/visits/domain/usecases/create_visit.dart';
import '../../features/visits/domain/usecases/update_visit.dart';
import '../../features/visits/domain/usecases/delete_visit.dart';
import '../../features/visits/domain/usecases/sync_visits.dart';
import '../../features/visits/presentation/bloc/visits_bloc.dart';
import '../../features/customers/data/datasources/customers_remote_datasource.dart';
import '../../features/customers/data/repositories/customers_repository_impl.dart';
import '../../features/customers/domain/repositories/customers_repository.dart';
import '../../features/customers/domain/usecases/get_customers.dart';
import '../../features/customers/presentation/bloc/customers_bloc.dart';
import '../../features/activities/data/datasources/activities_remote_datasource.dart';
import '../../features/activities/data/repositories/activities_repository_impl.dart';
import '../../features/activities/domain/repositories/activities_repository.dart';
import '../../features/activities/domain/usecases/get_activities.dart';
import '../../features/activities/presentation/bloc/activities_bloc.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  Database? database;
  if (!kIsWeb) {
    // Database (not for web)
    database = await DatabaseHelper.database;
    getIt.registerSingleton<Database>(database);
    // Local Data Sources (not for web)
    getIt.registerLazySingleton<VisitsLocalDataSource>(
      () => VisitsLocalDataSourceImpl(getIt<Database>()),
    );
  }
  // Network
  final dio = DioClient.createDio();
  getIt.registerSingleton<Dio>(dio);
  final apiClient = ApiClient(dio);
  getIt.registerSingleton<ApiClient>(apiClient);
  // Data Sources
  getIt.registerLazySingleton<VisitsRemoteDataSource>(
    () => VisitsRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<CustomersRemoteDataSource>(
    () => CustomersRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<ActivitiesRemoteDataSource>(
    () => ActivitiesRemoteDataSourceImpl(getIt<ApiClient>()),
  );
  // Repositories
  getIt.registerLazySingleton<VisitsRepository>(
    () => VisitsRepositoryImpl(
      remoteDataSource: getIt<VisitsRemoteDataSource>(),
      localDataSource: kIsWeb ? null : getIt<VisitsLocalDataSource>(),
    ),
  );
  getIt.registerLazySingleton<CustomersRepository>(
    () => CustomersRepositoryImpl(getIt<CustomersRemoteDataSource>()),
  );
  getIt.registerLazySingleton<ActivitiesRepository>(
    () => ActivitiesRepositoryImpl(getIt<ActivitiesRemoteDataSource>()),
  );
  // Use Cases
  getIt.registerLazySingleton(() => GetVisits(getIt<VisitsRepository>()));
  getIt.registerLazySingleton(() => CreateVisit(getIt<VisitsRepository>()));
  getIt.registerLazySingleton(() => UpdateVisit(getIt<VisitsRepository>()));
  getIt.registerLazySingleton(() => DeleteVisit(getIt<VisitsRepository>()));
  getIt.registerLazySingleton(() => SyncVisits(getIt<VisitsRepository>()));
  getIt.registerLazySingleton(() => GetCustomers(getIt<CustomersRepository>()));
  getIt.registerLazySingleton(() => GetActivities(getIt<ActivitiesRepository>()));
  // BLoCs
  getIt.registerFactory(() => VisitsBloc(
    getVisits: getIt<GetVisits>(),
    createVisit: getIt<CreateVisit>(),
    updateVisit: getIt<UpdateVisit>(),
    deleteVisit: getIt<DeleteVisit>(),
    syncVisits: getIt<SyncVisits>(),
  ));
  getIt.registerFactory(() => CustomersBloc(getIt<GetCustomers>()));
  getIt.registerFactory(() => ActivitiesBloc(getIt<GetActivities>()));
}
