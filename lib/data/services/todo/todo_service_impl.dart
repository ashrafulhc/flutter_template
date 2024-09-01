import 'package:flutter_template/data/remappers/todo_remapper.dart';
import 'package:flutter_template/data/services/todo/source/remote/todo_remote_data_source.dart';
import 'package:flutter_template/domain/entities/todo/todo_entity.dart';
import 'package:flutter_template/domain/services/todo/todo_service.dart';
import 'package:injectable/injectable.dart';

@LazySingleton(as: TodoService)
class TodoServiceImpl implements TodoService {
  final TodoRemoteDataSource _todoRemoteDataSource;
  final TodoRemapper _todoRemapper;

  TodoServiceImpl(
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
