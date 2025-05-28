import 'package:equatable/equatable.dart';

class Visit extends Equatable {
  final int? id;
  final int customerId;
  final DateTime visitDate;
  final String status;
  final String location;
  final String? notes;
  final List<int> activitiesDone;
  final DateTime createdAt;
  final bool isSynced;
  final String? localId;
  final String? gpsLocation;

  const Visit({
    this.id,
    required this.customerId,
    required this.visitDate,
    required this.status,
    required this.location,
    this.notes,
    required this.activitiesDone,
    required this.createdAt,
    this.isSynced = false,
    this.localId,
    this.gpsLocation,
  });

  Visit copyWith({
    int? id,
    int? customerId,
    DateTime? visitDate,
    String? status,
    String? location,
    String? notes,
    List<int>? activitiesDone,
    DateTime? createdAt,
    bool? isSynced,
    String? localId,
    String? gpsLocation,
  }) {
    return Visit(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      visitDate: visitDate ?? this.visitDate,
      status: status ?? this.status,
      location: location ?? this.location,
      notes: notes ?? this.notes,
      activitiesDone: activitiesDone ?? this.activitiesDone,
      createdAt: createdAt ?? this.createdAt,
      isSynced: isSynced ?? this.isSynced,
      localId: localId ?? this.localId,
      gpsLocation: gpsLocation ?? this.gpsLocation,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        visitDate,
        status,
        location,
        notes,
        activitiesDone,
        createdAt,
        isSynced,
        localId,
        gpsLocation,
      ];
}
