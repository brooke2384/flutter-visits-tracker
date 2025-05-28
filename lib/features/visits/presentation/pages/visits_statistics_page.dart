import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/visits_bloc.dart';

class VisitsStatisticsPage extends StatefulWidget {
  const VisitsStatisticsPage({super.key});

  @override
  State<VisitsStatisticsPage> createState() => _VisitsStatisticsPageState();
}

class _VisitsStatisticsPageState extends State<VisitsStatisticsPage> {
  Map<String, int> statistics = {};

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  void _loadStatistics() async {
    final visitsState = context.read<VisitsBloc>().state;
    if (visitsState is VisitsLoaded) {
      final visits = visitsState.visits;
      
      final completed = visits.where((v) => v.status == 'Completed').length;
      final pending = visits.where((v) => v.status == 'Pending').length;
      final cancelled = visits.where((v) => v.status == 'Cancelled').length;
      
      setState(() {
        statistics = {
          'total': visits.length,
          'completed': completed,
          'pending': pending,
          'cancelled': cancelled,
        };
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Visit Statistics'),
        elevation: 0,
        backgroundColor: theme.colorScheme.surface,
        foregroundColor: theme.colorScheme.onSurface,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Overview Cards
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Total Visits',
                    value: statistics['total']?.toString() ?? '0',
                    color: theme.colorScheme.primary,
                    icon: Icons.business_center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Completed',
                    value: statistics['completed']?.toString() ?? '0',
                    color: Colors.green,
                    icon: Icons.check_circle,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    title: 'Pending',
                    value: statistics['pending']?.toString() ?? '0',
                    color: Colors.orange,
                    icon: Icons.schedule,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    title: 'Cancelled',
                    value: statistics['cancelled']?.toString() ?? '0',
                    color: Colors.red,
                    icon: Icons.cancel,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Completion Rate
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Completion Rate',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildCompletionRate(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: color,
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletionRate() {
    final total = statistics['total'] ?? 0;
    final completed = statistics['completed'] ?? 0;
    final rate = total > 0 ? (completed / total) : 0.0;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('${(rate * 100).toStringAsFixed(1)}%', style: Theme.of(context).textTheme.titleMedium),
            Text('$completed of $total visits', style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: rate,
            minHeight: 10,
            backgroundColor: Theme.of(context).colorScheme.surfaceVariant,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
      ],
    );
  }
}
