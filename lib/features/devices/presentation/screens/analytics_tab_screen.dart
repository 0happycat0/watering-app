import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/data/models/history_sensor_model.dart';
import 'package:watering_app/features/devices/providers/device/get_history_provider.dart';
import 'package:watering_app/features/devices/providers/device/device_state.dart'
    as device_state;
import 'package:watering_app/theme/theme.dart';

class AnalyticsTabScreen extends ConsumerStatefulWidget {
  const AnalyticsTabScreen({super.key, required this.device});

  final Device device;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      AnalyticsTabScreenState();
}

class AnalyticsTabScreenState extends ConsumerState<AnalyticsTabScreen> {
  late TrackballBehavior _tempTrackballBehavior;
  late TrackballBehavior _soilTrackballBehavior;
  late TrackballBehavior _airTrackballBehavior;
  late ZoomPanBehavior _tempZoomPanBehavior;
  late ZoomPanBehavior _soilZoomPanBehavior;
  late ZoomPanBehavior _airZoomPanBehavior;

  ChartAxisLabel _formatAxisLabel(AxisLabelRenderDetails args) {
    // Lấy giá trị DateTime từ args
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(
      args.value.toInt(),
    );
    // Định dạng lại với dấu xuống dòng
    final String formattedText = DateFormat('HH:mm\ndd/MM').format(date);
    // Trả về AxisLabel mới
    return ChartAxisLabel(formattedText, args.textStyle);
  }

