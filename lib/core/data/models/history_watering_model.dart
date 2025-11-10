import 'package:equatable/equatable.dart';

class HistoryWatering extends Equatable {
  final String action;
  final int duration;
  final DateTime? startTime;
  final bool? byGroup;

  const HistoryWatering({
    this.action = '',
    this.duration = 0,
    this.startTime,
    this.byGroup,
  });

  factory HistoryWatering.fromJson(Map<String, dynamic> json) =>
      HistoryWatering(
        action: json['action'] ?? '',
        duration: (json['duration'] ?? 0) ~/ 60,
        startTime: DateTime.tryParse(json['startTime'] ?? ''),
        byGroup: json['byGroup'],
      );

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'action': action,
      'duration': duration * 60,
      'startTime': startTime?.toIso8601String(),
      'byGroup': byGroup,
    };
  }

  @override
  List<Object?> get props => [action, duration, startTime, byGroup];
}
