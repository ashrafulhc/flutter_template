import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/presentation/features/login/cubit/login_cubit.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_template/presentation/routes/app_router.dart';

class LoginBody extends StatelessWidget {
  const LoginBody({super.key});

  @override
  Widget build(BuildContext context) {
    final emailError = context.select((LoginCubit c) => c.state.emailError);
    final passwordError =
        context.select((LoginCubit c) => c.state.passwordError);

    return BlocListener<LoginCubit, LoginState>(
      listenWhen: (previous, current) =>
          previous.initStatus != current.initStatus,
      listener: (context, state) {
        if (state.initStatus.isSuccess) {
          context.go('${AppRoutes.main}/${AppRoutes.home}');
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Login'),
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
                    context.read<LoginCubit>().onEmailChanged(value),
              ),
              const SizedBox(height: 8),
              TextField(
                obscureText: true,
                textInputAction: TextInputAction.done,
                decoration: InputDecoration(
                  hintText: 'Enter password',
                  errorText: passwordError,
                ),
                onChanged: (value) =>
                    context.read<LoginCubit>().onPasswordChanged(value),
              ),
              const SizedBox(height: 20),
              BlocBuilder<LoginCubit, LoginState>(
                buildWhen: (prev, curr) => prev.initStatus != curr.initStatus,
                builder: (context, state) {
                  final isLoading = state.initStatus.isLoading;

                  return ElevatedButton(
                    onPressed: isLoading
                        ? null
                        : () => context.read<LoginCubit>().onSubmit(),
                    child: Text(
                      isLoading ? 'Loading...' : 'Submit',
                      style: const TextStyle(color: Colors.white),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.push(AppRoutes.register),
                child: const Text("Don't have an account? Register"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
