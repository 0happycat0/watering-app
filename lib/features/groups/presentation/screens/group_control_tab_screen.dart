import 'package:data_table_2/data_table_2.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/core/constants/app_assets.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/constants/app_strings.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/text_form_field/normal_text_form_field.dart';
import 'package:watering_app/features/groups/data/models/group_model.dart';
import 'package:watering_app/features/groups/providers/group/group_provider.dart';
import 'package:watering_app/features/groups/providers/group/group_state.dart'
    as group_state;
import 'package:watering_app/features/groups/providers/group/get_history_provider.dart';
import 'package:watering_app/core/widgets/history_watering_data_table.dart';
import 'package:watering_app/theme/styles.dart';
import 'package:watering_app/theme/theme.dart';

class GroupControlTabScreen extends ConsumerStatefulWidget {
  const GroupControlTabScreen({super.key, required this.group});

  final Group group;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _GroupControlTabScreenState();
}

class _GroupControlTabScreenState extends ConsumerState<GroupControlTabScreen> {
  final _durationController = TextEditingController(text: '10');
  bool _isToggling = false;

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
          // Xóa số 0 đứng đầu
          newText = value.toStringAsFixed(0);
        }
      } else {
        newText = '0';
      }

      if (_durationController.text != newText) {
        _durationController.text = newText;
        // Di chuyển con trỏ về cuối
        _durationController.selection = TextSelection.fromPosition(
          TextPosition(offset: _durationController.text.length),
        );
      }
    });
  }

  void _toggleGroup(String id, String action, int duration) async {
    if (_isToggling) return;

    setState(() {
      _isToggling = true;
    });

    // Gọi API
    final success = await ref
        .read(toggleGroupProvider.notifier)
        .toggleGroup(
          group: Group(id: id, action: action, duration: duration),
        );

    if (!mounted) return;

    if (success) {
      // API thành công
      await Future.delayed(const Duration(milliseconds: 300));

      if (!mounted) return;

      // Thành công, nếu là STOP thì refresh history
      if (action == 'STOP') {
        await ref
            .read(getGroupHistoryWateringProvider.notifier)
            .getHistoryWatering(id: widget.group.id);
      }
    } else {
      // API thất bại
      ScaffoldMessenger.of(context).showSnackBar(
        CustomSnackBar(text: 'Có lỗi xảy ra. Vui lòng thử lại.'),
      );
    }

    if (mounted) {
      setState(() {
        _isToggling = false;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Chạy sau khi initstate hoàn tất
    Future.microtask(() async {
      if(!mounted) return;
      await ref
          .read(getGroupHistoryWateringProvider.notifier)
          .getHistoryWatering(id: widget.group.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final id = widget.group.id;

    final historyWateringState = ref.watch(getGroupHistoryWateringProvider);
    late DataTableSource historyWateringDataSource;

    double currentSliderValue = double.tryParse(_durationController.text) ?? 0;
    double sliderValue = currentSliderValue.clamp(0.0, 60.0);

    if (historyWateringState is group_state.Success) {
      historyWateringDataSource = HistoryWateringDataSource(
        historyWateringList: historyWateringState.listHistoryWatering ?? [],
      );
    }

    return Container(
      height: double.infinity,
      color: AppColors.primarySurface,
      child: Column(
        children: [
          // Pump section
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
                  SizedBox(height: 20),
                  Center(
                    child: SizedBox(
                      width: 150,
                      child: ElevatedButton(
                        onPressed: !_isToggling
                            ? () {
                                _toggleGroup(
                                  id,
                                  'START',
                                  int.tryParse(
                                        _durationController.text,
                                      ) ??
                                      0,
                                );
                              }
                            : null,
                        style: AppStyles.elevatedButtonStyle(),
                        child: _isToggling
                            ? CustomCircularProgress()
                            : Text(
                                'Bơm ngay',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // History section
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
                                .read(getGroupHistoryWateringProvider.notifier)
                                .refresh(id: id);
                          },
                          icon: Icon(Symbols.refresh_rounded),
                        ),
                      ],
                    ),
                  ),
                  historyWateringState is group_state.Loading
                      ? Expanded(
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : historyWateringState is group_state.Success
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
                              showFirstLastButtons: true,
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
                      : Expanded(
                          child: Center(
                            child: Text(
                              'Lỗi khi tải lịch sử tưới',
                              style: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

