import 'package:flutter_template/domain/entities/todo/todo_entity.dart';
import 'package:flutter_template/domain/repositories/todo/todo_repository.dart';
import 'package:injectable/injectable.dart';

@injectable
class GetTodoUseCase {
  final TodoRepository _todoRepository;

  GetTodoUseCase(this._todoRepository);

  Future<TodoEntity> run() async {
    return _todoRepository.getTodo();
  }
}
