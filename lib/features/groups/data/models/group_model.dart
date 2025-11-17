import 'package:equatable/equatable.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';

class Group extends Equatable {
  final String id;
  final String name;
  final int devicesQuantity;
  final List<Device> listDevices;
  final String action;
  final int duration;
  final bool watering;

  const Group({
    this.id = '',
    this.name = '',
    this.devicesQuantity = 0,
    this.listDevices = const [],
    this.action = '',
    this.duration = 0,
    this.watering = false,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    devicesQuantity: json['devicesQuantity'] ?? 0,
    listDevices: json['devices'] != null
        ? (json['devices'] as List)
              .map((deviceJson) => Device.fromJson(deviceJson))
              .toList()
        : [],
    action: json['action'] ?? '',
    duration: (json['duration'] ?? 0) ~/ 60,
    watering: json['watering'] ?? false,
  );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'devicesQuantity': devicesQuantity,
      'devices': listDevices.map((device) => device.toJson()).toList(),
      'action': action,
      'duration': duration * 60,
      'watering': watering,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    devicesQuantity,
    listDevices,
    action,
    duration,
    watering,
  ];
}
