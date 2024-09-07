import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_template/presentation/features/home/cubit/home_cubit.dart';
import 'package:flutter_template/presentation/widgets/text/app_text.dart';

class HomeBody extends StatelessWidget {
  const HomeBody({super.key});

  @override
  Widget build(BuildContext context) {
    final name = context.select((HomeCubit cubit) => cubit.state.name);

    return Scaffold(
      body: Center(
        child: AppText.header1('Hello $name!'),
      ),
    );
  }
}
