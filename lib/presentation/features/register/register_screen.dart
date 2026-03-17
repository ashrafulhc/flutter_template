import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/injection/injector.dart';
import 'package:flutter_template/presentation/features/register/cubit/register_cubit.dart';
import 'package:flutter_template/presentation/features/register/ui/register_body.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<RegisterCubit>(
      create: (context) => injector<RegisterCubit>(),
      child: const RegisterBody(),
    );
  }
}
