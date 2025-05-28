import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/visit.dart';

part 'visit_model.g.dart';

@JsonSerializable()
class VisitModel extends Visit {
  const VisitModel({
    super.id,
    required super.customerId,
    required super.visitDate,
    required super.status,
    required super.location,
    super.notes,
    required super.activitiesDone,
    required super.createdAt,
    super.isSynced = false,
    super.localId,
    super.gpsLocation,
  });

  factory VisitModel.fromJson(Map<String, dynamic> json) {
    // Handle activities_done conversion from string array to int array, or null
    List<int> activitiesDone = [];
    final rawActivities = json['activities_done'];
    if (rawActivities != null) {
      if (rawActivities is List) {
        activitiesDone = rawActivities.whereType<int>().toList();
        // If the list is not int, try parsing
        if (activitiesDone.isEmpty && rawActivities.isNotEmpty) {
          activitiesDone = rawActivities.map((e) => int.tryParse(e.toString()) ?? 0).toList();
        }
      } else if (rawActivities is String && rawActivities.isNotEmpty) {
        activitiesDone = rawActivities.split(',').map((e) => int.tryParse(e.trim()) ?? 0).toList();
      }
    }

    DateTime? createdAt;
    if (json['created_at'] != null && json['created_at'] is String) {
      createdAt = DateTime.tryParse(json['created_at']);
    }

    return VisitModel(
      id: json['id'] as int?,
      customerId: json['customer_id'] as int,
      visitDate: DateTime.parse(json['visit_date'] as String),
      status: json['status'] as String,
      location: json['location'] as String,
      notes: json['notes'] as String?,
      activitiesDone: activitiesDone,
      createdAt: createdAt ?? DateTime.now(),
      isSynced: json['is_synced'] == 1,
      localId: json['local_id'] as String?,
      gpsLocation: json['gps_location'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'visit_date': visitDate.toIso8601String(),
      'status': status,
      'location': location,
      'notes': notes,
      'activities_done': activitiesDone.map((e) => e.toString()).toList(),
      'created_at': createdAt?.toIso8601String(),
      'gps_location': gpsLocation,
    };
  }

  Map<String, dynamic> toLocalJson() {
    return {
      'id': id,
      'customer_id': customerId,
      'visit_date': visitDate.toIso8601String(),
      'status': status,
      'location': location,
      'notes': notes,
      'activities_done': activitiesDone.join(','),
      'created_at': createdAt?.toIso8601String(),
      'is_synced': isSynced ? 1 : 0,
      'local_id': localId,
      'gps_location': gpsLocation,
    };
  }

  factory VisitModel.fromLocalJson(Map<String, dynamic> json) {
    List<int> activitiesDone = [];
    if (json['activities_done'] != null && json['activities_done'] is String && (json['activities_done'] as String).isNotEmpty) {
      activitiesDone = (json['activities_done'] as String)
          .split(',')
          .map((e) => int.tryParse(e) ?? 0)
          .toList();
    }
    DateTime? createdAt;
    if (json['created_at'] != null && json['created_at'] is String) {
      createdAt = DateTime.tryParse(json['created_at']);
    }
    int? id;
    if (json['id'] is int) {
      id = json['id'] as int;
    } else if (json['id'] is String) {
      id = int.tryParse(json['id']);
    }
    return VisitModel(
      id: id,
      customerId: json['customer_id'] as int,
      visitDate: DateTime.parse(json['visit_date'] as String),
      status: json['status'] as String,
      location: json['location'] as String,
      notes: json['notes'] as String?,
      activitiesDone: activitiesDone,
      createdAt: createdAt ?? DateTime.now(),
      isSynced: json['is_synced'] == 1,
      localId: json['local_id'] as String?,
      gpsLocation: json['gps_location'] as String?,
    );
  }

  factory VisitModel.fromEntity(Visit visit) {
    return VisitModel(
      id: visit.id,
      customerId: visit.customerId,
      visitDate: visit.visitDate,
      status: visit.status,
      location: visit.location,
      notes: visit.notes,
      activitiesDone: visit.activitiesDone,
      createdAt: visit.createdAt,
      isSynced: visit.isSynced,
      localId: visit.localId,
      gpsLocation: visit.gpsLocation,
    );
  }
}
