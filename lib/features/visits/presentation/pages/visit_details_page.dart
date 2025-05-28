import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../domain/entities/visit.dart';
import '../bloc/visits_bloc.dart';
import '../../../customers/presentation/bloc/customers_bloc.dart';
import '../../../activities/presentation/bloc/activities_bloc.dart';

class VisitDetailsPage extends StatefulWidget {
  final int visitId;

  const VisitDetailsPage({super.key, required this.visitId});

  @override
  State<VisitDetailsPage> createState() => _VisitDetailsPageState();
}

class _VisitDetailsPageState extends State<VisitDetailsPage> {
  Visit? visit;

  @override
  void initState() {
    super.initState();
    context.read<CustomersBloc>().add(LoadCustomers());
    context.read<ActivitiesBloc>().add(LoadActivities());
    _loadVisit();
  }

  void _loadVisit() {
    final visitsState = context.read<VisitsBloc>().state;
    if (visitsState is VisitsLoaded) {
      visit = visitsState.visits
          .where((v) => v.id == widget.visitId)
          .firstOrNull;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (visit == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Visit Details')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final theme = Theme.of(context);
    final dateFormat = DateFormat('EEEE, MMM dd, yyyy  HH:mm');

    Color statusColor;
    switch (visit!.status.toLowerCase()) {
      case 'completed':
        statusColor = Colors.green;
        break;
      case 'pending':
        statusColor = Colors.orange;
        break;
      case 'cancelled':
        statusColor = Colors.red;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () {
              context.pushNamed(
                'edit-visit',
                pathParameters: {'id': visit!.id.toString()},
              );
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Customer avatar (first letter of location)
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: theme.colorScheme.primary.withOpacity(0.15),
                      child: Text(
                        visit!.location.isNotEmpty ? visit!.location[0].toUpperCase() : '?',
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            visit!.location,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Icon(Icons.schedule, size: 18, color: theme.colorScheme.outline),
                              const SizedBox(width: 4),
                              Text(
                                dateFormat.format(visit!.visitDate),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.outline,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    // Status chip
                    Chip(
                      label: Text(
                        visit!.status,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      backgroundColor: statusColor.withOpacity(0.12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      side: BorderSide(color: statusColor.withOpacity(0.3)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Visit Information
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Visit Information',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildInfoRow(
                      icon: Icons.schedule,
                      label: 'Date & Time',
                      value: dateFormat.format(visit!.visitDate),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(
                      icon: Icons.location_on,
                      label: 'Location',
                      value: visit!.location,
                    ),
                    const SizedBox(height: 12),
                    BlocBuilder<CustomersBloc, CustomersState>(
                      builder: (context, state) {
                        if (state is CustomersLoaded) {
                          final customer = state.customers
                              .where((c) => c.id == visit!.customerId)
                              .firstOrNull;
                          return _buildInfoRow(
                            icon: Icons.business,
                            label: 'Customer',
                            value: customer?.name ?? 'Unknown Customer',
                          );
                        }
                        return _buildInfoRow(
                          icon: Icons.business,
                          label: 'Customer',
                          value: 'Loading...',
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // Activities Completed
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Activities Completed',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    BlocBuilder<ActivitiesBloc, ActivitiesState>(
                      builder: (context, state) {
                        if (state is ActivitiesLoaded) {
                          final completedActivities = state.activities
                              .where((a) => visit!.activitiesDone.contains(a.id))
                              .toList();

                          if (completedActivities.isEmpty) {
                            return const Text(
                              'No activities completed',
                              style: TextStyle(color: Colors.grey),
                            );
                          }

                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: completedActivities.map((activity) {
                              return Chip(
                                label: Text(activity.description, style: const TextStyle(fontSize: 13)),
                                avatar: const Icon(Icons.check_circle, color: Colors.green, size: 18),
                                backgroundColor: theme.colorScheme.primary.withOpacity(0.08),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                              );
                            }).toList(),
                          );
                        }
                        return const CircularProgressIndicator();
                      },
                    ),
                  ],
                ),
              ),
            ),

            // Notes
            if (visit!.notes != null && visit!.notes!.isNotEmpty) ...[
              const SizedBox(height: 18),
              Card(
                elevation: 3,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Notes',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        visit!.notes!,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 20,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
