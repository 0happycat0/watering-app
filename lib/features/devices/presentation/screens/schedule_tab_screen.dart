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
import 'package:watering_app/theme/styles.dart';

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
        return EditScheduleSheet(id: widget.device.id, schedule: schedule);
      },
    );
  }

  void _toggleSchedule(bool newState, Schedule schedule) async {
    final success = await ref
        .read(getListScheduleProvider.notifier)
        .toggleSchedule(
          id: widget.device.id,
          scheduleToToggle: schedule,
          newStatus: newState,
        );
    if (!success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(text: 'Đặt lịch thất bại.'),
      );
    }
  }

  void _showAskDeleteDialog(Schedule schedule) {
    final deleteScheduleNotifier = ref.read(deleteScheduleProvider.notifier);
    final listScheduleNotifier = ref.read(getListScheduleProvider.notifier);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Xóa lịch'),
        content: Text(
          'Bạn có muốn xóa lịch này không?',
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              listScheduleNotifier.setLoading();
              await deleteScheduleNotifier.deleteSchedule(
                id: widget.device.id,
                scheduleId: schedule.id,
              );
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(CustomSnackBar(text: 'Đã xóa lịch'));
              }
              listScheduleNotifier.refresh(id: widget.device.id);
            },
            child: Text('Xóa'),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if(!mounted) return;
      await ref
          .read(getListScheduleProvider.notifier)
          .getListSchedule(id: widget.device.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.device.id;
    final scheduleState = ref.watch(getListScheduleProvider);

    ref.watch(deleteScheduleProvider);

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
          color: AppColors.primarySurface,
          child: scheduleState is device_state.Loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : scheduleState is device_state.Success
              ? (listSchedule.isNotEmpty)
                    ? RefreshIndicator(
                        displacement: 30,
                        onRefresh: () async {
                          await ref
                              .read(getListScheduleProvider.notifier)
                              .refresh(id: id);
                        },
                        child: ListView.builder(
                          padding: EdgeInsets.only(top: 10, bottom: 100),
                          itemCount: listSchedule.length,
                          itemBuilder: (ctx, index) {
                            final schedule = listSchedule[index];
                            return ScheduleListItem(
                              schedule: schedule,
                              onToggle: (bool newState) async {
                                _toggleSchedule(newState, schedule);
                              },
                              onSelectEdit: () {
                                _showScheduleSheet(schedule);
                              },
                              onSelectDelete: () {
                                _showAskDeleteDialog(schedule);
                              },
                            );
                          },
                        ),
                      )
                    : Center(
                        child: Text(
                          'Chưa có lịch tưới',
                          style: TextStyle(fontSize: 16),
                        ),
                      )
              : scheduleState is device_state.Failure
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        scheduleState.message,
                        style: TextStyle(fontSize: 16),
                      ),
                      TextButton(
                        onPressed: () {
                          ref
                              .read(getListScheduleProvider.notifier)
                              .refresh(id: id);
                        },
                        style: AppStyles.textButtonStyle,
                        child: Text('Thử lại'),
                      ),
                    ],
                  ),
                )
              : Center(child: Text('Có lỗi xảy ra')),
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
