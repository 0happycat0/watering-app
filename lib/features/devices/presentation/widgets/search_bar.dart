import 'package:flutter/material.dart';

class DeviceSearchBar extends StatelessWidget {
  const DeviceSearchBar({
    super.key,
    this.controller,
    this.focusNode,
    this.onTap,
    this.onChanged,
  });

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final VoidCallback? onTap;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return SearchBar(
      controller: controller,
      focusNode: focusNode,
      hintText: 'Tìm kiếm thiết bị...',
      leading: const Padding(
        padding: EdgeInsets.only(left: 4, top: 10, bottom: 10),
        child: Icon(Icons.search, color: Colors.grey, size: 22),
      ),
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
          // Viền xám nhạt
          side: BorderSide.none,
        ),
      ),
      padding: WidgetStateProperty.all(
        const EdgeInsets.symmetric(horizontal: 12.0),
      ),
      // Giới hạn chiều cao của SearchBar
      constraints: const BoxConstraints(maxHeight: 48),
      onTap: onTap,
      onChanged: onChanged,
    );
  }
}
