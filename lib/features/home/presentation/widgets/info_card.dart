import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/features/home/providers/home_provider.dart';
import 'package:watering_app/features/home/providers/home_state.dart'
    as home_state;
import 'package:watering_app/theme/theme.dart';

class InfoCard extends ConsumerWidget {
  const InfoCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final quantitiesState = ref.watch(quantitiesProvider);

    final bool isLoading =
        quantitiesState is home_state.Loading ||
        quantitiesState is home_state.Initial;
    final bool isFailure = quantitiesState is home_state.Failure;

    Widget buildRefreshButton() {
      return Positioned(
        top: 2,
        right: 4,
        child: IconButton(
          icon: Icon(Icons.refresh, color: Colors.grey[600]),
          onPressed: () {
            ref.read(quantitiesProvider.notifier).getQuantities();
          },
        ),
      );
    }

    return Stack(
      children: [
        Card(
          elevation: 4,
          shadowColor: colorScheme.shadow.withAlpha(50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          color: Colors.white.withAlpha(230),

          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            child: IntrinsicHeight(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  if (isLoading)
                    const Expanded(
                      child: SizedBox(
                        height: 107,
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    )
                  else if (isFailure)
                    const Expanded(
                      child: SizedBox(
                        height: 107,
                        child: Center(
                          child: Text('Lỗi khi tải thông tin'),
                        ),
                      ),
                    )
                  else ...[
                    Expanded(
                      child: _InfoColumn(
                        theme: theme,
                        title: 'Tổng thiết bị',
                        count:
                            (quantitiesState as home_state.Success)
                                .devicesQuantity
                                ?.toString() ??
                            '0',
                        icon: Symbols.all_inclusive,
                        iconColor: AppColors.secondaryGreen[300]!,
                        iconBgColor: AppColors.secondaryGreen[100]!,
                      ),
                    ),
                    const VerticalDivider(
                      width: 1,
                      thickness: 1,
                      indent: 8,
                      endIndent: 8,
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: _InfoColumn(
                        theme: theme,
                        title: 'Thiết bị online',
                        count:
                            quantitiesState.onlineDevicesQuantity?.toString() ??
                            '0',
                        icon: Symbols.wifi,
                        iconColor: Colors.blue[600]!,
                        iconBgColor: Colors.blue[100]!,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),

        if (!isLoading) buildRefreshButton(),
      ],
    );
  }
}

class _InfoColumn extends StatelessWidget {
  const _InfoColumn({
    required this.theme,
    required this.title,
    required this.count,
    required this.icon,
    required this.iconColor,
    required this.iconBgColor,
  });

  final ThemeData theme;
  final String title;
  final String count;
  final IconData icon;
  final Color iconColor;
  final Color iconBgColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: iconBgColor,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: iconColor),
        ),
        const SizedBox(height: 12),
        Text(
          title,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          count,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
