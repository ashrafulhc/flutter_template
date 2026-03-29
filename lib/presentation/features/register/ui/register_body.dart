import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/presentation/features/register/cubit/register_cubit.dart';
import 'package:flutter_template/presentation/routes/app_router.dart';
import 'package:go_router/go_router.dart';

class RegisterBody extends StatelessWidget {
  const RegisterBody({super.key});

  @override
  Widget build(BuildContext context) {
    final emailError =
        context.select((RegisterCubit c) => c.state.emailError);
    final passwordError =
        context.select((RegisterCubit c) => c.state.passwordError);
    final confirmPasswordError =
        context.select((RegisterCubit c) => c.state.confirmPasswordError);

    return BlocListener<RegisterCubit, RegisterState>(
      listenWhen: (previous, current) =>
          previous.initStatus != current.initStatus,
      listener: (context, state) {
        if (state.initStatus.isSuccess) {
          context.go('${AppRoutes.main}/${AppRoutes.home}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Register'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                keyboardType: TextInputType.emailAddress,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Enter email',
                  errorText: emailError,
                ),
                onChanged: (value) =>
                    context.read<RegisterCubit>().onEmailChanged(value),
              ),
              const SizedBox(height: 8),
              TextField(
                obscureText: true,
                textInputAction: TextInputAction.next,
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  errorText: passwordError,
                ),
                onChanged: (value) =>
                    context.read<RegisterCubit>().onPasswordChanged(value),
              ),
              const SizedBox(height: 8),
              TextField(
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Confirm password',
                  errorText: confirmPasswordError,
                ),
                onChanged: (value) =>
                    context.read<RegisterCubit>().onConfirmPasswordChanged(value),
              ),
              const SizedBox(height: 20),
              BlocBuilder<RegisterCubit, RegisterState>(
                buildWhen: (prev, curr) => prev.initStatus != curr.initStatus,
                builder: (context, state) {
                  final isLoading = state.initStatus.isLoading;
                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => context.read<RegisterCubit>().onSubmit(),
                    child: Text(
                      isLoading ? 'Loading...' : 'Register',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Already have an account? Login'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
