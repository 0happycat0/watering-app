import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/widgets/custom_circular_progress.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/text_form_field/normal_text_form_field.dart';
import 'package:watering_app/features/devices/data/enums/devices_enums.dart';
import 'package:watering_app/features/devices/data/models/schedule_model.dart';
import 'package:watering_app/features/devices/providers/device/device_state.dart'
    as device_state;
import 'package:watering_app/features/devices/providers/device/schedule_provider.dart';
import 'package:watering_app/theme/theme.dart';

class EditScheduleSheet extends ConsumerStatefulWidget {
  const EditScheduleSheet({
    super.key,
    required this.id,
    this.schedule, // Null: Chế độ Thêm, Not-Null: Chế độ Sửa
  });

  final String id;
  final Schedule? schedule;

  @override
  ConsumerState<EditScheduleSheet> createState() => _ScheduleEditSheetState();
}

class _ScheduleEditSheetState extends ConsumerState<EditScheduleSheet> {
  late bool _isEditMode;
  TimeOfDay? _selectedTime;
  final _durationController = TextEditingController();
  Set<DaysOfWeek> _selectedDays = {};
  late RepeatType _selectedRepeatType;

  static const Map<String, DaysOfWeek> dayMap = {
    'T2': DaysOfWeek.MON,
    'T3': DaysOfWeek.TUE,
    'T4': DaysOfWeek.WED,
    'T5': DaysOfWeek.THU,
    'T6': DaysOfWeek.FRI,
    'T7': DaysOfWeek.SAT,
    'CN': DaysOfWeek.SUN,
  };
  final List<String> _dayLabels = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];
  final List<int> _quickDurations = [5, 15, 30];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.schedule != null;

    if (_isEditMode) {
      final schedule = widget.schedule!;
      _selectedTime = _parseTime(schedule.startTime);
      _durationController.text = schedule.duration.toString();
      _selectedDays = schedule.daysOfWeek?.toSet() ?? {};
      _selectedRepeatType = schedule.repeatType;
    } else {
      _selectedTime = TimeOfDay.now();
      _durationController.text = '15';
      _selectedDays = {};
      _selectedRepeatType = RepeatType.ONE_TIME;
    }

    // Listener để đồng bộ state của quick chip và text field
    _durationController.addListener(() {
      setState(() {
        // Cần gọi setState để vẽ lại các chip 5, 15, 30
      });
    });
  }

  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return const TimeOfDay(hour: 7, minute: 0);
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  Future<void> _pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: Colors.white,
              dialBackgroundColor: AppColors.mainGreen[50],
              dayPeriodTextColor: colorScheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  String _getRepeatTypeText(RepeatType type) {
    switch (type) {
      case RepeatType.ONE_TIME:
        return 'Một lần';
      case RepeatType.DAYS:
        return 'Tuỳ chọn';
      case RepeatType.EVERYDAY:
        return 'Mỗi ngày';
      // ignore: unreachable_switch_default
      default:
        return '';
    }
  }

  void _onSave() async {
    final schedule = widget.schedule;
    final timeStr =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}:00';
    final duration = int.tryParse(_durationController.text) ?? 0;
    final repeatType = _selectedRepeatType;
    final selectedDays = _selectedDays.toList();

    print('--- ĐANG LƯU LỊCH ---');
    print('Mode: ${_isEditMode ? 'Sửa' : 'Thêm'}');
    print('Time: $timeStr');
    print('Duration: $duration phút');
    print('Days: $_selectedDays');
    if (_isEditMode) {
      print('ID (Sửa): ${schedule!.id}');
      await ref
          .read(updateScheduleProvider.notifier)
          .updateSchedule(
            id: widget.id,
            scheduleId: schedule.id,
            startTime: timeStr,
            duration: duration,
            repeatType: repeatType,
            daysOfWeek: selectedDays,
          );
    } else {
      await ref
          .read(createScheduleProvider.notifier)
          .createSchedule(
            id: widget.id,
            startTime: timeStr,
            duration: duration,
            repeatType: repeatType,
            daysOfWeek: selectedDays,
          );
    }
    ref.read(getListScheduleProvider.notifier).refresh(id: widget.id);
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    late device_state.DeviceState deviceState;

    if (_isEditMode) {
      deviceState = ref.watch(updateScheduleProvider);
      ref.listen(updateScheduleProvider, (prev, next) {
        print(
          'Update schedule transition: ${prev.runtimeType} -> ${next.runtimeType}',
        );
        if (next is device_state.Failure) {
          final message = next.message;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(CustomSnackBar(text: message));
        }
        if (next is device_state.Success && prev is device_state.Loading) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            CustomSnackBar(text: 'Cập nhật thành công'),
          );
          Navigator.pop(context);
        }
      });
    } else {
      deviceState = ref.watch(createScheduleProvider);
      ref.listen(createScheduleProvider, (prev, next) {
        print(
          'Create schedule transition: ${prev.runtimeType} -> ${next.runtimeType}',
        );
        if (next is device_state.Failure) {
          final message = next.message;
          Navigator.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(CustomSnackBar(text: message));
        }
        if (next is device_state.Success && prev is device_state.Loading) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(
            CustomSnackBar(text: 'Đã thêm lịch'),
          );
          Navigator.pop(context);
        }
      });
    }

    return SingleChildScrollView(
      child: AnimatedPadding(
        duration: Duration(milliseconds: 50),
        curve: Curves.decelerate,
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          30 + MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _isEditMode ? 'Cập Nhật Lịch Tưới' : 'Tạo Lịch Tưới Mới',
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.mainGreen[200],
              ),
            ),
            const SizedBox(height: 24),

            _buildSectionTitle('Chọn giờ tưới', textTheme),
            NormalTextFormField(
              textController: TextEditingController(
                text: _formatTime(_selectedTime!),
              ),
              hintText: '',
              readOnly: true,
              onTap: _pickTime,
              suffixIcon: Icon(Symbols.schedule, color: colorScheme.primary),
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Thời lượng tưới (phút)', textTheme),
            Row(
              children: [
                Expanded(
                  child: NormalTextFormField(
                    textController: _durationController,
                    hintText: '',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    suffixIcon: Icon(Symbols.timer, color: colorScheme.primary),
                  ),
                ),
                const SizedBox(width: 10),
                ..._quickDurations.map((duration) {
                  final isSelected =
                      _durationController.text == duration.toString();
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: _DurationChip(
                      label: '$duration',
                      isSelected: isSelected,
                      onTap: () {
                        _durationController.text = '$duration';
                        FocusScope.of(context).unfocus();
                      },
                    ),
                  );
                }),
              ],
            ),
            const SizedBox(height: 20),

            _buildSectionTitle('Kiểu lặp lại', textTheme),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: RepeatType.values.map((type) {
                final isSelected = _selectedRepeatType == type;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: _DurationChip(
                      label: _getRepeatTypeText(type),
                      isSelected: isSelected,
                      onTap: () {
                        setState(() {
                          _selectedRepeatType = type;
                        });
                      },
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 20),

            AnimatedSize(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_selectedRepeatType == RepeatType.DAYS) ...[
                    _buildSectionTitle('Chọn các ngày lặp lại', textTheme),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _dayLabels.map((label) {
                        final dayEnum = dayMap[label]!;
                        final isSelected = _selectedDays.contains(dayEnum);
                        return _DayToggleChip(
                          label: label,
                          isSelected: isSelected,
                          onTap: () {
                            setState(() {
                              if (isSelected) {
                                _selectedDays.remove(dayEnum);
                              } else {
                                _selectedDays.add(dayEnum);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 30),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Symbols.close),
                    label: const Text('Hủy'),
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      splashFactory: NoSplash.splashFactory,
                      foregroundColor: colorScheme.onSurfaceVariant,
                      side: BorderSide(color: colorScheme.outline),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: deviceState is device_state.Loading
                        ? null
                        : const Icon(Symbols.check),
                    label: deviceState is device_state.Loading
                        ? CustomCircularProgress()
                        : const Text('Lưu Lịch'),
                    onPressed: _onSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainGreen[200],
                      foregroundColor: colorScheme.onPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, TextTheme textTheme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

class _DurationChip extends StatelessWidget {
  const _DurationChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ActionChip(
      label: Text(label),
      onPressed: onTap,
      backgroundColor: isSelected
          ? colorScheme.primary
          : AppColors.mainGreen[50],
      labelStyle: TextStyle(
        color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
      side: BorderSide.none,
    );
  }
}

class _DayToggleChip extends StatelessWidget {
  const _DayToggleChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isSelected ? colorScheme.primary : AppColors.mainGreen[50],
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: isSelected ? 2 : 0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
          child: Text(
            label,
            style: TextStyle(
              color: isSelected ? colorScheme.onPrimary : colorScheme.primary,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}
