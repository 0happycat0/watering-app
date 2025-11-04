import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/theme/theme.dart';

class CustomFab extends StatelessWidget {
  CustomFab({
    super.key,
    required this.onAddDevicePressed,
    required this.onAddGroupPressed,
  });
  final void Function() onAddDevicePressed;
  final void Function() onAddGroupPressed;

  final _key = GlobalKey<ExpandableFabState>();

  @override
  Widget build(BuildContext context) {
    return ExpandableFab(
      key: _key,
      margin: EdgeInsets.symmetric(vertical: 4, horizontal: 2),
      type: ExpandableFabType.up,
      childrenAnimation: ExpandableFabAnimation.none,
      distance: 55,
      duration: Duration(milliseconds: 200),
      openButtonBuilder: DefaultFloatingActionButtonBuilder(
        heroTag: null,
        fabSize: ExpandableFabSize.regular,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadiusGeometry.circular(200),
          side: BorderSide(
            color: AppColors.mainYellow[300]!,
            strokeAlign: BorderSide.strokeAlignOutside,
            width: 1,
          ),
        ),
        foregroundColor: AppColors.primaryYellow[500],
        backgroundColor: AppColors.primaryYellow[100],
        child: Icon(
          Symbols.add,
          size: 32,
          weight: 600,
        ),
      ),
      closeButtonBuilder: DefaultFloatingActionButtonBuilder(
        heroTag: null,
        fabSize: ExpandableFabSize.small,
        foregroundColor: AppColors.mainGreen[50],
        backgroundColor: AppColors.mainGreen[400],
        shape: CircleBorder(),
        child: Icon(Icons.close),
      ),
      children: [
        SizedBox(
          height: 48,
          child: FloatingActionButton.extended(
            heroTag: null,
            onPressed: () {
              final state = _key.currentState;
              onAddDevicePressed();
              if (state != null) {
                state.toggle();
              }
            },
            elevation: 2,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            label: Text('Thêm thiết bị'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
        SizedBox(
          height: 48,
          child: FloatingActionButton.extended(
            heroTag: null,
            onPressed: () {
              final state = _key.currentState;
              if (state != null) {
                state.toggle();
              }
            },
            elevation: 2,
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
            label: Text('Thêm nhóm'),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
          ),
        ),
      ],
    );
  }
}
