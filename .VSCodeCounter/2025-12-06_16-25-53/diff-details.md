# Diff Details

Date : 2025-12-06 16:25:53

Directory d:\\VSCode\\Flutter\\watering_app\\lib

Total : 38 files,  622 codes, 18 comments, 31 blanks, all 671 lines

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details

## Files
| filename | language | code | comment | blank | total |
| :--- | :--- | ---: | ---: | ---: | ---: |
| [lib/core/app\_lifecycle\_observer.dart](/lib/core/app_lifecycle_observer.dart) | Dart | 3 | 0 | 0 | 3 |
| [lib/core/constants/app\_strings.dart](/lib/core/constants/app_strings.dart) | Dart | 4 | 0 | 1 | 5 |
| [lib/core/main\_scaffold.dart](/lib/core/main_scaffold.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/core/network/auth\_dio\_network\_service.dart](/lib/core/network/auth_dio_network_service.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/core/network/dio\_network\_service.dart](/lib/core/network/dio_network_service.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/core/network/interceptors/auth\_interceptor.dart](/lib/core/network/interceptors/auth_interceptor.dart) | Dart | 3 | 0 | 0 | 3 |
| [lib/core/network/stomp\_service.dart](/lib/core/network/stomp_service.dart) | Dart | 10 | 0 | 0 | 10 |
| [lib/core/utils/debug\_print.dart](/lib/core/utils/debug_print.dart) | Dart | 6 | 0 | 2 | 8 |
| [lib/core/utils/notification\_service.dart](/lib/core/utils/notification_service.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/core/widgets/edit\_schedule\_sheet.dart](/lib/core/widgets/edit_schedule_sheet.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/authentication/data/source/auth\_remote.dart](/lib/features/authentication/data/source/auth_remote.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/authentication/domain/repository/auth\_repository\_impl.dart](/lib/features/authentication/domain/repository/auth_repository_impl.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/authentication/presentation/screens/account\_screen.dart](/lib/features/authentication/presentation/screens/account_screen.dart) | Dart | 41 | 1 | 2 | 44 |
| [lib/features/authentication/presentation/screens/app\_info\_screen.dart](/lib/features/authentication/presentation/screens/app_info_screen.dart) | Dart | 486 | 14 | 24 | 524 |
| [lib/features/authentication/presentation/screens/login\_screen.dart](/lib/features/authentication/presentation/screens/login_screen.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/authentication/presentation/screens/signup\_screen.dart](/lib/features/authentication/presentation/screens/signup_screen.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/authentication/providers/auth\_provider.dart](/lib/features/authentication/providers/auth_provider.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/authentication/providers/biometric\_provider.dart](/lib/features/authentication/providers/biometric_provider.dart) | Dart | 24 | 3 | 2 | 29 |
| [lib/features/devices/data/source/device\_remote.dart](/lib/features/devices/data/source/device_remote.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/devices/presentation/screens/all\_devices\_screen.dart](/lib/features/devices/presentation/screens/all_devices_screen.dart) | Dart | 2 | 0 | 0 | 2 |
| [lib/features/devices/presentation/screens/analytics\_tab\_screen.dart](/lib/features/devices/presentation/screens/analytics_tab_screen.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/devices/presentation/screens/device\_detail\_screen.dart](/lib/features/devices/presentation/screens/device_detail_screen.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/devices/presentation/screens/schedule\_tab\_screen.dart](/lib/features/devices/presentation/screens/schedule_tab_screen.dart) | Dart | 2 | 0 | 0 | 2 |
| [lib/features/devices/presentation/widgets/add\_new\_device.dart](/lib/features/devices/presentation/widgets/add_new_device.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/devices/providers/all\_devices/realtime\_devices\_provider.dart](/lib/features/devices/providers/all_devices/realtime_devices_provider.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/devices/providers/device/realtime\_device\_provider.dart](/lib/features/devices/providers/device/realtime_device_provider.dart) | Dart | 0 | 0 | 1 | 1 |
| [lib/features/devices/providers/device/schedule\_provider.dart](/lib/features/devices/providers/device/schedule_provider.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/groups/data/source/group\_remote.dart](/lib/features/groups/data/source/group_remote.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/groups/presentation/screens/all\_groups\_screen.dart](/lib/features/groups/presentation/screens/all_groups_screen.dart) | Dart | 2 | 0 | 0 | 2 |
| [lib/features/groups/presentation/screens/group\_detail\_screen.dart](/lib/features/groups/presentation/screens/group_detail_screen.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/groups/presentation/screens/group\_devices\_tab\_screen.dart](/lib/features/groups/presentation/screens/group_devices_tab_screen.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/groups/presentation/screens/group\_schedule\_tab\_screen.dart](/lib/features/groups/presentation/screens/group_schedule_tab_screen.dart) | Dart | 2 | 0 | 0 | 2 |
| [lib/features/groups/presentation/widgets/add\_or\_edit\_group.dart](/lib/features/groups/presentation/widgets/add_or_edit_group.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/groups/providers/all\_groups/realtime\_groups\_provider.dart](/lib/features/groups/providers/all_groups/realtime_groups_provider.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/groups/providers/group/schedule\_provider.dart](/lib/features/groups/providers/group/schedule_provider.dart) | Dart | 8 | 0 | -1 | 7 |
| [lib/features/home/data/source/home\_remote.dart](/lib/features/home/data/source/home_remote.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/home/presentation/screens/articles\_screen.dart](/lib/features/home/presentation/screens/articles_screen.dart) | Dart | 1 | 0 | 0 | 1 |
| [lib/features/home/presentation/screens/home\_screen.dart](/lib/features/home/presentation/screens/home_screen.dart) | Dart | 6 | 0 | 0 | 6 |

[Summary](results.md) / [Details](details.md) / [Diff Summary](diff.md) / Diff Details