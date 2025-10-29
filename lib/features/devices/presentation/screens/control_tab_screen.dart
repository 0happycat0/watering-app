import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/core/constants/app_assets.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/constants/app_strings.dart';
import 'package:watering_app/core/widgets/text_form_field/normal_text_form_field.dart';
import 'package:watering_app/features/devices/data/models/device_model.dart';
import 'package:watering_app/features/devices/presentation/providers/device/device_state.dart'
    as device_state;
import 'package:watering_app/features/devices/presentation/providers/device/get_history_watering_provider.dart';
import 'package:watering_app/features/devices/presentation/providers/device/toggle_device_provider.dart';
import 'package:watering_app/features/devices/presentation/widgets/history_watering_data_table.dart';
import 'package:watering_app/theme/styles.dart';
import 'package:watering_app/theme/theme.dart';

class ControlTabScreen extends ConsumerStatefulWidget {
  const ControlTabScreen({super.key, required this.device});

  final Device device;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ControlTabScreenState();
}

class _ControlTabScreenState extends ConsumerState<ControlTabScreen> {
  final _durationController = TextEditingController(text: '10');

  int _rowPerPage = 5;
  bool _isWatering = false;

  void _onDurationTextChanged(String text) {
    setState(() {
      final value = double.tryParse(text);
      String newText = text;

      if (value != null) {
        if (value > 60) {
          newText = AppStrings.maxPumpDurationValue;
        } else if (value < 0) {
          newText = AppStrings.minPumpDurationValue;
        } else {
          //xóa số 0 đứng đầu
          newText = value.toStringAsFixed(0);
        }
      } else {
        newText = '0';
      }

      if (_durationController.text != newText) {
        _durationController.text = newText;
        //di chuyển con trỏ về cuối
        _durationController.selection = TextSelection.fromPosition(
          TextPosition(offset: _durationController.text.length),
        );
      }
    });
  }

  void _toggleDevice(String id, String action, int duration) async {
    setState(() {
      _isWatering = !_isWatering;
    });

    await ref.read(
      toggleDeviceProvider(
        Device(id: id, action: action, duration: duration),
      ).future,
    );
    if (!_isWatering) {
      await ref
          .read(getHistoryWateringProvider.notifier)
          .getHistoryWatering(id: widget.device.id);
    }
  }

  @override
  void initState() {
    super.initState();

    //chạy sau khi initstate hoàn tất
    Future.microtask(() async {
      await ref
          .read(getHistoryWateringProvider.notifier)
          .getHistoryWatering(id: widget.device.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.device.id;
    final historyWateringState = ref.watch(getHistoryWateringProvider);
    late DataTableSource historyWateringDataSource;

    double currentSliderValue = double.tryParse(_durationController.text) ?? 0;
    double sliderValue = currentSliderValue.clamp(0.0, 60.0);

    if (historyWateringState is device_state.Success) {
      historyWateringDataSource = HistoryWateringDataSource(
        historyWateringList: historyWateringState.listHistoryWatering ?? [],
      );
    }

    return Container(
      height: double.infinity,
      color: AppColors.mainGreen[50]!,
      child: Column(
        children: [
          //pump section
          Card(
            color: colorScheme.onPrimary,
            margin: EdgeInsets.fromLTRB(14, 12, 14, 0),
            elevation: 3,
            child: Padding(
              padding: EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Image.asset(AppAssets.pump, width: 100),
                      SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Slider(
                              year2023: false,
                              padding: EdgeInsets.all(0),
                              value: sliderValue,
                              max: 60,
                              onChanged: (value) {
                                setState(() {
                                  _durationController.text = value
                                      .toStringAsFixed(0);
                                });
                              },
                            ),
                            SizedBox(height: 10),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 50,
                                  child: NormalTextFormField(
                                    textController: _durationController,
                                    textAlign: TextAlign.center,
                                    hintText: '',
                                    keyboardType:
                                        TextInputType.numberWithOptions(),
                                    padding: EdgeInsets.symmetric(
                                      vertical: 4,
                                      horizontal: 2,
                                    ),
                                    onChanged: _onDurationTextChanged,
                                  ),
                                ),
                                SizedBox(width: 10),
                                Text(
                                  'phút',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.mainGreen[200],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                    child: _isWatering
                        ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            child: Text(
                              'Đang bơm...',
                              textAlign: TextAlign.left,
                            ),
                          )
                        : null,
                  ),
                  Center(
                    child: SizedBox(
                      width: 150,
                      child: _isWatering
                          ? ElevatedButton(
                              onPressed: () {
                                _toggleDevice(id, 'STOP', 0);
                              },
                              style: AppStyles.elevatedButtonStyle(),
                              child: Text('Hủy'),
                            )
                          : ElevatedButton(
                              onPressed: () {
                                _toggleDevice(
                                  id,
                                  'START',
                                  int.tryParse(_durationController.text) ?? 0,
                                );
                              },
                              style: AppStyles.elevatedButtonStyle(),
                              child: Text(
                                'Bơm ngay',
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //history section
          Expanded(
            child: Card(
              color: colorScheme.onPrimary,
              elevation: 3,
              margin: EdgeInsets.fromLTRB(14, 12, 14, 34),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.fromLTRB(20, 10, 10, 10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Lịch sử tưới',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () async {
                            await ref
                                .read(getHistoryWateringProvider.notifier)
                                .refresh(id: id);
                          },
                          icon: Icon(Symbols.refresh_rounded),
                        ),
                      ],
                    ),
                  ),
                  historyWateringState is device_state.Loading
                      ? Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : historyWateringState is device_state.Success
                      ? Expanded(
                          child: Theme(
                            data: ThemeData(),
                            child: PaginatedDataTable2(
                              wrapInCard: false,
                              columns: <DataColumn>[
                                DataColumn2(
                                  size: ColumnSize.L,
                                  headingRowAlignment: MainAxisAlignment.center,
                                  label: Text(
                                    'Thời gian',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                                DataColumn2(
                                  size: ColumnSize.M,
                                  headingRowAlignment: MainAxisAlignment.center,
                                  label: Text(
                                    'Số phút tưới',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: colorScheme.onPrimary,
                                    ),
                                  ),
                                ),
                              ],

                              // rowsPerPage: _rowPerPage,
                              // availableRowsPerPage: [5, 10, 15, 20],
                              // onRowsPerPageChanged: (value) {
                              //   _rowPerPage = value!;
                              // },
                              showFirstLastButtons: true,
                              // columnSpacing: 10,
                              horizontalMargin: 32,
                              headingRowHeight: 48,
                              headingRowColor: WidgetStateColor.resolveWith(
                                (states) => colorScheme.primary,
                              ),
                              border: TableBorder(
                                borderRadius: BorderRadius.circular(40),
                              ),
                              dataRowHeight: 42,
                              dataTextStyle: TextStyle(
                                color: Colors.black87,
                                fontWeight: FontWeight.bold,
                              ),
                              empty: Center(child: Text('Chưa có lịch sử')),
                              source: historyWateringDataSource,
                            ),
                          ),
                        )
                      : Center(child: Text('Lỗi khi tải lịch sử tưới')),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
