import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_template/domain/common/base_status/base_status.dart';
import 'package:flutter_template/domain/entities/todo/todo_entity.dart';
import 'package:flutter_template/domain/usecases/todo/get_todo_use_case.dart';
import 'package:flutter_template/presentation/features/settings/cubit/settings_cubit.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockGetTodoUseCase extends Mock implements GetTodoUseCase {}

void main() {
  late MockGetTodoUseCase mockGetTodoUseCase;

  setUp(() {
    mockGetTodoUseCase = MockGetTodoUseCase();
  });

  group('SettingsCubit', () {
    const tEntity = TodoEntity(
      userId: 1,
      id: 1,
      title: 'Test Todo',
      completed: false,
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits [loading, success] when getTodo succeeds',
      build: () {
        when(() => mockGetTodoUseCase.run()).thenAnswer((_) async => tEntity);
        return SettingsCubit(mockGetTodoUseCase);
      },
      act: (cubit) => cubit.getTodo(),
      expect: () => [
        const SettingsState(initStatus: BaseStatus.loading()),
        const SettingsState(
          initStatus: BaseStatus.success(),
          todoEntity: tEntity,
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'emits [loading, failure] when getTodo throws',
      build: () {
        when(() => mockGetTodoUseCase.run()).thenThrow(Exception('error'));
        return SettingsCubit(mockGetTodoUseCase);
      },
      act: (cubit) => cubit.getTodo(),
      expect: () => [
        const SettingsState(initStatus: BaseStatus.loading()),
        isA<SettingsState>().having(
          (s) => s.initStatus,
          'initStatus',
          isA<Failure<dynamic>>(),
        ),
      ],
    );

    blocTest<SettingsCubit, SettingsState>(
      'does not emit when already loading',
      build: () => SettingsCubit(mockGetTodoUseCase),
      seed: () => const SettingsState(initStatus: BaseStatus.loading()),
      act: (cubit) => cubit.getTodo(),
      expect: () => [],
    );
  });
}
