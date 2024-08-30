import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/resources/resources.dart';

@RoutePage()
class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: context.colors.background,
      ),
      body: const Padding(
        padding: EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Stack(
          children: [
            ContentWidget(),
            AnimatedHeading(),
          ],
        ),
      ),
    );
  }
}

class ContentWidget extends StatelessWidget {
  const ContentWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        SizedBox(height: 100),
        Text(
          'Hello World!',
          style: TextStyle(
            fontSize: 30,
            fontWeight: FontWeight.w500,
          ),
        )
      ],
    );
  }
}

class AnimatedHeading extends StatelessWidget {
  const AnimatedHeading({super.key});

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder(
      builder: (context, value, child) {
        return Padding(
          padding: EdgeInsets.only(top: value * 20),
          child: child,
        );
      },
      tween: Tween<double>(begin: 0, end: 1),
      duration: const Duration(milliseconds: 1000),
      child: const ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text('Ashraful Haque'),
        subtitle: Text('Software Engineer'),
        trailing: CircleAvatar(
          radius: 20,
          child: Icon(Icons.supervised_user_circle),
        ),
      ),
    );
  }
}
