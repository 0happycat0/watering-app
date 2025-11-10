import 'package:equatable/equatable.dart';

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
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
    id: json['id'] ?? '',
    deviceId: json['deviceId'] ?? '',
    name: json['name'] ?? '',
    topicSensor: json['topicSensor'] ?? '',
    topicWatering: json['topicWatering'] ?? '',
    action: json['action'] ?? '',
    duration: (json['duration'] ?? 0) ~/ 60,
    online: json['online'] ?? true,
    watering: json['watering'] ?? false,
  );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'deviceId': deviceId,
      'name': name,
      'topicSensor': topicSensor,
      'topicWatering': topicWatering,
      'action': action,
      'duration': duration * 60,
      'online': online,
      'watering': watering,
    };
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
  ];
}
