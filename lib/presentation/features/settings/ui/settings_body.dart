import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/presentation/features/_playground/playground_screen.dart';
import 'package:flutter_template/presentation/features/settings/cubit/settings_cubit.dart';
import 'package:flutter_template/presentation/routes/router.gr.dart';

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
        title: const Text('Settings'),
        actions: const [
          PlaygroundScreenOpenerButton(),
        ],
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
