import 'package:flutter_template/data/remappers/todo_remapper.dart';
import 'package:flutter_template/data/repositories/todo/todo_repository_impl.dart';
import 'package:flutter_template/data/response_objects/todo_response/todo_response.dart';
import 'package:flutter_template/data/services/todo/source/remote/todo_remote_data_source.dart';
import 'package:flutter_template/domain/entities/todo/todo_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockTodoRemoteDataSource extends Mock implements TodoRemoteDataSource {}

class MockTodoRemapper extends Mock implements TodoRemapper {}

void main() {
  late MockTodoRemoteDataSource mockRemoteDataSource;
  late MockTodoRemapper mockRemapper;
  late TodoRepositoryImpl sut;

  setUp(() {
    mockRemoteDataSource = MockTodoRemoteDataSource();
    mockRemapper = MockTodoRemapper();
    sut = TodoRepositoryImpl(mockRemoteDataSource, mockRemapper);
  });

  group('getTodo', () {
    const tResponse = TodoResponse(
      userId: 1,
      id: 1,
      title: 'Test Todo',
      completed: false,
    );
    const tEntity = TodoEntity(
      userId: 1,
      id: 1,
      title: 'Test Todo',
      completed: false,
    );

    test('returns TodoEntity on success', () async {
      when(() => mockRemoteDataSource.getTodo()).thenAnswer((_) async => tResponse);
      when(() => mockRemapper.toTodoEntity(tResponse)).thenReturn(tEntity);

      final result = await sut.getTodo();

      expect(result, equals(tEntity));
      verify(() => mockRemoteDataSource.getTodo()).called(1);
      verify(() => mockRemapper.toTodoEntity(tResponse)).called(1);
    });

    test('throws exception on data source failure', () async {
      when(() => mockRemoteDataSource.getTodo()).thenThrow(Exception('Network error'));

      expect(() => sut.getTodo(), throwsException);
    });
  });
}
