import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../bloc/visits_bloc.dart';
import '../widgets/visit_card.dart';
import '../widgets/visits_search_bar.dart';
import '../../../activities/presentation/bloc/activities_bloc.dart';

class VisitsListPage extends StatefulWidget {
  const VisitsListPage({super.key});

  @override
  State<VisitsListPage> createState() => _VisitsListPageState();
}

class _VisitsListPageState extends State<VisitsListPage> {
  @override
  void initState() {
    super.initState();
    context.read<VisitsBloc>().add(LoadVisits());
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Visits Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sync),
            tooltip: 'Sync',
            onPressed: () {
              context.read<VisitsBloc>().add(SyncVisitsEvent());
            },
          ),
          IconButton(
            icon: const Icon(Icons.analytics),
            tooltip: 'Statistics',
            onPressed: () {
              context.pushNamed('visits-statistics');
            },
          ),
        ],
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: VisitsSearchBar(),
          ),
          Expanded(
            child: BlocBuilder<VisitsBloc, VisitsState>(
              builder: (context, state) {
                if (state is VisitsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(strokeWidth: 3),
                  );
                } else if (state is VisitsSyncing) {
                  return const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(strokeWidth: 3),
                        SizedBox(height: 16),
                        Text('Syncing visits...'),
                      ],
                    ),
                  );
                } else if (state is VisitsLoaded) {
                  return BlocBuilder<ActivitiesBloc, ActivitiesState>(
                    builder: (context, activitiesState) {
                      if (state.visits.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.business_center, size: 80, color: theme.colorScheme.outline),
                              const SizedBox(height: 20),
                              Text(
                                'No visits found',
                                style: theme.textTheme.titleMedium?.copyWith(color: theme.colorScheme.outline),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                'Tap the + button to add your first visit',
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline),
                              ),
                            ],
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async {
                          context.read<VisitsBloc>().add(LoadVisits());
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                          itemCount: state.hasMore ? state.visits.length + 1 : state.visits.length,
                          itemBuilder: (context, index) {
                            if (index < state.visits.length) {
                              final visit = state.visits[index];
                              List<String> activityDescriptions = [];
                              if (activitiesState is ActivitiesLoaded) {
                                activityDescriptions = activitiesState.activities
                                  .where((a) => visit.activitiesDone.contains(a.id))
                                  .map((a) => a.description)
                                  .toList();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 12),
                                child: VisitCard(
                                  visit: visit,
                                  activityDescriptions: activityDescriptions,
                                  onTap: () {
                                    if (visit.id != null) {
                                      context.pushNamed(
                                        'visit-details',
                                        pathParameters: {'id': visit.id.toString()},
                                      );
                                    }
                                  },
                                  onEdit: () {
                                    if (visit.id != null) {
                                      context.pushNamed(
                                        'edit-visit',
                                        pathParameters: {'id': visit.id.toString()},
                                      );
                                    }
                                  },
                                  onDelete: () {
                                    if (visit.id != null) {
                                      _showDeleteDialog(context, visit.id!);
                                    }
                                  },
                                ),
                              );
                            } else {
                              // Load More button
                              return Padding(
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                child: Center(
                                  child: OutlinedButton.icon(
                                    icon: const Icon(Icons.expand_more),
                                    label: const Text('Load More'),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () {
                                      context.read<VisitsBloc>().add(LoadMoreVisits());
                                    },
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      );
                    },
                  );
                } else if (state is VisitsError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error, size: 64, color: theme.colorScheme.error),
                        const SizedBox(height: 16),
                        Text(
                          'Error: ${state.message}',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          ),
                          onPressed: () {
                            context.read<VisitsBloc>().add(LoadVisits());
                          },
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed('create-visit');
        },
        icon: const Icon(Icons.add),
        label: const Text('New Visit'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        backgroundColor: theme.colorScheme.primary,
        foregroundColor: theme.colorScheme.onPrimary,
        elevation: 3,
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, int visitId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Visit'),
          content: const Text('Are you sure you want to delete this visit?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                context.read<VisitsBloc>().add(DeleteVisitEvent(visitId));
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }
}
