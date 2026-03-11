import 'package:flutter_template/domain/entities/todo/todo_entity.dart';
import 'package:flutter_template/domain/repositories/todo/todo_repository.dart';
import 'package:flutter_template/domain/usecases/todo/get_todo_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTodoRepository extends Mock implements TodoRepository {}

void main() {
  late MockTodoRepository mockRepository;
  late GetTodoUseCase sut;

  setUp(() {
    mockRepository = MockTodoRepository();
    sut = GetTodoUseCase(mockRepository);
  });

  group('run', () {
    const tEntity = TodoEntity(
      userId: 1,
      id: 1,
      title: 'Test Todo',
      completed: false,
    );

    test('calls repository.getTodo and returns entity', () async {
      when(() => mockRepository.getTodo()).thenAnswer((_) async => tEntity);

      final result = await sut.run();

      expect(result, equals(tEntity));
      verify(() => mockRepository.getTodo()).called(1);
    });
  });
}
