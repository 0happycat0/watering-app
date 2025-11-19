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
  // Hàm tạo chuỗi ngày tháng tiếng Việt: "Thứ Ba, 18 tháng 11, 2025"
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

  @override
  Widget build(BuildContext context) {
    final devicesState = ref.watch(devicesProvider);
    final theme = Theme.of(context);

    final bool isLoading =
        devicesState is devices_state.Loading ||
        devicesState is devices_state.Initial;
    final bool isFailure = devicesState is devices_state.Failure;

    List<Device> devices = [];

    if (isLoading) {
      // Tạo dữ liệu giả để hiện skeleton loading
      devices = List.generate(
        8,
        (index) => Device(
          name: 'Tên thiết bị',
          nextSchedule: Schedule(
            duration: 20,
            startTime: '11:00:00',
            runAfter: 3600,
          ),
        ),
      );
    } else if (devicesState is devices_state.Success) {
      devices = devicesState.devicesList
          .where((device) => device.nextSchedule != null)
          .toList();
    }

    return Scaffold(
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
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await ref.read(devicesProvider.notifier).getAllDevices();
        },
        child: Skeletonizer(
          enabled: isLoading,
          child: devices.isEmpty && !isLoading
              ? _buildEmptyState(isFailure)
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: devices.length,
                  itemBuilder: (context, index) {
                    final device = devices[index];
                    return ScheduleItemCard(
                      onTap: () {
                        _onTapSchedule(device);
                      },
                      theme: theme,
                      device: device,
                    );
                  },
                ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(bool isFailure) {
    return Center(
      heightFactor: 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            isFailure ? Symbols.event_busy : Symbols.event_busy_rounded,
            size: isFailure ? 54 : 60,
            weight: 700,
            color: Colors.grey,
          ),
          SizedBox(height: 10),
          Text(
            isFailure ? 'Lỗi khi tải lịch tưới' : 'Không có lịch tưới sắp tới',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 18,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}
