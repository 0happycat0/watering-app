import 'package:flutter/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/features/devices/data/enums/devices_enums.dart';

extension AllDevicesSortFieldLabel on AllDevicesSortField {
  String get label {
    switch (this) {
      case AllDevicesSortField.defaultSort:
        return 'Mặc định';
      case AllDevicesSortField.name:
        return 'Theo tên';
      case AllDevicesSortField.updatedAt:
        return 'Ngày cập nhật';
      case AllDevicesSortField.isWatering:
        return 'Đang bơm';
      case AllDevicesSortField.isOnline:
        return 'Đang online';
    }
  }
}

/// Widget nút Sort cho màn hình tất cả thiết bị
class DeviceSortButton extends StatelessWidget {
  const DeviceSortButton({
    super.key,
    required this.currentSort,
    required this.isAscending,
    required this.onSortSelected,
    this.onMenuOpened,
    this.onMenuClosed,
  });

  final AllDevicesSortField currentSort;
  final bool isAscending;
  final ValueChanged<AllDevicesSortField> onSortSelected;
  final VoidCallback? onMenuOpened;
  final VoidCallback? onMenuClosed;

  @override
  Widget build(BuildContext context) {
    const double itemHeight = 40.0;
    const double headerHeight = 30.0;
    const double menuWidth = 170.0;

    return PopupMenuButton<String>(
      color: Colors.white,
      elevation: 6,
      borderRadius: BorderRadius.circular(12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300, width: 1),
      ),
      offset: const Offset(0, 48),
      onOpened: onMenuOpened,
      onCanceled: onMenuClosed,
      onSelected: (String sortName) {
        onMenuClosed?.call();
        if (sortName != 'header' && sortName != 'footer') {
          final selectedOption = AllDevicesSortField.values.firstWhere(
            (sort) => sort.name == sortName,
          );
          onSortSelected(selectedOption);
        }
      },
      // Widget kích hoạt menu
      child: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Colors.grey.shade300,
            width: 1.0,
          ),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(
              Symbols.swap_vert,
              color: Colors.grey[700],
              size: 26,
            ),
            // Badge hiển thị hướng sắp xếp
            if (currentSort != AllDevicesSortField.defaultSort)
              Positioned(
                top: 2,
                right: 2,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.green.shade600,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isAscending ? Symbols.north : Symbols.south,
                    size: 10,
                    color: Colors.white,
                    weight: 700,
                  ),
                ),
              ),
          ],
        ),
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
        // Header
        const PopupMenuItem<String>(
          value: 'header',
          enabled: false,
          height: headerHeight,
          child: SizedBox(
            width: menuWidth,
            child: Text(
              'Sắp xếp theo',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
        ),
        const PopupMenuDivider(height: 8),

        // Menu items
        ...AllDevicesSortField.values.map((sort) {
          final isSelected = currentSort == sort;
          return PopupMenuItem<String>(
            value: sort.name,
            height: itemHeight,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  sort.label,
                  style: TextStyle(
                    fontSize: 14,
                    color: isSelected ? Colors.green.shade700 : Colors.black87,
                    fontWeight: isSelected
                        ? FontWeight.w600
                        : FontWeight.normal,
                  ),
                ),
                // Hiển thị dấu check nếu đây là mục đang chọn
                if (isSelected)
                  Icon(
                    Symbols.check_circle,
                    color: Colors.green.shade600,
                    size: 20,
                    fill: 1,
                  ),
              ],
            ),
          );
        }).toList(),

        const PopupMenuDivider(height: 8),

        // Footer
        const PopupMenuItem<String>(
          value: 'footer',
          height: headerHeight,
          enabled: false,
          child: Text(
            'Nhấn lại để đảo thứ tự',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }
}
