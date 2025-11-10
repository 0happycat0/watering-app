import 'package:equatable/equatable.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';

class Group extends Equatable {
  final String id;
  final String name;
  final List<Device> listDevices;
  final String action;
  final int duration; 

  const Group({
    this.id = '',
    this.name = '',
    this.listDevices = const [],
    this.action = '',
    this.duration = 0,
  });

  factory Group.fromJson(Map<String, dynamic> json) => Group(
    id: json['id'] ?? '',
    name: json['name'] ?? '',
    listDevices: json['devices'] != null
        ? (json['devices'] as List)
            .map((deviceJson) => Device.fromJson(deviceJson))
            .toList()
        : [],
    action: json['action'] ?? '',
    duration: (json['duration'] ?? 0) ~/ 60,
  );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'devices': listDevices.map((device) => device.toJson()).toList(),
      'action': action,
      'duration': duration * 60,
    };
  }

  @override
  List<Object?> get props => [
    id,
    name,
    listDevices,
    action,
    duration,
  ];
}

