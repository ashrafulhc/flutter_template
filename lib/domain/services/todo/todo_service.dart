import 'package:flutter_template/domain/entities/todo/todo_entity.dart';

abstract interface class TodoService {
  Future<TodoEntity> getTodo();
}
