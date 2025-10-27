import 'package:equatable/equatable.dart';

class Device extends Equatable {
  final String id;
  final String deviceId;
  final String name;
  final String topicSensor;
  final String topicWatering;
  final String action;
  final int duration;

  const Device({
    this.id = '',
    this.deviceId = '',
    this.name = '',
    this.topicSensor = '',
    this.topicWatering = '',
    this.action = '',
    this.duration = 0,
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json['id'] ?? '',
        deviceId: json['deviceId'] ?? '',
        name: json['name'] ?? '',
        topicSensor: json['topicSensor'] ?? '',
        topicWatering: json['topicWatering'] ?? '',
        action: json['action'] ?? '',
        duration: json['duration'] ?? 0,
      );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'deviceId': deviceId,
      'name': name,
      'topicSensor': topicSensor,
      'topicWatering': topicWatering,
      'action': action,
      'duration': duration
    };
  }

  @override
  List<Object?> get props => [id, deviceId, name, topicSensor, topicWatering, action, duration];
}