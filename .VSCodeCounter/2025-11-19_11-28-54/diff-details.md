# Diff Details

Date : 2025-11-19 11:28:54

Directory d:\\VSCode\\Flutter\\watering_app\\lib

Total : 70 files,  3514 codes, 126 comments, 266 blanks, all 3906 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [lib/core/app.dart](/lib/core/app.dart) | Dart | 11 | 2 | 1 | 14 |
| [lib/core/app\_lifecycle\_observer.dart](/lib/core/app_lifecycle_observer.dart) | Dart | 51 | 11 | 9 | 71 |
| [lib/core/constants/api\_path.dart](/lib/core/constants/api_path.dart) | Dart | 5 | 0 | 2 | 7 |
| [lib/core/constants/api\_strings.dart](/lib/core/constants/api_strings.dart) | Dart | 4 | 0 | 1 | 5 |
| [lib/core/constants/app\_colors.dart](/lib/core/constants/app_colors.dart) | Dart | 9 | 0 | 0 | 9 |
| [lib/core/constants/app\_strings.dart](/lib/core/constants/app_strings.dart) | Dart | 1 | 0 | 1 | 2 |
| [lib/core/constants/shared\_preference\_key.dart](/lib/core/constants/shared_preference_key.dart) | Dart | 3 | 0 | 0 | 3 |
| [lib/core/constants/stomp\_path.dart](/lib/core/constants/stomp_path.dart) | Dart | 1 | 0 | 2 | 3 |
| [lib/core/data/models/schedule\_model.dart](/lib/core/data/models/schedule_model.dart) | Dart | 7 | 0 | 0 | 7 |
| [lib/core/main\_scaffold.dart](/lib/core/main_scaffold.dart) | Dart | -13 | -1 | 0 | -14 |
| [lib/core/network/stomp\_service.dart](/lib/core/network/stomp_service.dart) | Dart | 253 | 35 | 62 | 350 |
| [lib/core/network/stomp\_service\_provider.dart](/lib/core/network/stomp_service_provider.dart) | Dart | 5 | 0 | 1 | 6 |
| [lib/core/utils/stomp\_service.dart](/lib/core/utils/stomp_service.dart) | Dart | -246 | -35 | -59 | -340 |
| [lib/core/widgets/custom\_app\_bar.dart](/lib/core/widgets/custom_app_bar.dart) | Dart | 29 | 0 | 0 | 29 |
| [lib/core/widgets/custom\_snack\_bar.dart](/lib/core/widgets/custom_snack_bar.dart) | Dart | 35 | 0 | 0 | 35 |
| [lib/core/widgets/edit\_schedule\_sheet.dart](/lib/core/widgets/edit_schedule_sheet.dart) | Dart | -26 | 0 | 0 | -26 |
| [lib/core/widgets/icons/back\_icon.dart](/lib/core/widgets/icons/back_icon.dart) | Dart | 1 | 0 | 1 | 2 |
| [lib/core/widgets/text\_form\_field/normal\_text\_form\_field.dart](/lib/core/widgets/text_form_field/normal_text_form_field.dart) | Dart | 3 | 0 | 0 | 3 |
| [lib/core/widgets/text\_form\_field/password\_text\_form\_field.dart](/lib/core/widgets/text_form_field/password_text_form_field.dart) | Dart | 10 | 0 | 0 | 10 |
| [lib/features/authentication/data/source/auth\_local.dart](/lib/features/authentication/data/source/auth_local.dart) | Dart | 18 | 0 | 5 | 23 |
| [lib/features/authentication/data/source/auth\_remote.dart](/lib/features/authentication/data/source/auth_remote.dart) | Dart | 90 | 2 | 4 | 96 |
| [lib/features/authentication/domain/repository/auth\_repository.dart](/lib/features/authentication/domain/repository/auth_repository.dart) | Dart | 15 | 0 | 0 | 15 |
| [lib/features/authentication/domain/repository/auth\_repository\_impl.dart](/lib/features/authentication/domain/repository/auth_repository_impl.dart) | Dart | 98 | 1 | 7 | 106 |
| [lib/features/authentication/presentation/screens/account\_screen.dart](/lib/features/authentication/presentation/screens/account_screen.dart) | Dart | 229 | 51 | 9 | 289 |
| [lib/features/authentication/presentation/screens/change\_password\_screen.dart](/lib/features/authentication/presentation/screens/change_password_screen.dart) | Dart | 420 | 10 | 33 | 463 |
| [lib/features/authentication/presentation/screens/login\_screen.dart](/lib/features/authentication/presentation/screens/login_screen.dart) | Dart | 4 | 2 | 0 | 6 |
| [lib/features/authentication/presentation/screens/new\_password\_screen.dart](/lib/features/authentication/presentation/screens/new_password_screen.dart) | Dart | 221 | 4 | 21 | 246 |
| [lib/features/authentication/presentation/screens/signup\_screen.dart](/lib/features/authentication/presentation/screens/signup_screen.dart) | Dart | 32 | 0 | 4 | 36 |
| [lib/features/authentication/presentation/screens/verify\_email\_screen.dart](/lib/features/authentication/presentation/screens/verify_email_screen.dart) | Dart | 442 | 11 | 31 | 484 |
| [lib/features/authentication/providers/auth\_provider.dart](/lib/features/authentication/providers/auth_provider.dart) | Dart | 106 | 17 | 12 | 135 |
| [lib/features/authentication/providers/auth\_state.dart](/lib/features/authentication/providers/auth_state.dart) | Dart | 38 | 0 | 3 | 41 |
| [lib/features/devices/data/models/device\_model.dart](/lib/features/devices/data/models/device_model.dart) | Dart | 8 | 0 | 0 | 8 |
| [lib/features/devices/presentation/screens/all\_devices\_screen.dart](/lib/features/devices/presentation/screens/all_devices_screen.dart) | Dart | -2 | 0 | 0 | -2 |
| [lib/features/devices/presentation/screens/control\_tab\_screen.dart](/lib/features/devices/presentation/screens/control_tab_screen.dart) | Dart | -4 | 0 | 0 | -4 |
| [lib/features/devices/presentation/screens/device\_detail\_screen.dart](/lib/features/devices/presentation/screens/device_detail_screen.dart) | Dart | 4 | 0 | 0 | 4 |
| [lib/features/devices/presentation/screens/schedule\_tab\_screen.dart](/lib/features/devices/presentation/screens/schedule_tab_screen.dart) | Dart | 8 | 0 | 0 | 8 |
| [lib/features/devices/presentation/widgets/add\_new\_device.dart](/lib/features/devices/presentation/widgets/add_new_device.dart) | Dart | -1 | 0 | 0 | -1 |
| [lib/features/devices/presentation/widgets/device\_grid\_item.dart](/lib/features/devices/presentation/widgets/device_grid_item.dart) | Dart | 0 | 2 | -1 | 1 |
| [lib/features/devices/providers/all\_devices/devices\_provider.dart](/lib/features/devices/providers/all_devices/devices_provider.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/devices/providers/all\_devices/realtime\_devices\_provider.dart](/lib/features/devices/providers/all_devices/realtime_devices_provider.dart) | Dart | 16 | 0 | 0 | 16 |
| [lib/features/devices/providers/device/device\_provider.dart](/lib/features/devices/providers/device/device_provider.dart) | Dart | 3 | 0 | -2 | 1 |
| [lib/features/devices/providers/device/get\_history\_provider.dart](/lib/features/devices/providers/device/get_history_provider.dart) | Dart | 2 | 0 | -2 | 0 |
| [lib/features/devices/providers/device/schedule\_provider.dart](/lib/features/devices/providers/device/schedule_provider.dart) | Dart | 3 | 0 | 0 | 3 |
| [lib/features/groups/data/models/group\_model.dart](/lib/features/groups/data/models/group_model.dart) | Dart | 10 | 0 | -1 | 9 |
| [lib/features/groups/data/source/group\_remote.dart](/lib/features/groups/data/source/group_remote.dart) | Dart | 0 | 0 | -1 | -1 |
| [lib/features/groups/domain/repository/group\_repository\_impl.dart](/lib/features/groups/domain/repository/group_repository_impl.dart) | Dart | 4 | 0 | 0 | 4 |
| [lib/features/groups/presentation/screens/all\_groups\_screen.dart](/lib/features/groups/presentation/screens/all_groups_screen.dart) | Dart | 22 | 0 | 1 | 23 |
| [lib/features/groups/presentation/screens/group\_control\_tab\_screen.dart](/lib/features/groups/presentation/screens/group_control_tab_screen.dart) | Dart | 35 | 8 | 2 | 45 |
| [lib/features/groups/presentation/screens/group\_detail\_screen.dart](/lib/features/groups/presentation/screens/group_detail_screen.dart) | Dart | -4 | 0 | 1 | -3 |
| [lib/features/groups/presentation/screens/group\_devices\_tab\_screen.dart](/lib/features/groups/presentation/screens/group_devices_tab_screen.dart) | Dart | 52 | 3 | 0 | 55 |
| [lib/features/groups/presentation/screens/group\_schedule\_tab\_screen.dart](/lib/features/groups/presentation/screens/group_schedule_tab_screen.dart) | Dart | -3 | 0 | 1 | -2 |
| [lib/features/groups/presentation/widgets/add\_or\_edit\_group.dart](/lib/features/groups/presentation/widgets/add_or_edit_group.dart) | Dart | 11 | 0 | 1 | 12 |
| [lib/features/groups/presentation/widgets/group\_grid\_item.dart](/lib/features/groups/presentation/widgets/group_grid_item.dart) | Dart | 104 | -35 | 0 | 69 |
| [lib/features/groups/providers/all\_groups/groups\_provider.dart](/lib/features/groups/providers/all_groups/groups_provider.dart) | Dart | 2 | 4 | 1 | 7 |
| [lib/features/groups/providers/all\_groups/realtime\_groups\_provider.dart](/lib/features/groups/providers/all_groups/realtime_groups_provider.dart) | Dart | 55 | 1 | 9 | 65 |
| [lib/features/groups/providers/group/get\_history\_provider.dart](/lib/features/groups/providers/group/get_history_provider.dart) | Dart | 8 | 0 | -2 | 6 |
| [lib/features/groups/providers/group/group\_provider.dart](/lib/features/groups/providers/group/group_provider.dart) | Dart | 4 | 0 | 0 | 4 |
| [lib/features/groups/providers/group/schedule\_provider.dart](/lib/features/groups/providers/group/schedule_provider.dart) | Dart | 3 | 0 | 0 | 3 |
| [lib/features/home/data/source/home\_remote.dart](/lib/features/home/data/source/home_remote.dart) | Dart | 54 | 0 | 5 | 59 |
| [lib/features/home/domain/home\_repository.dart](/lib/features/home/domain/home_repository.dart) | Dart | 6 | 0 | 1 | 7 |
| [lib/features/home/domain/home\_repository\_impl.dart](/lib/features/home/domain/home_repository_impl.dart) | Dart | 32 | 0 | 5 | 37 |
| [lib/features/home/domain/home\_repository\_provider.dart](/lib/features/home/domain/home_repository_provider.dart) | Dart | 12 | 0 | 3 | 15 |
| [lib/features/home/presentation/screens/home\_screen copy.dart](/lib/features/home/presentation/screens/home_screen%20copy.dart) | Dart | 234 | 8 | 19 | 261 |
| [lib/features/home/presentation/screens/home\_screen.dart](/lib/features/home/presentation/screens/home_screen.dart) | Dart | 398 | 7 | 23 | 428 |
| [lib/features/home/presentation/screens/incoming\_schedule\_screen.dart](/lib/features/home/presentation/screens/incoming_schedule_screen.dart) | Dart | 142 | 2 | 13 | 157 |
| [lib/features/home/presentation/widgets/artical\_item\_card.dart](/lib/features/home/presentation/widgets/artical_item_card.dart) | Dart | 94 | 1 | 3 | 98 |
| [lib/features/home/presentation/widgets/info\_card.dart](/lib/features/home/presentation/widgets/info_card.dart) | Dart | 157 | 0 | 11 | 168 |
| [lib/features/home/presentation/widgets/schedule\_item\_card.dart](/lib/features/home/presentation/widgets/schedule_item_card.dart) | Dart | 117 | 14 | 7 | 138 |
| [lib/features/home/providers/home\_provider.dart](/lib/features/home/providers/home_provider.dart) | Dart | 44 | 1 | 12 | 57 |
| [lib/features/home/providers/home\_state.dart](/lib/features/home/providers/home_state.dart) | Dart | 27 | 0 | 7 | 34 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details