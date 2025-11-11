import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_symbols_icons/symbols.dart';
import 'package:watering_app/core/constants/app_colors.dart';
import 'package:watering_app/core/constants/app_strings.dart';
import 'package:watering_app/core/widgets/custom_app_bar.dart';
import 'package:watering_app/core/widgets/custom_snack_bar.dart';
import 'package:watering_app/core/widgets/search_bar.dart';
import 'package:watering_app/features/groups/data/models/group_model.dart';
import 'package:watering_app/features/groups/presentation/screens/group_detail_screen.dart';
import 'package:watering_app/features/groups/presentation/widgets/add_or_edit_group.dart';
import 'package:watering_app/features/groups/providers/all_groups/groups_provider.dart';
import 'package:watering_app/features/groups/presentation/widgets/group_grid_item.dart';
import 'package:watering_app/features/groups/providers/all_groups/groups_state.dart'
    as groups_state;
import 'package:watering_app/features/groups/providers/group/group_provider.dart';
import 'package:watering_app/theme/styles.dart';

class AllGroupsScreen extends ConsumerStatefulWidget {
  const AllGroupsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AllGroupsScreenState();
}

class _AllGroupsScreenState extends ConsumerState<AllGroupsScreen> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();

  String? _currentSearchQuery = '';
  Timer? _debounceTimer;

  void _unfocusSearch() {
    if (_searchFocusNode.hasFocus) {
      _searchFocusNode.unfocus();
    }
  }

  void _onSearchChanged(String query) {
    // Hủy timer đang chạy
    if (_debounceTimer?.isActive ?? false) {
      _debounceTimer!.cancel();
    }

    // Sử dụng timer để delay gọi api khi gõ liên tục
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      ref
          .read(groupsProvider.notifier)
          .getAllGroups(name: query == '' ? null : query);
      _currentSearchQuery = query;
    });
  }

  void _onSearchSubmitted(String query) {
    ref.read(groupsProvider.notifier).getAllGroups(name: query);
  }

  void _onSelectGroup(Group group) {
    Navigator.of(context).push(
      CupertinoPageRoute(
        builder: (ctx) => GroupDetailScreen(group: group),
      ),
    );
  }

  void _showAskDeleteDialog(Group group) {
    final deleteGroupNotifier = ref.read(deleteGroupProvider.notifier);
    final groupsNotifier = ref.read(groupsProvider.notifier);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('Xóa nhóm'),
        content: Text(
          'Bạn có muốn xóa nhóm "${group.name}" không?',
        ),
        actions: [
          OutlinedButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Hủy'),
          ),
          FilledButton(
            onPressed: () async {
              Navigator.of(context).pop();
              groupsNotifier.setLoading();
              await deleteGroupNotifier.deleteGroup(id: group.id);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  CustomSnackBar(text: 'Đã xóa nhóm "${group.name}"'),
                );
                groupsNotifier.getAllGroups(name: _currentSearchQuery);
              }
            },
            child: Text('Xóa'),
          ),
        ],
      ),
    );
  }

  void _showEditDialog(Group group) async {
    final isSuccess = await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      barrierColor: AppColors.mainGreen[300]?.withValues(alpha: 0.5),
      clipBehavior: Clip.antiAlias,
      builder: (ctx) {
        return AddOrEditGroup(groupToEdit: group);
      },
    );

    if (isSuccess && mounted) {
      ref.read(groupsProvider.notifier).getAllGroups(name: _currentSearchQuery);
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      if (!mounted) return;
      ref.read(groupsProvider.notifier).getAllGroups();
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupsState = ref.watch(groupsProvider);

    ref.listen(shouldResetGroupSearchProvider, (prev, next) {
      if (next == true) {
        _currentSearchQuery = '';
        ref.read(shouldResetGroupSearchProvider.notifier).state = false;
      }
    });
    ref.listen(shouldRefreshGroupsListProvider, (prev, next) {
      if (next == true) {
        ref
            .read(groupsProvider.notifier)
            .getAllGroups(
              name: _currentSearchQuery,
            );
        ref.read(shouldRefreshGroupsListProvider.notifier).state = false;
      }
    });

    ref.watch(updateGroupProvider);
    ref.watch(deleteGroupProvider);

    ref.listen(groupsProvider, (prev, next) {
      print(
        'All groups transition: ${prev.runtimeType} -> ${next.runtimeType}',
      );
    });

    if (_currentSearchQuery == '') _currentSearchQuery = null;

    return GestureDetector(
      onTap: _unfocusSearch,
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: CustomAppBar(
          title: 'Nhóm thiết bị',
          backgroundColor: Colors.white,
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(54.0),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: CustomSearchBar(
                isGroup: true,
                controller: _searchController,
                focusNode: _searchFocusNode,
                onChanged: _onSearchChanged,
                onSubmitted: _onSearchSubmitted,
              ),
            ),
          ),
        ),
        body: Padding(
          padding: EdgeInsets.fromLTRB(8, 0, 8, 0),
          child: () {
            if (groupsState is groups_state.Loading ||
                groupsState is groups_state.Initial) {
              return Center(child: CircularProgressIndicator());
            } else if (groupsState is groups_state.Success) {
              final groups = groupsState.groupsList;

              // Hiển thị khi chưa có nhóm hoặc không tìm thấy nhóm
              if (groups.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        groupsState.isSearchResultEmpty
                            ? Symbols.search_off
                            : Symbols.variable_remove,
                        size: 64,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16),
                      Text(
                        groupsState.isSearchResultEmpty
                            ? 'Không tìm thấy nhóm "${groupsState.searchQuery}"'
                            : 'Chưa có nhóm nào',
                        style: TextStyle(fontSize: 16),
                      ),
                      if (groupsState.isSearchResultEmpty)
                        TextButton(
                          onPressed: () {
                            _searchController.clear();
                            _currentSearchQuery = '';
                            ref.read(groupsProvider.notifier).getAllGroups();
                          },
                          child: Text('Xóa tìm kiếm'),
                        ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                displacement: 40,
                edgeOffset: 0,
                onRefresh: () async {
                  await ref
                      .read(groupsProvider.notifier)
                      .getAllGroups(name: _currentSearchQuery);
                },
                child: Scrollbar(
                  interactive: true,
                  thickness: 5,
                  radius: Radius.circular(10),
                  child: GridView.builder(
                    primary: true,
                    padding: EdgeInsets.only(bottom: 42),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 5 / 4,
                      mainAxisSpacing: 0,
                      crossAxisSpacing: 0,
                    ),
                    itemCount: groups.length,
                    itemBuilder: (context, index) {
                      final group = groups[index];
                      return GroupGridItem(
                        group: group,
                        onSelectGroup: () {
                          _onSelectGroup(group);
                        },
                        onSelectDelete: () {
                          _showAskDeleteDialog(group);
                        },
                        onSelectEdit: () {
                          _showEditDialog(group);
                        },
                      );
                    },
                  ),
                ),
              );
            } else if (groupsState is groups_state.Failure) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(groupsState.message),
                    TextButton(
                      style: AppStyles.textButtonStyle,
                      onPressed: () async {
                        await ref.read(groupsProvider.notifier).refresh();
                      },
                      child: Text(AppStrings.tryAgain),
                    ),
                  ],
                ),
              );
            } else {
              return Center(child: Text("Trạng thái không xác định"));
            }
          }(),
        ),
      ),
    );
  }
}
