import 'package:flutter_riverpod/legacy.dart';
import 'package:stomp_dart_client/stomp_dart_client.dart';
import 'package:watering_app/core/utils/websocket_service.dart';
import 'package:watering_app/features/devices/data/models/history_sensor_model.dart';

class RealtimeSensorNotifier extends StateNotifier<HistorySensor?> {
  RealtimeSensorNotifier(this.deviceId): super(null){
    _subscribe();
  }

  final String deviceId;
  StompUnsubscribeTopic? _unsubscribe;

  void _subscribe() {
    WebSocketService().connect();
    

  }


  
}