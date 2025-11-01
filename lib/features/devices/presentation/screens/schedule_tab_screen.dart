import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/data/models/schedule_model.dart';
import 'package:watering_app/features/devices/presentation/widgets/edit_schedule_sheet.dart';
import 'package:watering_app/features/devices/presentation/widgets/schedule_list_item.dart';
import 'package:watering_app/features/devices/providers/device/schedule_provider.dart';
import 'package:watering_app/features/devices/providers/device/device_state.dart'
    as device_state;

class ScheduleTabScreen extends ConsumerStatefulWidget {
  const ScheduleTabScreen({super.key, required this.device});

  final Device device;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ScheduleTabScreenState();
}

class _ScheduleTabScreenState extends ConsumerState<ScheduleTabScreen> {
  // final mockData = [
  //   Schedule(
  //     id: '1',
  //     startTime: '07:00',
  //     duration: 15, // 15 phút
  //     repeatType: RepeatType.DAYS,
  //     status: true,
  //     daysOfWeek: [
  //       DaysOfWeek.MON, // T2
  //       DaysOfWeek.TUE, // T3
  //       DaysOfWeek.WED, // T4
  //       DaysOfWeek.THU, // T5
  //       DaysOfWeek.FRI, // T6
  //     ],
  //   ),
  //   Schedule(
  //     id: '2',
  //     startTime: '18:30',
  //     duration: 5, // 5 phút
  //     repeatType: RepeatType.EVERYDAY,
  //     status: false,
  //     daysOfWeek: null, // Sẽ không có ngày nào sáng
  //   ),
  //   Schedule(
  //     id: '3',
  //     startTime: '12:00',
  //     duration: 10, // 10 phút
  //     repeatType: RepeatType.DAYS,
  //     status: true,
  //     daysOfWeek: [
  //       DaysOfWeek.SAT, // T7
  //       DaysOfWeek.SUN, // CN
  //     ],
  //   ),
  //   Schedule(
  //     id: '4',
  //     startTime: '09:15',
  //     duration: 2, // 2 phút
  //     repeatType: RepeatType.ONE_TIME,
  //     status: true,
  //     daysOfWeek: [], // Mảng rỗng
  //   ),
  // ];

  void _showScheduleSheet(Schedule? schedule) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.white,
      builder: (ctx) {
        return EditScheduleSheet(schedule: schedule);
      },
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      await ref
          .read(getListScheduleProvider.notifier)
          .getListSchedule(id: widget.device.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.device.id;
    final scheduleState = ref.watch(getListScheduleProvider);
    ref.listen(getListScheduleProvider, (prev, next) {
      print(
        'Schedule list transition: ${prev.runtimeType} -> ${next.runtimeType}',
      );
    });
    late List<Schedule> listSchedule;

    if (scheduleState is device_state.Success) {
      listSchedule = scheduleState.listSchedule ?? [];
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          color: AppColors.mainGreen[50]!,
          child: scheduleState is device_state.Loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : scheduleState is device_state.Success
              ? (listSchedule.isNotEmpty)
                    ? ListView.builder(
                        padding: EdgeInsets.only(top: 10, bottom: 100),
                        itemCount: listSchedule.length,
                        itemBuilder: (ctx, index) {
                          final schedule = listSchedule[index];
                          return ScheduleListItem(
                            schedule: schedule,
                            onToggle: (bool newState) async {
                              final success = await ref
                                  .read(getListScheduleProvider.notifier)
                                  .toggleSchedule(
                                    deviceId: widget.device.id,
                                    scheduleToToggle: schedule,
                                    newStatus: newState,
                                  );
                              if (!success && context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  CustomSnackBar(text: 'Đặt lịch thất bại.'),
                                );
                              }
                            },
                            onSelectEdit: () {
                              _showScheduleSheet(schedule);
                            },
                            onSelectDelete: () {
                              print('Delete schedule ${schedule.id}');
                            },
                          );
                        },
                      )
                    : Center(
                        child: Text(
                          'Chưa có lịch tưới',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
              : Center(
                  child: Text(
                    'Lỗi khi tải lịch tưới',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
        ),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.white.withAlpha(210),
                blurRadius: 40,
                spreadRadius: 10,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.mainGreen[200],
                foregroundColor: Colors.white,
                textStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                _showScheduleSheet(null);
              },
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Thêm Lịch'),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
