// lib/core/utils/home_wrapper.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../services/providers.dart';
import '../../shared/theme/app_theme.dart';

class HomeWrapper extends ConsumerWidget {
  final Widget child;
  const HomeWrapper({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final location = GoRouterState.of(context).matchedLocation;
    final unread = ref.watch(unreadCountProvider);

    int currentIndex = 0;
    if (location.startsWith('/notifications')) currentIndex = 1;

    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (i) {
          if (i == 0) context.go('/tickets');
          if (i == 1) context.go('/notifications');
        },
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.confirmation_number_outlined),
            selectedIcon: Icon(Icons.confirmation_number),
            label: 'Tiket',
          ),
          NavigationDestination(
            icon: Badge(
              isLabelVisible: (unread.value ?? 0) > 0,
              label: Text('${unread.value ?? 0}'),
              child: const Icon(Icons.notifications_outlined),
            ),
            selectedIcon: const Icon(Icons.notifications),
            label: 'Notifikasi',
          ),
        ],
      ),
    );
  }
}
