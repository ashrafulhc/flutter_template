part of 'home_cubit.dart';

@freezed
class HomeState with _$HomeState {
  const factory HomeState({
    @Default(BaseStatus.initial()) BaseStatus initStatus,
    @Default('Ashraful') String name,
  }) = _HomeState;
}
