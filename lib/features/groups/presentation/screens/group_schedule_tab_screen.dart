import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/features/groups/data/models/group_model.dart';
import 'package:watering_app/core/data/models/schedule_model.dart';
import 'package:watering_app/core/widgets/edit_schedule_sheet.dart';
import 'package:watering_app/core/widgets/schedule_list_item.dart';
import 'package:watering_app/features/groups/providers/group/schedule_provider.dart';
import 'package:watering_app/features/groups/providers/group/group_state.dart'
    as group_state;
import 'package:watering_app/theme/styles.dart';

class GroupScheduleTabScreen extends ConsumerStatefulWidget {
  const GroupScheduleTabScreen({super.key, required this.group});

  final Group group;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupScheduleTabScreenState();
}

class _GroupScheduleTabScreenState
    extends ConsumerState<GroupScheduleTabScreen> {
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
        return EditScheduleSheet(
          id: widget.group.id,
          schedule: schedule,
          isGroup: true, // Đánh dấu là group
        );
      },
    );
  }

  void _toggleSchedule(bool newState, Schedule schedule) async {
    final success = await ref
        .read(getGroupListScheduleProvider.notifier)
        .toggleSchedule(
          id: widget.group.id,
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
    final deleteScheduleNotifier = ref.read(
      deleteGroupScheduleProvider.notifier,
    );
    final listScheduleNotifier = ref.read(
      getGroupListScheduleProvider.notifier,
    );

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
                id: widget.group.id,
                scheduleId: schedule.id,
              );
              if (mounted) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(CustomSnackBar(text: 'Đã xóa lịch'));
              }
              listScheduleNotifier.refresh(id: widget.group.id);
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
      if (!mounted) return;
      await ref
          .read(getGroupListScheduleProvider.notifier)
          .getListSchedule(id: widget.group.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.group.id;
    final scheduleState = ref.watch(getGroupListScheduleProvider);

    ref.watch(createGroupScheduleProvider);
    ref.watch(updateGroupScheduleProvider);
    ref.watch(deleteGroupScheduleProvider);

    ref.listen(getGroupListScheduleProvider, (prev, next) {
      print(
        'Schedule list transition: ${prev.runtimeType} -> ${next.runtimeType}',
      );
    });
    late List<Schedule> listSchedule;

    if (scheduleState is group_state.Success) {
      listSchedule = scheduleState.listSchedule ?? [];
    }

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          color: AppColors.primarySurface,
          child: scheduleState is group_state.Loading
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : scheduleState is group_state.Success
              ? (listSchedule.isNotEmpty)
                    ? RefreshIndicator(
                        displacement: 30,
                        onRefresh: () async {
                          await ref
                              .read(getGroupListScheduleProvider.notifier)
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
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Symbols.schedule,
                              size: 60,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Chưa có lịch tưới',
                              style: TextStyle(fontSize: 16),
                            ),
                          ],
                        ),
                      )
              : scheduleState is group_state.Failure
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
                              .read(getGroupListScheduleProvider.notifier)
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
