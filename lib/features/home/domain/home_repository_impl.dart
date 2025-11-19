import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watering_app/features/home/data/models/article_model.dart';
import 'package:watering_app/features/home/data/source/home_remote.dart';
import 'package:watering_app/features/home/domain/home_repository.dart';

class HomeRepositoryImpl extends HomeRepository {
  HomeRemoteDataSource homeRemoteDataSource;

  HomeRepositoryImpl(this.homeRemoteDataSource);

  @override
  Future<Either<DioException, Response>> getDevicesQuantity() async {
    final response = await homeRemoteDataSource.getDevicesQuantity();
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) {
        return Right(res);
      },
    );
  }

  @override
  Future<Either<DioException, Response>> getOnlineDevicesQuantity() async {
    final response = await homeRemoteDataSource.getOnlineDevicesQuantity();
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (res) {
        return Right(res);
      },
    );
  }

  @override
  Future<Either<DioException, List<Article>>> getArticles() async {
    final response = await homeRemoteDataSource.getArticles();
    return response.fold(
      (exception) {
        return Left(exception);
      },
      (listArticles) {
        return Right(listArticles);
      },
    );
  }
}
