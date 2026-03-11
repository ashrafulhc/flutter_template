import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_template/presentation/features/main/ui/app_bottom_navigation_bar.dart';
import 'package:flutter_template/presentation/routes/app_router.dart';

class MainScreen extends StatelessWidget {
  const MainScreen({super.key, required this.body});

  final Widget body;

  static const _tabs = [
    '${AppRoutes.main}/${AppRoutes.home}',
    '${AppRoutes.main}/${AppRoutes.settings}',
  ];

  static const _navItems = [
    BottomNavigationBarItem(label: 'Home', icon: Icon(Icons.home)),
    BottomNavigationBarItem(label: 'Settings', icon: Icon(Icons.settings)),
  ];

  int _currentIndex(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    final index = _tabs.indexWhere((t) => location.startsWith(t));
    return index < 0 ? 0 : index;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: body,
      bottomNavigationBar: AppBottomNavigationBar(
        currentIndex: _currentIndex(context),
        onTap: (index) => context.go(_tabs[index]),
        bottomNavigationBarItemList: _navItems,
      ),
    );
  }
}
