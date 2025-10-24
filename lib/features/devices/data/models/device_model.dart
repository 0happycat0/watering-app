import 'package:equatable/equatable.dart';

class Device extends Equatable {
  final String id;
  final String deviceId;
  final String name;
  final String topicSensor;
  final String topicWatering;

  const Device({
    this.id = '',
    this.deviceId = '',
    this.name = '',
    this.topicSensor = '',
    this.topicWatering = '',
  });

  factory Device.fromJson(Map<String, dynamic> json) => Device(
        id: json['id'] ?? '',
        deviceId: json['deviceId'] ?? '',
        name: json['name'] ?? '',
        topicSensor: json['topicSensor'] ?? '',
        topicWatering: json['topicWatering'] ?? '',
      );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'deviceId': deviceId,
      'name': name,
      'topicSensor': topicSensor,
      'topicWatering': topicWatering,
    };
  }

  @override
  List<Object?> get props => [id, deviceId, name, topicSensor, topicWatering];
}