import 'package:equatable/equatable.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';

class Group extends Equatable {
  final String id;
  final String name;
  final List<Device> listDevices;

  const Group({
    this.id = '',
    this.name = '',
    this.listDevices = const [],
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    listDevices: json['devices'] != null
        ? (json['devices'] as List)
            .map((deviceJson) => Device.fromJson(deviceJson))
            .toList()
        : [],
  );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'devices': listDevices.map((device) => device.toJson()).toList(),
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    listDevices,
  ];
}

