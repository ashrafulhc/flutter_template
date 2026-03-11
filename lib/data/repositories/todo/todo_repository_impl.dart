import 'package:flutter_template/data/remappers/todo_remapper.dart';
import 'package:flutter_template/data/services/todo/source/remote/todo_remote_data_source.dart';
import 'package:flutter_template/domain/entities/todo/todo_entity.dart';
import 'package:flutter_template/domain/repositories/todo/todo_repository.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TodoRepository)
class TodoRepositoryImpl implements TodoRepository {
  final TodoRemoteDataSource _todoRemoteDataSource;
  final TodoRemapper _todoRemapper;

  TodoRepositoryImpl(
    this._todoRemoteDataSource,
    this._todoRemapper,
  );

  @override
  Future<TodoEntity> getTodo() async {
    final response = await _todoRemoteDataSource.getTodo();
    final todoEntity = _todoRemapper.toTodoEntity(response);
    return todoEntity;
  }
}