  @override
  void initState() {
    super.initState();

    _tempTrackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipSettings: InteractiveTooltip(
        format: 'point.x: point.y°C',
        canShowMarker: false,
      ),
    );
    _soilTrackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipSettings: InteractiveTooltip(
        format: 'point.x: point.y%',
        canShowMarker: false,
      ),
      tooltipAlignment: ChartAlignment.center,
    );
    _airTrackballBehavior = TrackballBehavior(
      enable: true,
      activationMode: ActivationMode.singleTap,
      tooltipSettings: InteractiveTooltip(
        format: 'point.x: point.y%',
        canShowMarker: false,
      ),
    );

    _tempZoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enablePinching: true,
      zoomMode: ZoomMode.x,
    );
    _soilZoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enablePinching: true,
      zoomMode: ZoomMode.x,
    );
    _airZoomPanBehavior = ZoomPanBehavior(
      enablePanning: true,
      enablePinching: true,
      zoomMode: ZoomMode.x,
    );

    Future.microtask(() async {
      await ref
          .read(getHistorySensorProvider.notifier)
          .getHistorySensor(id: widget.device.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final historySensorState = ref.watch(getHistorySensorProvider);

    // DateTime? minDate;
    // DateTime? maxDate;

    late List<HistorySensor> historySensorList;

    if (historySensorState is device_state.Success) {
      historySensorList = historySensorState.listHistorySensor ?? [];
      // final listTime = historySensorList
      //     .map((historySensor) => historySensor.timestamp)
      //     .whereType<DateTime>()
      //     .toList();
      // minDate = listTime.reduce((a, b) => a.isBefore(b) ? a : b);
      // maxDate = listTime.reduce((a, b) => a.isAfter(b) ? a : b);
      // print('debug: $minDate, $maxDate');
    }

    return Container(
      height: double.infinity,
      color: AppColors.primarySurface,
      // child: ElevatedButton(
      //   onPressed: () {
      //     ref.read(getHistorySensorProvider.notifier).getHistorySensor(id: id);
      //   },
      //   child: Text('data'),
      // ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(14, 8, 14, 28),
        child: Column(
          spacing: 8,
          children: [
            Expanded(
              child: Card(
                margin: EdgeInsets.all(0),
                color: colorScheme.onPrimary,
                elevation: 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 8, left: 8),
                      child: Row(
                        children: [
                          Icon(Symbols.thermostat),
                          SizedBox(width: 4),
                          Text('Nhiệt độ (°C)'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: historySensorState is device_state.Loading
                          ? Center(child: CircularProgressIndicator())
                          : historySensorState is device_state.Success
                          ? SfCartesianChart(
                              zoomPanBehavior: _tempZoomPanBehavior,
                              primaryXAxis: DateTimeAxis(
                                dateFormat: DateFormat('HH:mm - dd/MM'),
                                axisLabelFormatter: _formatAxisLabel,
                                majorGridLines: MajorGridLines(width: 0),
                                // majorTickLines: MajorTickLines(width: 1),
                                labelRotation: 0,
                                edgeLabelPlacement: EdgeLabelPlacement.shift,
                                // minimum: minDate,
                                // maximum: maxDate,
                                // intervalType: DateTimeIntervalType.hours,
                                // interval: maxDate.difference(minDate) ,
                                // initialVisibleMinimum: minDate,
                                // initialVisibleMaximum: maxDate,
                              ),
                              primaryYAxis: NumericAxis(
                                initialVisibleMaximum: 80,
                              ),
                              trackballBehavior: _tempTrackballBehavior,
                              series:
                                  <CartesianSeries<HistorySensor, DateTime?>>[
                                    LineSeries<HistorySensor, DateTime?>(
                                      dataSource: historySensorList,
                                      color: Colors.red,
                                      xValueMapper:
                                          (HistorySensor historySensor, _) =>
                                              historySensor.timestamp,
                                      yValueMapper:
                                          (HistorySensor historySensor, _) =>
                                              historySensor.temp,
                                      name: 'Nhiệt độ',
                                      dataLabelSettings: DataLabelSettings(
                                        isVisible: true,
                                      ),
                                      markerSettings: MarkerSettings(
                                        isVisible: true,
                                      ),
                                    ),
                                  ],
                            )
                          : Center(child: Text('Lỗi khi tải nhiệt độ')),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Card(
                margin: EdgeInsets.all(0),
                color: colorScheme.onPrimary,
                elevation: 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 8, left: 8),
                      child: Row(
                        children: [
                          Icon(Symbols.water_drop),
                          SizedBox(width: 4),
                          Text('Độ ẩm đất (%)'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: historySensorState is device_state.Loading
                          ? Center(child: CircularProgressIndicator())
                          : historySensorState is device_state.Success
                          ? SfCartesianChart(
                              zoomPanBehavior: _soilZoomPanBehavior,
                              primaryXAxis: DateTimeAxis(
                                dateFormat: DateFormat('HH:mm - dd/MM'),
                                axisLabelFormatter: _formatAxisLabel,
                                majorGridLines: MajorGridLines(width: 0),
                                labelRotation: 0,
                                edgeLabelPlacement: EdgeLabelPlacement.shift,
                              ),
                              primaryYAxis: NumericAxis(
                                minimum: 0,
                                maximum: 100,
                              ),
                              trackballBehavior: _soilTrackballBehavior,
                              series:
                                  <CartesianSeries<HistorySensor, DateTime?>>[
                                    LineSeries<HistorySensor, DateTime?>(
                                      dataSource: historySensorList,
                                      color: Colors.brown,
                                      xValueMapper:
                                          (HistorySensor historySensor, _) =>
                                              historySensor.timestamp,
                                      yValueMapper:
                                          (HistorySensor historySensor, _) =>
                                              historySensor.soil,
                                      name: 'Độ ẩm đất',
                                      dataLabelSettings: DataLabelSettings(
                                        isVisible: true,
                                      ),
                                      markerSettings: MarkerSettings(
                                        isVisible: true,
                                      ),
                                    ),
                                  ],
                            )
                          : Center(child: Text('Lỗi khi tải độ ẩm đất')),
                    ),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Card(
                margin: EdgeInsets.all(0),
                color: colorScheme.onPrimary,
                elevation: 3,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 8, left: 8),
                      child: Row(
                        children: [
                          Icon(Symbols.water),
                          SizedBox(width: 4),
                          Text('Độ ẩm không khí (%)'),
                        ],
                      ),
                    ),
                    Expanded(
                      child: historySensorState is device_state.Loading
                          ? Center(child: CircularProgressIndicator())
                          : historySensorState is device_state.Success
                          ? SfCartesianChart(
                              zoomPanBehavior: _airZoomPanBehavior,
                              primaryXAxis: DateTimeAxis(
                                dateFormat: DateFormat('HH:mm - dd/MM'),
                                axisLabelFormatter: _formatAxisLabel,
                                majorGridLines: MajorGridLines(width: 0),
                                labelRotation: 0,
                                edgeLabelPlacement: EdgeLabelPlacement.shift,
                              ),
                              primaryYAxis: NumericAxis(
                                minimum: 0,
                                maximum: 100,
                              ),
                              trackballBehavior: _airTrackballBehavior,
                              series:
                                  <CartesianSeries<HistorySensor, DateTime?>>[
                                    LineSeries<HistorySensor, DateTime?>(
                                      dataSource: historySensorList,
                                      color: Colors.cyan,
                                      xValueMapper:
                                          (HistorySensor historySensor, _) =>
                                              historySensor.timestamp,
                                      yValueMapper:
                                          (HistorySensor historySensor, _) =>
                                              historySensor.air,
                                      name: 'Độ ẩm không khí',
                                      dataLabelSettings: DataLabelSettings(
                                        isVisible: true,
                                      ),
                                      markerSettings: MarkerSettings(
                                        isVisible: true,
                                      ),
                                    ),
                                  ],
                            )
                          : Center(child: Text('Lỗi khi tải độ ẩm không khí')),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
