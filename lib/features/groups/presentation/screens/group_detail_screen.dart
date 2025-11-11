import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/icons/back_icon.dart';
import 'package:watering_app/features/groups/data/models/group_model.dart';
import 'package:watering_app/features/groups/providers/all_groups/groups_provider.dart';
import 'package:watering_app/features/groups/providers/group/group_provider.dart';
import 'package:watering_app/features/groups/providers/group/group_state.dart'
    as group_state;
import 'package:watering_app/features/groups/presentation/screens/group_control_tab_screen.dart';
import 'package:watering_app/features/groups/presentation/screens/group_schedule_tab_screen.dart';
import 'package:watering_app/features/groups/presentation/screens/group_devices_tab_screen.dart';
import 'package:watering_app/theme/theme.dart';

class GroupDetailScreen extends ConsumerStatefulWidget {
  const GroupDetailScreen({super.key, required this.group});

  final Group group;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupDetailScreenState();
}

class _GroupDetailScreenState extends ConsumerState<GroupDetailScreen> {
  Group? _currentGroup;

  void _showAskDeleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Consumer(
        builder: (context, ref, child) {
          final groupState = ref.watch(deleteGroupProvider);
          return AlertDialog(
            title: Text('Xóa nhóm'),
            content: Text(
              'Bạn có muốn xóa nhóm "${widget.group.name}" không?',
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
                  await ref
                      .read(deleteGroupProvider.notifier)
                      .deleteGroup(id: widget.group.id);
                  ref.read(groupsProvider.notifier).refresh();
                },
                child: groupState is group_state.Loading
                    ? CustomCircularProgress(
                        color: colorScheme.primaryContainer,
                      )
                    : Text('Xóa'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _currentGroup = widget.group;

    Future.microtask(() async {
      if (!mounted) return;
      await ref
          .read(groupByIdProvider.notifier)
          .getGroupById(id: widget.group.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupState = ref.watch(groupByIdProvider);

    // Cập nhật group khi có data mới
    if (groupState is group_state.Success && groupState.listDevices != null) {
      _currentGroup = Group(
        id: widget.group.id,
        name: widget.group.name,
        listDevices: groupState.listDevices!,
      );
    }

    ref.listen(deleteGroupProvider, (prev, next) {
      print(
        'Delete group transition: ${prev.runtimeType} -> ${next.runtimeType}',
      );
      if (next is group_state.Failure) {
        final message = next.message;
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(CustomSnackBar(text: message));
      }
      if (next is group_state.Success && prev is group_state.Loading) {
        Navigator.of(context).pop();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(
          CustomSnackBar(text: 'Đã xóa nhóm "${widget.group.name}"'),
        );
      }
    });

    return DefaultTabController(
      initialIndex: 0,
      length: 3,
      child: Scaffold(
        appBar: CustomAppBar(
          automaticallyImplyLeading: false,
          title: 'Nhóm: ${widget.group.name}',
          leading: BackIcon(),
          actions: [
            IconButton(
              onPressed: _showAskDeleteDialog,
              icon: Icon(
                Symbols.delete,
                size: 28,
              ),
            ),
          ],
          bottom: TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            unselectedLabelStyle: TextStyle(fontWeight: FontWeight.normal),
            tabs: <Widget>[
              Tab(text: 'Điều khiển'),
              Tab(text: 'Lên lịch'),
              Tab(text: 'Thiết bị'),
            ],
          ),
        ),
        body: TabBarView(
          children: <Widget>[
            GroupControlTabScreen(group: _currentGroup ?? widget.group),
            GroupScheduleTabScreen(group: _currentGroup ?? widget.group),
            GroupDevicesTabScreen(group: _currentGroup ?? widget.group),
          ],
        ),
      ),
    );
  }
}
