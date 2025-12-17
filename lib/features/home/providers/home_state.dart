import 'package:dio/dio.dart';
import 'package:watering_app/features/home/data/models/article_model.dart';

sealed class HomeState {
  const HomeState();
}

class Initial extends HomeState {
  const Initial();
}

class Loading extends HomeState {
  const Loading();
}

class Success extends HomeState {
  const Success({this.devicesQuantity, this.onlineDevicesQuantity, this.articlesList});

  final int? devicesQuantity;
  final int? onlineDevicesQuantity;
  final List<Article>? articlesList;
}

class Failure extends HomeState {
  const Failure(this.exception);
  final DioException exception;
  String get message {
    switch (exception.message) {
      case 'Internal Server Error':
        return 'Lỗi máy chủ. Vui lòng thử lại';
      default:
        return 'Có lỗi xảy ra';
    }
  }
}
