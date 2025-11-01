import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/widgets/text_form_field/normal_text_form_field.dart';
import 'package:watering_app/features/devices/data/enums/schedule_enums.dart';
import 'package:watering_app/features/devices/data/models/schedule_model.dart';
import 'package:watering_app/theme/theme.dart';

class EditScheduleSheet extends ConsumerStatefulWidget {
  const EditScheduleSheet({
    super.key,
    this.schedule, // Null: Chế độ Thêm, Not-Null: Chế độ Sửa
  });

  final Schedule? schedule;

  @override
  ConsumerState<EditScheduleSheet> createState() => _ScheduleEditSheetState();
}

class _ScheduleEditSheetState extends ConsumerState<EditScheduleSheet> {
  late bool _isEditMode;
  TimeOfDay? _selectedTime;
  final _durationController = TextEditingController();
  Set<DaysOfWeek> _selectedDays = {};

  // Map từ UI label sang Enum (giống ScheduleListItem)
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
      // Chế độ SỬA: Lấy dữ liệu từ schedule
      final schedule = widget.schedule!;
      _selectedTime = _parseTime(schedule.startTime);
      _durationController.text = schedule.duration.toString();
      _selectedDays = schedule.daysOfWeek?.toSet() ?? {};
    } else {
      // Chế độ THÊM: Đặt giá trị mặc định
      _selectedTime = const TimeOfDay(hour: 7, minute: 0);
      _durationController.text = '15';
      _selectedDays = {};
    }

    // Listener để đồng bộ state của quick chip và text field
    _durationController.addListener(() {
      setState(() {
        // Cần gọi setState để vẽ lại các chip 5, 15, 30
      });
    });
  }

  @override
  void dispose() {
    _durationController.dispose();
    super.dispose();
  }

  // Chuyển "07:00" thành TimeOfDay(hour: 7, minute: 0)
  TimeOfDay _parseTime(String timeStr) {
    try {
      final parts = timeStr.split(':');
      return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
    } catch (e) {
      return const TimeOfDay(hour: 7, minute: 0); // Fallback
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

  // Hàm khi nhấn Lưu
  void _onSave() {
    // Tạm thời chỉ in ra, sau này sẽ gọi provider
    final timeStr =
        '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}';
    final duration = int.tryParse(_durationController.text) ?? 0;

    print('--- ĐANG LƯU LỊCH ---');
    print('Mode: ${_isEditMode ? 'Sửa' : 'Thêm'}');
    print('Time: $timeStr');
    print('Duration: $duration phút');
    print('Days: $_selectedDays');
    if (_isEditMode) {
      print('ID (Sửa): ${widget.schedule!.id}');
    }

    // TODO: ref.read(provider.notifier).saveSchedule(...);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;

    return AnimatedPadding(
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

          // 1. Chọn giờ tưới
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

          // 2. Thời lượng tưới
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
              // Các nút chọn nhanh
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
                      // Tắt focus khỏi text field
                      FocusScope.of(context).unfocus();
                    },
                  ),
                );
              }),
            ],
          ),
          const SizedBox(height: 20),

          _buildSectionTitle('Chọn các ngày lặp lại', textTheme),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
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
                    foregroundColor: colorScheme.onSurfaceVariant,
                    side: BorderSide(color: colorScheme.outline),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  icon: const Icon(Symbols.check),
                  label: const Text('Lưu Lịch'),
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
