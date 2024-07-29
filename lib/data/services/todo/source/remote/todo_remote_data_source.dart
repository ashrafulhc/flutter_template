import 'package:dio/dio.dart';
import 'package:flutter_template/domain/entities/todo/todo_entity.dart';
import 'package:flutter_template/injection/network_module.dart';
import 'package:injectable/injectable.dart';
import 'package:retrofit/retrofit.dart';

part 'todo_remote_data_source.g.dart';

@RestApi()
@lazySingleton
abstract class TodoRemoteDataSource {
  @factoryMethod
  factory TodoRemoteDataSource(
    @Named(dioClient) Dio dio,
  ) = _TodoRemoteDataSource;

  @GET('/todos/1')
  Future<TodoEntity> getTodo();
}
