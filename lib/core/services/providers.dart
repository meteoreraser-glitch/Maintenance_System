// lib/core/services/providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/profile_model.dart';
import '../models/ticket_model.dart';
import 'auth_service.dart';
import 'ticket_service.dart';

final authServiceProvider = Provider((ref) => AuthService());
final ticketServiceProvider = Provider((ref) => TicketService());

// Profile user yang sedang login
final currentProfileProvider = FutureProvider<ProfileModel?>((ref) async {
  final auth = ref.read(authServiceProvider);
  return await auth.getCurrentProfile();
});

// Daftar tiket
final ticketsProvider = FutureProvider.family<List<TicketModel>, String>(
  (ref, status) async {
    final profile = await ref.watch(currentProfileProvider.future);
    if (profile == null) return [];
    final svc = ref.read(ticketServiceProvider);
    return svc.getTickets(status: status, profile: profile);
  },
);

// Detail tiket
final ticketDetailProvider = FutureProvider.family<TicketModel, String>(
  (ref, ticketId) async {
    final svc = ref.read(ticketServiceProvider);
    return svc.getTicketDetail(ticketId);
  },
);

// Daftar teknisi
final techniciansProvider = FutureProvider.family<List<ProfileModel>, String>(
  (ref, category) async {
    final svc = ref.read(ticketServiceProvider);
    return svc.getTechnicians(category);
  },
);

// Notifikasi
final notificationsProvider = FutureProvider<List<NotificationModel>>((ref) async {
  final svc = ref.read(ticketServiceProvider);
  return svc.getNotifications();
});

// Unread notif count
final unreadCountProvider = FutureProvider<int>((ref) async {
  final svc = ref.read(ticketServiceProvider);
  return svc.getUnreadCount();
});

// Statistik
final statsProvider = FutureProvider<Map<String, int>>((ref) async {
  final profile = await ref.watch(currentProfileProvider.future);
  if (profile == null) return {};
  final svc = ref.read(ticketServiceProvider);
  return svc.getStats(profile);
});
