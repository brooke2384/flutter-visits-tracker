import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/customer.dart';

part 'customer_model.g.dart';

@JsonSerializable()
class CustomerModel extends Customer {
  const CustomerModel({
    super.id,
    required super.name,
    required super.createdAt,
  });

  factory CustomerModel.fromJson(Map<String, dynamic> json) =>
      _$CustomerModelFromJson(json);

  Map<String, dynamic> toJson() => _$CustomerModelToJson(this);

  factory CustomerModel.fromEntity(Customer customer) {
    return CustomerModel(
      id: customer.id,
      name: customer.name,
      createdAt: customer.createdAt,
    );
  }
}
