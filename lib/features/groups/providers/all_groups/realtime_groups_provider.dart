import 'dart:convert';

import 'package:flutter_riverpod/legacy.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:watering_app/core/constants/stomp_path.dart';
import 'package:watering_app/core/network/stomp_service.dart';
import 'package:watering_app/core/network/stomp_service_provider.dart';

typedef GroupsWateringState = Map<String, bool>;

// watering (true: watering, fasle: not watering)
final groupsWateringProvider =
    StateNotifierProvider.autoDispose<
      GroupsWateringNotifier,
      GroupsWateringState
    >(
      (ref) {
        final stompService = ref.watch(stompServiceProvider);
        if (stompService == null) {
          throw Exception('StompService is null');
        }
        return GroupsWateringNotifier(stompService);
      },
    );

class GroupsWateringNotifier extends StateNotifier<GroupsWateringState> {
  StompUnsubscribeTopic? _unsubscribe;
  StompService stompService;

  GroupsWateringNotifier(this.stompService) : super({}) {
    _subscribe();
  }

  void _subscribe() {
    _unsubscribe = stompService.subscribe(
      StompPath.topic.groupsWatering,
      onMessage: (StompFrame frame) {
        if (frame.body == null) return;
        try {
          final data = jsonDecode(frame.body!);
          final String groupId = data['groupId'];
          final bool isWatering = data['isWatering'];

          if (groupId.isEmpty) return;

          state = {
            ...state,
            groupId: isWatering,
          };
        } catch (e) {
          print('[GroupsWateringNotifier] Lỗi parse JSON: $e');
        }
      },
    );
  }

  @override
  void dispose() {
    print(
      '[GroupsWateringNotifier] Đang hủy. Đang unsubscribe /user/groups/watering...',
    );
    _unsubscribe!();
    super.dispose();
  }
}