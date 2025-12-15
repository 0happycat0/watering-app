import 'package:equatable/equatable.dart';
import 'package:watering_app/core/data/models/schedule_model.dart';

class Device extends Equatable {
  final String id;
  final String deviceId;
  final String name;
  final String topicSensor;
  final String topicWatering;
  final String action;
  final int duration;
  final bool online;
  final bool watering;
  final Schedule? nextSchedule;

  const Device({
    this.id = '',
    this.deviceId = '',
    this.name = '',
    this.topicSensor = '',
    this.topicWatering = '',
    this.action = '',
    this.duration = 0,
    this.online = true,
    this.watering = false,
    this.nextSchedule,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    id: json['id'] ?? '',
    deviceId: json['deviceId'] ?? '',
    name: json['name'] ?? '',
    topicSensor: json['topicSensor'] ?? '',
    topicWatering: json['topicWatering'] ?? '',
    action: json['action'] ?? '',
    duration: json['duration'] ?? 0,
    online: json['online'] ?? true,
    watering: json['watering'] ?? false,
    nextSchedule: json['nextSchedule'] != null
        ? Schedule.fromJson(json['nextSchedule'])
        : null,
  );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'deviceId': deviceId,
      'name': name,
      'topicSensor': topicSensor,
      'topicWatering': topicWatering,
      'action': action,
      'duration': duration,
      'online': online,
      'watering': watering,
      'nextSchedule': nextSchedule,
    };
  }

  Device copyWith({
    String? id,
    String? deviceId,
    String? name,
    String? topicSensor,
    String? topicWatering,
    String? action,
    int? duration,
    bool? online,
    bool? watering,
    Schedule? nextSchedule,
  }) {
    return Device(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      name: name ?? this.name,
      topicSensor: topicSensor ?? this.topicSensor,
      topicWatering: topicWatering ?? this.topicWatering,
      action: action ?? this.action,
      duration: duration ?? this.duration,
      online: online ?? this.online,
      watering: watering ?? this.watering,
      nextSchedule: nextSchedule ?? this.nextSchedule,
    );
  }

  @override
  List<Object?> get props => [
    id,
    deviceId,
    name,
    topicSensor,
    topicWatering,
    action,
    duration,
    online,
    watering,
    nextSchedule,
  ];
}
