import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/presentation/features/settings/cubit/settings_cubit.dart';
import 'package:flutter_template/presentation/resources/resources.dart';

class SettingsBody extends StatelessWidget {
  const SettingsBody({super.key});

  @override
  Widget build(BuildContext context) {
    final isLoading = context
        .select((SettingsCubit cubit) => cubit.state.initStatus.isLoading);
    final todoEntity =
        context.select((SettingsCubit cubit) => cubit.state.todoEntity);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colors.background,
        title: const Text('Settings'),
      ),
      body: Center(
        child: isLoading
            ? const CircularProgressIndicator()
            : Text(todoEntity?.title ?? 'No title'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          context.read<SettingsCubit>().getTodo();
        },
        child: const Icon(Icons.get_app),
      ),
    );
  }
}
