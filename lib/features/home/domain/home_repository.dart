import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:watering_app/features/home/data/models/article_model.dart';

abstract class HomeRepository {
  Future<Either<Exception, Response>> getDevicesQuantity();
  Future<Either<Exception, Response>> getOnlineDevicesQuantity();
  Future<Either<Exception, List<Article>>> getArticles();
}