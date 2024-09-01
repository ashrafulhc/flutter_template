import 'package:flutter_template/data/response_objects/todo_response/todo_response.dart';
import 'package:flutter_template/domain/entities/todo/todo_entity.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class TodoRemapper {
  TodoEntity toTodoEntity(TodoResponse response) {
    final todoEntity = TodoEntity(
      userId: response.userId,
      id: response.id,
      title: response.title,
      completed: response.completed,
    );

    return todoEntity;
  }
}
