import 'package:equatable/equatable.dart';
import 'package:watering_app/core/data/models/schedule_model.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';

class Group extends Equatable {
  final String id;
  final String name;
  final int devicesQuantity;
  final List<Device> listDevices;
  final String action;
  final int duration;
  final bool watering;
    final Schedule? nextSchedule;


  const Group({
    this.id = '',
    this.name = '',
    this.devicesQuantity = 0,
    this.listDevices = const [],
    this.action = '',
    this.duration = 0,
    this.watering = false,
    this.nextSchedule,
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
    duration: json['duration'] ?? 0,
    watering: json['watering'] ?? false,
    nextSchedule: json['nextSchedule'] != null
        ? Schedule.fromJson(json['nextSchedule'])
        : null,
  );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'devicesQuantity': devicesQuantity,
      'devices': listDevices.map((device) => device.toJson()).toList(),
      'action': action,
      'duration': duration,
      'watering': watering,
      'nextSchedule': nextSchedule,
    };
  }

  Group copyWith({
    String? id,
    String? name,
    int? devicesQuantity,
    List<Device>? listDevices,
    String? action,
    int? duration,
    bool? watering,
    Schedule? nextSchedule,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      devicesQuantity: devicesQuantity ?? this.devicesQuantity,
      listDevices: listDevices ?? this.listDevices,
      action: action ?? this.action,
      duration: duration ?? this.duration,
      watering: watering ?? this.watering,
      nextSchedule: nextSchedule ?? this.nextSchedule,
    );
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
    nextSchedule,
  ];
}
