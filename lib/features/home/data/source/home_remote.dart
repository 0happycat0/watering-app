import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watering_app/core/constants/api_path.dart';
import 'package:watering_app/core/network/dio_network_service.dart';
import 'package:watering_app/features/home/data/models/article_model.dart';

class HomeRemoteDataSource {
  final DioNetworkService networkService;
  final DioNetworkService newsNetworkService;

  HomeRemoteDataSource(this.networkService, this.newsNetworkService);

  Future<Either<DioException, Response>> getDevicesQuantity() async {
    try {
      final result = await networkService.get(
        endpoint: ApiPath.device.getDevicesQuantity,
      );
      return result.fold(
        (exception) {
          return Left(exception);
        },
        (response) {
          return Right(response);
        },
      );
    } catch (e) {
      print('Loi khac (getDevicesQuantity) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, Response>> getOnlineDevicesQuantity() async {
    try {
      final result = await networkService.get(
        endpoint: ApiPath.device.getOnlineDevicesQuantity,
      );
      return result.fold(
        (exception) {
          return Left(exception);
        },
        (response) {
          return Right(response);
        },
      );
    } catch (e) {
      print('Loi khac (getOnlineDevicesQuantity) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }

  Future<Either<DioException, List<Article>>> getArticles() async {
    print('fetching articles data...');
    try {
      final result = await newsNetworkService.get(
        endpoint: ApiPath.news.getArticles,
      );
      return result.fold(
        (exception) {
          return Left(exception);
        },
        (response) {
          final List<dynamic> listData = response.data['items'];
          final List<Article> listArticles = listData
              .map((articleJson) => Article.fromJson(articleJson))
              .toList();
          return Right(listArticles);
        },
      );
    } catch (e) {
      print('Loi khac (getArticles) $e');
      return Left(
        DioException(
          requestOptions: RequestOptions(),
          message: 'Unknown exception',
        ),
      );
    }
  }
}
