import 'dart:ui';
import 'package:flutter/material.dart';

class ModernBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavigationDestination> destinations;

  const ModernBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.destinations,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).bottomNavigationBarTheme.backgroundColor?.withOpacity(0.85) ?? Colors.white.withOpacity(0.85),
              borderRadius: BorderRadius.circular(32),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 16,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: NavigationBar(
              height: 64,
              backgroundColor: Colors.transparent,
              indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
              selectedIndex: currentIndex,
              onDestinationSelected: onTap,
              destinations: destinations,
              elevation: 0,
              labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
              labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
                if (states.contains(WidgetState.selected)) {
                  return const TextStyle(fontSize: 11, fontWeight: FontWeight.bold);
                }
                return const TextStyle(fontSize: 10, fontWeight: FontWeight.w500);
              }),
            ),
          ),
        ),
      ),
    );
  }
}
