part of 'settings_cubit.dart';

@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    TodoEntity? todoEntity,
    @Default(BaseStatus.initial()) BaseStatus initStatus,
  }) = _SettingsState;
}
