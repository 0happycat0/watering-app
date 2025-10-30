import 'package:equatable/equatable.dart';

enum HistorySensorSortField { timestamp, soil, air }

class HistorySensor extends Equatable {
  final double temp;
  final double air;
  final double soil;
  final DateTime? timestamp;

  const HistorySensor({
    this.temp = 0.0,
    this.air = 0.0,
    this.soil = 0.0,
    this.timestamp,
  });

  factory HistorySensor.fromJson(Map<String, dynamic> json) => HistorySensor(
    temp: (json['temp'] as num?)?.toDouble() ?? 0.0,
    air: (json['air'] as num?)?.toDouble() ?? 0.0,
    soil: (json['soil'] as num?)?.toDouble() ?? 0.0,
    timestamp: DateTime.tryParse(json['timestamp'] ?? ''),
  );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'temp': temp,
      'air': air,
      'soil': soil,
      'timestamp': timestamp?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [temp, air, soil, timestamp];
}
