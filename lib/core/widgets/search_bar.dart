import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/features/devices/providers/all_devices/devices_provider.dart';
import 'package:watering_app/features/groups/providers/all_groups/groups_provider.dart';

class CustomSearchBar extends ConsumerStatefulWidget {
  const CustomSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.onTap,
    this.onChanged,
    this.onSubmitted,
    this.isGroup = false,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final bool isGroup;

  @override
  ConsumerState<CustomSearchBar> createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends ConsumerState<CustomSearchBar> {
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    _updateClearButtonVisibility();
    // Lắng nghe sự thay đổi của controller
    widget.controller?.addListener(_onTextChanged);
  }

  @override
  void didUpdateWidget(CustomSearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Nếu controller thay đổi, hủy listener cũ và thêm listener mới
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_onTextChanged);
      widget.controller?.addListener(_onTextChanged);
      _updateClearButtonVisibility(); // Cập nhật lại state
    }
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_onTextChanged);
    super.dispose();
  }

  void _onTextChanged() {
    _updateClearButtonVisibility();
  }

  void _updateClearButtonVisibility() {
    final bool shouldShow = widget.controller?.text.isNotEmpty ?? false;
    // Chỉ gọi setState nếu giá trị thực sự thay đổi để tối ưu performance
    if (mounted && _showClearButton != shouldShow) {
      setState(() {
        _showClearButton = shouldShow;
      });
    }
  }

  void _onClearPressed() {
    widget.controller?.clear();
    // Sau khi clear, listener _onTextChanged sẽ tự động được gọi
    // và cập nhật _showClearButton = false.

    // Tuy nhiên, controller.clear() không tự động gọi SearchBar.onChanged
    // nên chúng ta cần gọi nó thủ công nếu nó tồn tại.
    if (widget.onChanged != null) {
      widget.onChanged!('');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.isGroup) {
      ref.listen(shouldResetGroupSearchProvider, (prev, next) {
        if (next == true) {
          widget.controller?.clear();
          if (widget.onChanged != null) {
            widget.onChanged!('');
          }
          ref.read(shouldResetGroupSearchProvider.notifier).state = false;
        }
      });
    } else {
      //sau khi thêm thiết bị thì clear search
      ref.listen(shouldResetSortAndSearchProvider, (prev, next) {
        if (next == true) {
          widget.controller?.clear();
          if (widget.onChanged != null) {
            widget.onChanged!('');
          }
          ref.read(shouldResetSortAndSearchProvider.notifier).state = false;
        }
      });
    }

    return SearchBar(
      controller: widget.controller,
      focusNode: widget.focusNode,
      hintText: widget.isGroup ? 'Tìm kiếm nhóm...' : 'Tìm kiếm thiết bị...',
      leading: const Padding(
        padding: EdgeInsets.only(left: 4, top: 10, bottom: 10),
        child: Icon(Symbols.search, color: Colors.grey, size: 24),
      ),
      trailing: _showClearButton
          ? <Widget>[
              SizedBox(
                height: 42,
                width: 42,
                child: IconButton(
                  icon: const Icon(Symbols.clear, color: Colors.grey, size: 24),
                  onPressed: _onClearPressed,
                ),
              ),
            ]
          : null,
      hintStyle: WidgetStateProperty.all(
        TextStyle(
          color: Colors.grey.shade500,
          fontSize: 15,
        ),
      ),
      textStyle: WidgetStateProperty.all(
        const TextStyle(
          color: Colors.black87,
          fontSize: 15,
        ),
      ),
      elevation: WidgetStateProperty.all(0.0),
      backgroundColor: WidgetStateProperty.all(Colors.grey.shade100),
      shadowColor: WidgetStateProperty.all(Colors.transparent),
      surfaceTintColor: WidgetStateProperty.all(Colors.transparent),
      shape: WidgetStateProperty.all(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide.none,
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 12.0),
      ),
      // Giới hạn chiều cao của SearchBar
      constraints: const BoxConstraints(maxHeight: 48),
      onTap: widget.onTap,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
    );
  }
}
