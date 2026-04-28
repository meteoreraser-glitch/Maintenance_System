// lib/core/utils/app_router.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/tickets/ticket_list_screen.dart';
import '../../features/tickets/ticket_create_screen.dart';
import '../../features/tickets/ticket_detail_screen.dart';
import '../../features/chat/chat_screen.dart';
import '../../features/tickets/notification_screen.dart';
import '../services/providers.dart';
import 'home_wrapper.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/tickets',
    redirect: (context, state) {
      final user = Supabase.instance.client.auth.currentUser;
      final isLoggedIn = user != null;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register';

      if (!isLoggedIn && !isAuthRoute) return '/login';
      if (isLoggedIn && isAuthRoute) return '/tickets';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      ShellRoute(
        builder: (context, state, child) => HomeWrapper(child: child),
        routes: [
          GoRoute(
            path: '/tickets',
            builder: (_, __) => const TicketListScreen(),
          ),
          GoRoute(
            path: '/tickets/create',
            builder: (_, __) => const TicketCreateScreen(),
          ),
          GoRoute(
            path: '/tickets/:id',
            builder: (_, state) =>
                TicketDetailScreen(ticketId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/tickets/:id/chat',
            builder: (_, state) =>
                ChatScreen(ticketId: state.pathParameters['id']!),
          ),
          GoRoute(
            path: '/notifications',
            builder: (_, __) => const NotificationScreen(),
          ),
        ],
      ),
    ],
  );
});