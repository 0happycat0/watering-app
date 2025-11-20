import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/data/models/schedule_model.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';
import 'package:watering_app/core/widgets/icons/back_icon.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/presentation/screens/device_detail_screen.dart';
import 'package:watering_app/features/devices/providers/all_devices/devices_provider.dart';
import 'package:watering_app/features/devices/providers/all_devices/devices_state.dart'
    as devices_state;
import 'package:watering_app/features/groups/data/models/group_model.dart';
import 'package:watering_app/features/groups/presentation/screens/group_detail_screen.dart';
import 'package:watering_app/features/groups/providers/all_groups/groups_provider.dart';
import 'package:watering_app/features/groups/providers/all_groups/groups_state.dart'
    as groups_state;
import 'package:watering_app/features/home/presentation/widgets/schedule_item_card.dart';
import 'package:material_symbols_icons/symbols.dart';

class IncomingScheduleScreen extends ConsumerStatefulWidget {
  const IncomingScheduleScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _IncomingScheduleScreenState();
}

class _IncomingScheduleScreenState
    extends ConsumerState<IncomingScheduleScreen> {
  // Hàm tạo chuỗi ngày tháng tiếng Việt
  String _getVietnameseDate() {
    final now = DateTime.now();
    final List<String> weekdays = [
      '',
      'Thứ Hai',
      'Thứ Ba',
      'Thứ Tư',
      'Thứ Năm',
      'Thứ Sáu',
      'Thứ Bảy',
      'Chủ Nhật',
    ];

    String dayOfWeek = weekdays[now.weekday];
    String day = now.day.toString();
    String month = now.month.toString();
    String year = now.year.toString();

    return '$dayOfWeek, $day tháng $month, $year';
  }

  void _onTapSchedule(Device device) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (ctx) =>
            DeviceDetailScreen(device: device, isNavigetedFromHome: true),
      ),
    );
  }

  void _onTapGroupSchedule(Group group) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (ctx) =>
            GroupDetailScreen(group: group, isNavigetedFromHome: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final devicesState = ref.watch(devicesProvider);
    final groupsState = ref.watch(groupsProvider);
    final theme = Theme.of(context);

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.primarySurface,
        appBar: CustomAppBar(
          backgroundColor: AppColors.mainGreen[200],
          foregroundColor: Colors.white,
          leading: BackIcon(color: Colors.white),
          title: 'Lịch tưới sắp tới',
          subTitle: _getVietnameseDate(),
          subTitleHeight: 20,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarBrightness: Brightness.light,
            systemNavigationBarColor: Colors.transparent,
          ),
          bottom: const TabBar(
            indicatorSize: TabBarIndicatorSize.tab,
            indicatorWeight: 3,
            indicatorColor: Colors.white,
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            unselectedLabelStyle: TextStyle(
              fontWeight: FontWeight.normal,
              fontSize: 16,
            ),
            tabs: <Widget>[
              Tab(text: 'Theo thiết bị'),
              Tab(text: 'Theo nhóm'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildList(
              state: devicesState,
              isGroup: false,
              theme: theme,
              onRefresh: () async {
                await ref.read(devicesProvider.notifier).getAllDevices();
              },
            ),
            _buildList(
              state: groupsState,
              isGroup: true,
              theme: theme,
              onRefresh: () async {
                await ref.read(groupsProvider.notifier).getAllGroups();
              },
            ),
          ],
        ),
      ),
    );
  }

  // Hàm chung để build danh sách cho cả Device và Group
  Widget _buildList({
    required dynamic state,
    required bool isGroup,
    required ThemeData theme,
    required Future<void> Function() onRefresh,
  }) {
    final bool isLoading = isGroup
        ? (state is groups_state.Loading || state is groups_state.Initial)
        : (state is devices_state.Loading || state is devices_state.Initial);

    final bool isFailure = isGroup
        ? (state is groups_state.Failure)
        : (state is devices_state.Failure);

    List<dynamic> items = [];

    if (isLoading) {
      // Tạo dữ liệu giả Skeleton
      items = List.generate(8, (index) {
        if (isGroup) {
          return Group(
            name: 'Tên nhóm giả định',
            nextSchedule: Schedule(
              duration: 20,
              startTime: '11:00:00',
              runAfter: 3600,
            ),
          );
        } else {
          return Device(
            name: 'Tên thiết bị giả định',
            nextSchedule: Schedule(
              duration: 20,
              startTime: '11:00:00',
              runAfter: 3600,
            ),
          );
        }
      });
    } else if (isFailure) {
      items = [];
    } else {
      if (isGroup && state is groups_state.Success) {
        items = state.groupsList
            .where((group) => group.nextSchedule != null)
            .toList();
      } else if (!isGroup && state is devices_state.Success) {
        items = state.devicesList
            .where((device) => device.nextSchedule != null)
            .toList();
      }
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: Skeletonizer(
        enabled: isLoading,
        child: items.isEmpty && !isLoading
            ? _buildEmptyState(isFailure, isGroup)
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: items.length,
                itemBuilder: (context, index) {
                  final item = items[index];
                  return ScheduleItemCard(
                    onTap: () {
                      if (isGroup) {
                        _onTapGroupSchedule(item);
                      } else {
                        _onTapSchedule(item);
                      }
                    },
                    theme: theme,
                    device: isGroup ? null : item,
                    group: isGroup ? item : null,
                  );
                },
              ),
      ),
    );
  }

  Widget _buildEmptyState(bool isFailure, bool isGroupSelected) {
    String message;
    if (isFailure) {
      message = isGroupSelected
          ? 'Lỗi khi tải lịch tưới nhóm'
          : 'Lỗi khi tải lịch tưới thiết bị';
    } else {
      message = isGroupSelected
          ? 'Không có lịch tưới nhóm sắp tới'
          : 'Không có lịch tưới thiết bị sắp tới';
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: constraints.maxHeight,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    isFailure
                        ? Symbols.error_circle_rounded
                        : Symbols.event_busy_rounded,
                    size: isFailure ? 54 : 60,
                    weight: 700,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 10),
                  Text(
                    message,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
