import 'package:flutter_template/domain/entities/todo/todo_entity.dart';
import 'package:flutter_template/domain/services/todo/todo_service.dart';
import 'package:injectable/injectable.dart';

@injectable
final class GetTodoUseCase {
  final TodoService _todoService;

  GetTodoUseCase(this._todoService);

  Future<TodoEntity> run() async {
    return _todoService.getTodo();
  }
}
