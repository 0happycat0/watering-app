import 'package:equatable/equatable.dart';
import 'package:watering_app/features/devices/data/enums/schedule_enums.dart';

class Schedule extends Equatable {
  final String id;
  final String startTime;
  final int duration;
  final RepeatType repeatType;
  final bool status;
  final List<DaysOfWeek>? daysOfWeek;

  const Schedule({
    this.id = '',
    this.startTime = '',
    this.duration = 0,
    this.repeatType = RepeatType.ONE_TIME,
    this.status = false,
    this.daysOfWeek,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    List<DaysOfWeek>? parsedDays;
    if (json['daysOfWeek'] != null && json['daysOfWeek'] is List) {
      parsedDays = (json['daysOfWeek'] as List)
          .map((dayString) {
            try {
              return DaysOfWeek.values.byName(dayString.toString());
            } catch (e) {
              return null; // Bỏ qua nếu string không hợp lệ
            }
          })
          .whereType<DaysOfWeek>()
          .toList();
    }

    RepeatType parsedRepeatType = RepeatType.ONE_TIME; // Default
    if (json['repeatType'] != null) {
      try {
        parsedRepeatType =
            RepeatType.values.byName(json['repeatType'].toString());
      } catch (e) {
        // Giữ giá trị default nếu string từ API không khớp
      }
    }
    return Schedule(
      id: json['id'] ?? '',
      startTime: json['startTime'] ?? '',
      duration: (json['duration'] ?? 0) ~/ 60,
      repeatType: parsedRepeatType,
      status: json['status'] ?? false,
      daysOfWeek: parsedDays,
    );
  }

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'id': id,
      'startTime': startTime,
      'duration': duration * 60,
      'repeatType': repeatType.name,
      'status': status,
      if (daysOfWeek != null)
        'daysOfWeek': daysOfWeek!.map((e) => e.name).toList(),
    };
  }

  Schedule copyWith({
    String? id,
    String? startTime,
    int? duration,
    RepeatType? repeatType,
    bool? status,
    List<DaysOfWeek>? daysOfWeek,
  }) {
    return Schedule(
      id: id ?? this.id,
      startTime: startTime ?? this.startTime,
      duration: duration ?? this.duration,
      repeatType: repeatType ?? this.repeatType,
      status: status ?? this.status,
      daysOfWeek: daysOfWeek ?? this.daysOfWeek,
    );
  }

  @override
  List<Object?> get props => [
    id,
    startTime,
    duration,
    repeatType,
    status,
    daysOfWeek,
  ];
}
