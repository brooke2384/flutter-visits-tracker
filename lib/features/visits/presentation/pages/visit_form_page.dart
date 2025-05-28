import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:geolocator/geolocator.dart';
import 'package:visits_tracker/main.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:shimmer/shimmer.dart';

import '../../domain/entities/visit.dart';
import '../bloc/visits_bloc.dart';
import '../../../customers/presentation/bloc/customers_bloc.dart';
import '../../../activities/presentation/bloc/activities_bloc.dart';

class VisitFormPage extends StatefulWidget {
  final int? visitId;

  const VisitFormPage({super.key, this.visitId});

  @override
  State<VisitFormPage> createState() => _VisitFormPageState();
}

class _VisitFormPageState extends State<VisitFormPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  Visit? _existingVisit;
  String? _gpsLocation;
  bool _gettingLocation = false;

  @override
  void initState() {
    super.initState();
    context.read<CustomersBloc>().add(LoadCustomers());
    context.read<ActivitiesBloc>().add(LoadActivities());

    if (widget.visitId != null) {
      // Load existing visit for editing
      final visitsState = context.read<VisitsBloc>().state;
      if (visitsState is VisitsLoaded) {
        _existingVisit = visitsState.visits
            .where((v) => v.id == widget.visitId)
            .firstOrNull;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.visitId != null;
    final theme = Theme.of(context);

    final customersState = context.watch<CustomersBloc>().state;
    final activitiesState = context.watch<ActivitiesBloc>().state;
    final isLoading = customersState is! CustomersLoaded || activitiesState is! ActivitiesLoaded;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Visit' : 'New Visit'),
        actions: [
          TextButton(
            onPressed: _saveVisit,
            child: const Text('Save'),
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
      body: BlocListener<VisitsBloc, VisitsState>(
        listener: (context, state) {
          if (state is VisitsLoaded) {
            context.pop();
          } else if (state is VisitsError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Error: ${state.message}')),
            );
          }
        },
        child: isLoading
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Shimmer.fromColors(
                      baseColor: theme.colorScheme.surfaceVariant,
                      highlightColor: theme.colorScheme.surface,
                      child: Column(
                        children: [
                          // Customer dropdown skeleton
                          Container(
                            height: 56,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          // Visit date skeleton
                          Container(
                            height: 56,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          // Reminder skeleton
                          Container(
                            height: 56,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          // Status skeleton
                          Container(
                            height: 56,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          // Location skeleton
                          Container(
                            height: 56,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          // GPS skeleton
                          Container(
                            height: 56,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          // Activities skeleton
                          Container(
                            height: 56,
                            margin: const EdgeInsets.only(bottom: 20),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          // Notes skeleton
                          Container(
                            height: 80,
                            margin: const EdgeInsets.only(bottom: 28),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          // Save button skeleton
                          Container(
                            height: 48,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant,
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            : LayoutBuilder(
                builder: (context, constraints) {
                  return Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 500),
                      child: SingleChildScrollView(
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                          margin: const EdgeInsets.symmetric(vertical: 24, horizontal: 0),
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
                            child: FormBuilder(
                              key: _formKey,
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Customer Selection
                                  FormBuilderDropdown<int>(
                                    name: 'customer_id',
                                    decoration: InputDecoration(
                                      labelText: 'Customer',
                                      filled: true,
                                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18)
                                    ),
                                    initialValue: _existingVisit?.customerId,
                                    validator: FormBuilderValidators.required(),
                                    items: (customersState as CustomersLoaded)
                                        .customers
                                        .map((customer) => DropdownMenuItem(
                                              value: customer.id,
                                              child: Text(customer.name, style: const TextStyle(color: Colors.black)),
                                            ))
                                        .toList(),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  const SizedBox(height: 20),

                                  // Visit Date
                                  FormBuilderDateTimePicker(
                                    name: 'visit_date',
                                    decoration: InputDecoration(
                                      labelText: 'Visit Date & Time',
                                      filled: true,
                                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18)
                                    ),
                                    initialValue: _existingVisit?.visitDate ?? DateTime.now(),
                                    validator: FormBuilderValidators.required(),
                                    format: DateFormat('MMM dd, yyyy HH:mm'),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  const SizedBox(height: 20),

                                  // Reminder (optional)
                                  FormBuilderDateTimePicker(
                                    name: 'reminder',
                                    decoration: InputDecoration(
                                      labelText: 'Reminder (optional)',
                                      helperText: 'Set a reminder notification for this visit',
                                      filled: true,
                                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18)
                                    ),
                                    initialValue: null,
                                    inputType: InputType.both,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  const SizedBox(height: 20),

                                  // Status
                                  FormBuilderDropdown<String>(
                                    name: 'status',
                                    decoration: InputDecoration(
                                      labelText: 'Status',
                                      filled: true,
                                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18)
                                    ),
                                    initialValue: _existingVisit?.status ?? 'Pending',
                                    validator: FormBuilderValidators.required(),
                                    items: const [
                                      DropdownMenuItem(value: 'Pending', child: Text('Pending', style: TextStyle(color: Colors.black))),
                                      DropdownMenuItem(value: 'Completed', child: Text('Completed', style: TextStyle(color: Colors.black))),
                                      DropdownMenuItem(value: 'Cancelled', child: Text('Cancelled', style: TextStyle(color: Colors.black))),
                                    ],
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  const SizedBox(height: 20),

                                  // Location
                                  FormBuilderTextField(
                                    name: 'location',
                                    decoration: InputDecoration(
                                      labelText: 'Location',
                                      filled: true,
                                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18)
                                    ),
                                    initialValue: _existingVisit?.location,
                                    validator: FormBuilderValidators.required(),
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: FormBuilderTextField(
                                          name: 'gps_location',
                                          decoration: InputDecoration(
                                            labelText: 'GPS Coordinates',
                                            filled: true,
                                            fillColor: Theme.of(context).colorScheme.surfaceVariant,
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18)
                                          ),
                                          initialValue: _gpsLocation,
                                          enabled: false,
                                          style: const TextStyle(color: Colors.black),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        onPressed: _gettingLocation ? null : _getCurrentLocation,
                                        icon: const Icon(Icons.my_location),
                                        label: Text(_gettingLocation ? 'Getting...' : 'Use My Location'),
                                        style: ElevatedButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),

                                  // Activities
                                  BlocBuilder<ActivitiesBloc, ActivitiesState>(
                                    builder: (context, state) {
                                      if (state is ActivitiesLoaded) {
                                        return FormBuilderCheckboxGroup<int>(
                                          name: 'activities_done',
                                          decoration: InputDecoration(
                                            labelText: 'Activities Completed',
                                            filled: true,
                                            fillColor: Theme.of(context).colorScheme.surfaceVariant,
                                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18)
                                          ),
                                          initialValue: _existingVisit?.activitiesDone ?? [],
                                          options: state.activities
                                              .map((activity) => FormBuilderFieldOption(
                                                    value: activity.id!,
                                                    child: Text(activity.description, style: const TextStyle(color: Colors.black)),
                                                  ))
                                              .toList(),
                                          checkColor: Colors.black,
                                        );
                                      }
                                      return const Padding(
                                        padding: EdgeInsets.symmetric(vertical: 12),
                                        child: Center(child: CircularProgressIndicator()),
                                      );
                                    },
                                  ),
                                  const SizedBox(height: 20),

                                  // Notes
                                  FormBuilderTextField(
                                    name: 'notes',
                                    decoration: InputDecoration(
                                      labelText: 'Notes',
                                      filled: true,
                                      fillColor: Theme.of(context).colorScheme.surfaceVariant,
                                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18)
                                    ),
                                    initialValue: _existingVisit?.notes,
                                    maxLines: 4,
                                    style: const TextStyle(color: Colors.black),
                                  ),
                                  const SizedBox(height: 28),

                                  // Save Button
                                  SizedBox(
                                    width: double.infinity,
                                    child: ElevatedButton.icon(
                                      onPressed: _saveVisit,
                                      icon: Icon(isEditing ? Icons.save : Icons.add),
                                      label: Padding(
                                        padding: const EdgeInsets.all(16),
                                        child: Text(isEditing ? 'Update Visit' : 'Create Visit'),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        textStyle: theme.textTheme.titleMedium,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }

  void _saveVisit() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData = _formKey.currentState!.value;

      final visit = Visit(
        id: _existingVisit?.id,
        customerId: formData['customer_id'] as int,
        visitDate: formData['visit_date'] as DateTime,
        status: formData['status'] as String,
        location: formData['location'] as String,
        notes: formData['notes'] as String?,
        activitiesDone: (formData['activities_done'] as List<int>?) ?? [],
        createdAt: _existingVisit?.createdAt ?? DateTime.now(),
        isSynced: _existingVisit?.isSynced ?? false,
        localId: _existingVisit?.localId,
        gpsLocation: _gpsLocation,
      );

      // Schedule notification if reminder is set
      final DateTime? reminder = formData['reminder'] as DateTime?;
      if (reminder != null && reminder.isAfter(DateTime.now())) {
        if (scheduleVisitReminderNotification != null) {
          scheduleVisitReminderNotification(
            visit.id ?? DateTime.now().millisecondsSinceEpoch,
            'Visit at ${visit.location}',
            reminder,
          );
        }
      }

      if (widget.visitId != null) {
        context.read<VisitsBloc>().add(UpdateVisitEvent(visit));
      } else {
        context.read<VisitsBloc>().add(CreateVisitEvent(visit));
      }
    }
  }

  void _getCurrentLocation() async {
    setState(() => _gettingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.deniedForever || permission == LocationPermission.denied) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied.')),
        );
        setState(() => _gettingLocation = false);
        return;
      }
      final position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      final coords = '${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
      setState(() {
        _gpsLocation = coords;
        _gettingLocation = false;
      });
      _formKey.currentState?.fields['gps_location']?.didChange(coords);
    } catch (e) {
      setState(() => _gettingLocation = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to get location: $e')),
      );
    }
  }
}
