import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';

import '../../features/visits/presentation/pages/visits_list_page.dart';
import '../../features/visits/presentation/pages/visit_form_page.dart';
import '../../features/visits/presentation/pages/visit_details_page.dart';
import '../../features/visits/presentation/pages/visits_statistics_page.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/visits',
    routes: [
      GoRoute(
        path: '/visits',
        name: 'visits',
        builder: (context, state) => const VisitsListPage(),
        routes: [
          GoRoute(
            path: 'create',
            name: 'create-visit',
            builder: (context, state) => const VisitFormPage(),
          ),
          GoRoute(
            path: 'edit/:id',
            name: 'edit-visit',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return VisitFormPage(visitId: int.parse(id));
            },
          ),
          GoRoute(
            path: 'details/:id',
            name: 'visit-details',
            builder: (context, state) {
              final id = state.pathParameters['id']!;
              return VisitDetailsPage(visitId: int.parse(id));
            },
          ),
          GoRoute(
            path: 'statistics',
            name: 'visits-statistics',
            builder: (context, state) => const VisitsStatisticsPage(),
          ),
        ],
      ),
    ],
  );
}
