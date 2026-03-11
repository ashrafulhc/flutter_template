import 'package:flutter/material.dart';
import 'package:flutter_template/presentation/resources/resources.dart';

class AppBottomNavigationBar extends StatelessWidget {
  const AppBottomNavigationBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.bottomNavigationBarItemList,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<BottomNavigationBarItem> bottomNavigationBarItemList;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: context.colors.background,
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      items: bottomNavigationBarItemList,
    );
  }
}
