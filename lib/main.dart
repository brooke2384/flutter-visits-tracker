import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get_it/get_it.dart';
import 'package:dio/dio.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'core/di/injection.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/visits/presentation/bloc/visits_bloc.dart';
import 'features/customers/presentation/bloc/customers_bloc.dart';
import 'features/activities/presentation/bloc/activities_bloc.dart';

Future<void> testApiConnection() async {
  try {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://kqgbftwsodpttpqgqnbh.supabase.co/rest/v1',
      headers: {
        'apikey': 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtxZ2JmdHdzb2RwdHRwcWdxbmJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5ODk5OTksImV4cCI6MjA2MTU2NTk5OX0.rwJSY4bJaNdB8jDn3YJJu_gKtznzm-dUKQb4OvRtP6c',
        'Authorization': 'Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtxZ2JmdHdzb2RwdHRwcWdxbmJoIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDU5ODk5OTksImV4cCI6MjA2MTU2NTk5OX0.rwJSY4bJaNdB8jDn3YJJu_gKtznzm-dUKQb4OvRtP6c',
      },
    ));

    print('🔍 Testing API connection...');
    
    // Test customers endpoint
    final customersResponse = await dio.get('/customers');
    print('✅ Customers API: ${customersResponse.statusCode} - ${customersResponse.data.length} customers found');
    
    // Test activities endpoint
    final activitiesResponse = await dio.get('/activities');
    print('✅ Activities API: ${activitiesResponse.statusCode} - ${activitiesResponse.data.length} activities found');
    
    // Test visits endpoint
    final visitsResponse = await dio.get('/visits');
    print('✅ Visits API: ${visitsResponse.statusCode} - ${visitsResponse.data.length} visits found');
    
    print('🎉 All API endpoints are working!');
  } catch (e) {
    print('❌ API connection failed: $e');
  }
}

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> initializeNotifications() async {
  tz.initializeTimeZones();
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');
  final InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );
  await flutterLocalNotificationsPlugin.initialize(initializationSettings);
}

Future<void> scheduleVisitReminderNotification(int visitId, String title, DateTime scheduledTime) async {
  final tz.TZDateTime tzScheduled = tz.TZDateTime.from(scheduledTime, tz.local);
  await flutterLocalNotificationsPlugin.zonedSchedule(
    visitId,
    'Visit Reminder',
    title,
    tzScheduled,
    const NotificationDetails(
      android: AndroidNotificationDetails(
        'visit_reminders',
        'Visit Reminders',
        channelDescription: 'Reminders for scheduled visits',
        importance: Importance.max,
        priority: Priority.high,
      ),
    ),
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation: UILocalNotificationDateInterpretation.absoluteTime,
    matchDateTimeComponents: DateTimeComponents.dateAndTime,
  );
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Test API connection
  await testApiConnection();
  
  // Initialize dependency injection
  await configureDependencies();
  
  await initializeNotifications();
  
  runApp(const VisitsTrackerAppWithConnectivity());
}

class VisitsTrackerAppWithConnectivity extends StatefulWidget {
  const VisitsTrackerAppWithConnectivity({super.key});
  @override
  State<VisitsTrackerAppWithConnectivity> createState() => _VisitsTrackerAppWithConnectivityState();
}

class _VisitsTrackerAppWithConnectivityState extends State<VisitsTrackerAppWithConnectivity> {
  late final Connectivity _connectivity;
  late final Stream<ConnectivityResult> _connectivityStream;
  @override
  void initState() {
    super.initState();
    _connectivity = Connectivity();
    _connectivityStream = _connectivity.onConnectivityChanged;
    // Listen for connectivity changes
    _connectivityStream.listen((result) {
      if (result != ConnectivityResult.none) {
        // Trigger sync when online
        // Use context directly (only triggers sync, no snackbar)
        final visitsBloc = BlocProvider.of<VisitsBloc>(context, listen: false);
        visitsBloc.add(SyncVisitsEvent());
      }
    });
    // Trigger sync on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final visitsBloc = BlocProvider.of<VisitsBloc>(context, listen: false);
      visitsBloc.add(SyncVisitsEvent());
    });
  }
  @override
  Widget build(BuildContext context) {
    return VisitsTrackerApp();
  }
}

class VisitsTrackerApp extends StatelessWidget {
  const VisitsTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => GetIt.instance<VisitsBloc>()),
        BlocProvider(create: (_) => GetIt.instance<CustomersBloc>()),
        BlocProvider(create: (_) => GetIt.instance<ActivitiesBloc>()),
      ],
      child: MaterialApp.router(
        title: 'Visits Tracker',
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}
