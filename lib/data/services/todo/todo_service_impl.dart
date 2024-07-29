import 'package:flutter_template/data/services/todo/source/remote/todo_remote_data_source.dart';
import 'package:flutter_template/domain/entities/todo/todo_entity.dart';
import 'package:flutter_template/domain/services/todo/todo_service.dart';
import 'package:injectable/injectable.dart';

@Injectable(as: TodoService)
class TodoServiceImpl implements TodoService {
  final TodoRemoteDataSource _todoRemoteDataSource;

  TodoServiceImpl(this._todoRemoteDataSource);

  @override
  Future<TodoEntity> getTodo() async {
    final respnse = await _todoRemoteDataSource.getTodo();
    return respnse;
  }
}
