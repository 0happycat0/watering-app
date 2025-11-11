# Diff Details

Date : 2025-11-11 07:57:18

Directory d:\\VSCode\\Flutter\\watering_app\\lib

Total : 61 files,  4170 codes, 225 comments, 381 blanks, all 4776 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [lib/core/constants/api\_path.dart](/lib/core/constants/api_path.dart) | Dart | 22 | 0 | 1 | 23 |
| [lib/core/constants/api\_strings.dart](/lib/core/constants/api_strings.dart) | Dart | 2 | 0 | 1 | 3 |
| [lib/core/constants/app\_assets.dart](/lib/core/constants/app_assets.dart) | Dart | 2 | 0 | 0 | 2 |
| [lib/core/constants/app\_colors.dart](/lib/core/constants/app_colors.dart) | Dart | 17 | 0 | 0 | 17 |
| [lib/core/data/models/history\_watering\_model.dart](/lib/core/data/models/history_watering_model.dart) | Dart | 30 | 0 | 6 | 36 |
| [lib/core/data/models/schedule\_model.dart](/lib/core/data/models/schedule_model.dart) | Dart | 86 | 1 | 8 | 95 |
| [lib/core/main\_scaffold.dart](/lib/core/main_scaffold.dart) | Dart | 14 | 0 | 1 | 15 |
| [lib/core/network/network\_service\_provider.dart](/lib/core/network/network_service_provider.dart) | Dart | 0 | 3 | -1 | 2 |
| [lib/core/utils/stomp\_service.dart](/lib/core/utils/stomp_service.dart) | Dart | 133 | 30 | 37 | 200 |
| [lib/core/widgets/custom\_app\_bar.dart](/lib/core/widgets/custom_app_bar.dart) | Dart | 3 | 0 | 0 | 3 |
| [lib/core/widgets/custom\_fab.dart](/lib/core/widgets/custom_fab.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/core/widgets/custom\_snack\_bar.dart](/lib/core/widgets/custom_snack_bar.dart) | Dart | 8 | 0 | 0 | 8 |
| [lib/core/widgets/edit\_schedule\_sheet.dart](/lib/core/widgets/edit_schedule_sheet.dart) | Dart | 516 | 7 | 30 | 553 |
| [lib/core/widgets/history\_watering\_data\_table.dart](/lib/core/widgets/history_watering_data_table.dart) | Dart | 59 | 0 | 8 | 67 |
| [lib/core/widgets/schedule\_list\_item.dart](/lib/core/widgets/schedule_list_item.dart) | Dart | 200 | 10 | 16 | 226 |
| [lib/core/widgets/search\_bar.dart](/lib/core/widgets/search_bar.dart) | Dart | 138 | 9 | 14 | 161 |
| [lib/core/widgets/sort\_button.dart](/lib/core/widgets/sort_button.dart) | Dart | 164 | 7 | 9 | 180 |
| [lib/features/devices/data/enums/devices\_enums.dart](/lib/features/devices/data/enums/devices_enums.dart) | Dart | 4 | 2 | 4 | 10 |
| [lib/features/devices/data/enums/schedule\_enums.dart](/lib/features/devices/data/enums/schedule_enums.dart) | Dart | -2 | -2 | -2 | -6 |
| [lib/features/devices/data/models/device\_model.dart](/lib/features/devices/data/models/device_model.dart) | Dart | 5 | 0 | 0 | 5 |
| [lib/features/devices/data/models/history\_sensor\_model.dart](/lib/features/devices/data/models/history_sensor_model.dart) | Dart | -1 | 0 | -2 | -3 |
| [lib/features/devices/data/models/history\_watering\_model.dart](/lib/features/devices/data/models/history_watering_model.dart) | Dart | -30 | 0 | -6 | -36 |
| [lib/features/devices/data/models/schedule\_model.dart](/lib/features/devices/data/models/schedule_model.dart) | Dart | -86 | -1 | -8 | -95 |
| [lib/features/devices/data/source/device\_remote.dart](/lib/features/devices/data/source/device_remote.dart) | Dart | 27 | 0 | 0 | 27 |
| [lib/features/devices/domain/repository/device\_repository.dart](/lib/features/devices/domain/repository/device_repository.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/devices/domain/repository/device\_repository\_impl.dart](/lib/features/devices/domain/repository/device_repository_impl.dart) | Dart | 13 | 0 | -1 | 12 |
| [lib/features/devices/presentation/screens/all\_devices\_screen.dart](/lib/features/devices/presentation/screens/all_devices_screen.dart) | Dart | 198 | -2 | 17 | 213 |
| [lib/features/devices/presentation/screens/analytics\_tab\_screen.dart](/lib/features/devices/presentation/screens/analytics_tab_screen.dart) | Dart | 52 | 26 | 0 | 78 |
| [lib/features/devices/presentation/screens/control\_tab\_screen.dart](/lib/features/devices/presentation/screens/control_tab_screen.dart) | Dart | 54 | 10 | 10 | 74 |
| [lib/features/devices/presentation/screens/device\_detail\_screen.dart](/lib/features/devices/presentation/screens/device_detail_screen.dart) | Dart | -8 | 4 | 0 | -4 |
| [lib/features/devices/presentation/screens/schedule\_tab\_screen.dart](/lib/features/devices/presentation/screens/schedule_tab_screen.dart) | Dart | 15 | 0 | 0 | 15 |
| [lib/features/devices/presentation/widgets/add\_new\_device.dart](/lib/features/devices/presentation/widgets/add_new_device.dart) | Dart | 28 | 0 | 1 | 29 |
| [lib/features/devices/presentation/widgets/device\_grid\_item.dart](/lib/features/devices/presentation/widgets/device_grid_item.dart) | Dart | 191 | 3 | 9 | 203 |
| [lib/features/devices/presentation/widgets/edit\_schedule\_sheet.dart](/lib/features/devices/presentation/widgets/edit_schedule_sheet.dart) | Dart | -431 | -3 | -30 | -464 |
| [lib/features/devices/presentation/widgets/history\_watering\_data\_table.dart](/lib/features/devices/presentation/widgets/history_watering_data_table.dart) | Dart | -59 | 0 | -8 | -67 |
| [lib/features/devices/presentation/widgets/schedule\_list\_item.dart](/lib/features/devices/presentation/widgets/schedule_list_item.dart) | Dart | -200 | -10 | -16 | -226 |
| [lib/features/devices/providers/all\_devices/devices\_provider.dart](/lib/features/devices/providers/all_devices/devices_provider.dart) | Dart | 14 | 0 | 0 | 14 |
| [lib/features/devices/providers/all\_devices/devices\_state.dart](/lib/features/devices/providers/all_devices/devices_state.dart) | Dart | 5 | 1 | 2 | 8 |
| [lib/features/devices/providers/all\_devices/realtime\_devices\_provider.dart](/lib/features/devices/providers/all_devices/realtime_devices_provider.dart) | Dart | 142 | 5 | 25 | 172 |
| [lib/features/devices/providers/device/device\_state.dart](/lib/features/devices/providers/device/device_state.dart) | Dart | 0 | 0 | -1 | -1 |
| [lib/features/devices/providers/device/get\_history\_provider.dart](/lib/features/devices/providers/device/get_history_provider.dart) | Dart | 0 | -1 | -1 | -2 |
| [lib/features/devices/providers/device/realtime\_device\_provider.dart](/lib/features/devices/providers/device/realtime_device_provider.dart) | Dart | -41 | 42 | 0 | 1 |
| [lib/features/groups/data/models/group\_model.dart](/lib/features/groups/data/models/group_model.dart) | Dart | 44 | 0 | 7 | 51 |
| [lib/features/groups/data/source/group\_remote.dart](/lib/features/groups/data/source/group_remote.dart) | Dart | 436 | 0 | 20 | 456 |
| [lib/features/groups/domain/repository/group\_repository.dart](/lib/features/groups/domain/repository/group_repository.dart) | Dart | 43 | 0 | 2 | 45 |
| [lib/features/groups/domain/repository/group\_repository\_impl.dart](/lib/features/groups/domain/repository/group_repository_impl.dart) | Dart | 237 | 0 | 16 | 253 |
| [lib/features/groups/domain/repository/group\_repository\_provider.dart](/lib/features/groups/domain/repository/group_repository_provider.dart) | Dart | 12 | 0 | 4 | 16 |
| [lib/features/groups/presentation/screens/all\_groups\_screen.dart](/lib/features/groups/presentation/screens/all_groups_screen.dart) | Dart | 263 | 3 | 24 | 290 |
| [lib/features/groups/presentation/screens/group\_control\_tab\_screen.dart](/lib/features/groups/presentation/screens/group_control_tab_screen.dart) | Dart | 307 | 9 | 24 | 340 |
| [lib/features/groups/presentation/screens/group\_detail\_screen.dart](/lib/features/groups/presentation/screens/group_detail_screen.dart) | Dart | 144 | 1 | 12 | 157 |
| [lib/features/groups/presentation/screens/group\_devices\_tab\_screen.dart](/lib/features/groups/presentation/screens/group_devices_tab_screen.dart) | Dart | 171 | 0 | 12 | 183 |
| [lib/features/groups/presentation/screens/group\_schedule\_tab\_screen.dart](/lib/features/groups/presentation/screens/group_schedule_tab_screen.dart) | Dart | 238 | 0 | 14 | 252 |
| [lib/features/groups/presentation/widgets/add\_or\_edit\_group.dart](/lib/features/groups/presentation/widgets/add_or_edit_group.dart) | Dart | 384 | 14 | 42 | 440 |
| [lib/features/groups/presentation/widgets/group\_grid\_item.dart](/lib/features/groups/presentation/widgets/group_grid_item.dart) | Dart | 126 | 38 | 7 | 171 |
| [lib/features/groups/providers/all\_groups/groups\_provider.dart](/lib/features/groups/providers/all_groups/groups_provider.dart) | Dart | 84 | 3 | 10 | 97 |
| [lib/features/groups/providers/all\_groups/groups\_state.dart](/lib/features/groups/providers/all_groups/groups_state.dart) | Dart | 32 | 1 | 9 | 42 |
| [lib/features/groups/providers/group/get\_history\_provider.dart](/lib/features/groups/providers/group/get_history_provider.dart) | Dart | 36 | 0 | 8 | 44 |
| [lib/features/groups/providers/group/group\_provider.dart](/lib/features/groups/providers/group/group_provider.dart) | Dart | 136 | 8 | 19 | 163 |
| [lib/features/groups/providers/group/group\_state.dart](/lib/features/groups/providers/group/group_state.dart) | Dart | 33 | 0 | 6 | 39 |
| [lib/features/groups/providers/group/schedule\_provider.dart](/lib/features/groups/providers/group/schedule_provider.dart) | Dart | 158 | 9 | 22 | 189 |
| [lib/main.dart](/lib/main.dart) | Dart | 0 | -2 | 0 | -2 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details