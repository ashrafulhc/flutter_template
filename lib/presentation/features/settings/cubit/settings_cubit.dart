import 'dart:developer';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/data/response_objects/response_error.dart';
import 'package:flutter_template/domain/entities/todo/todo_entity.dart';
import 'package:flutter_template/domain/usecases/todo/get_todo_use_case.dart';
import 'package:flutter_template/presentation/common/base_status/base_status.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:injectable/injectable.dart';

part 'settings_state.dart';
part 'settings_cubit.freezed.dart';

@injectable
class SettingsCubit extends Cubit<SettingsState> {
  SettingsCubit(this._getTodoUseCase) : super(const SettingsState());

  final GetTodoUseCase _getTodoUseCase;

  Future<void> getTodo() async {
    if (state.initStatus.isLoading) {
      return;
    }

    try {
      log('fetching todo...');

      emit(state.copyWith(initStatus: const BaseStatus.loading()));

      final result = await _getTodoUseCase.run();

      if (isClosed) {
        return;
      }

      emit(
        state.copyWith(
            initStatus: const BaseStatus.success(), todoEntity: result),
      );

      log('Successfuly Fetched');
    } catch (e, s) {
      if (isClosed) {
        return;
      }

      log('Unable to Failure message $e ---- $s');
      final error = ResponseError.from(e);
      emit(state.copyWith(initStatus: BaseStatus.failure(error)));
    }
  }
}
