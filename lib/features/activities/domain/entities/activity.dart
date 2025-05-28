import 'package:equatable/equatable.dart';

class Activity extends Equatable {
  final int? id;
  final String description;
  final DateTime createdAt;

  const Activity({
    this.id,
    required this.description,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, description, createdAt];
}
