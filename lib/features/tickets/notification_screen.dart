// lib/features/tickets/notification_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../core/services/providers.dart';
import '../../core/models/ticket_model.dart';
import '../../shared/theme/app_theme.dart';

class NotificationScreen extends ConsumerWidget {
  const NotificationScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifsAsync = ref.watch(notificationsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifikasi'),
        actions: [
          TextButton(
            onPressed: () async {
              final notifs = notifsAsync.value ?? [];
              final svc = ref.read(ticketServiceProvider);
              for (final n in notifs.where((n) => !n.isRead)) {
                await svc.markNotificationRead(n.id);
              }
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadCountProvider);
            },
            child: const Text(
              'Tandai semua dibaca',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
        ],
      ),
      body: notifsAsync.when(
        data: (notifs) {
          if (notifs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none,
                      size: 72, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text(
                    'Belum ada notifikasi',
                    style: TextStyle(color: Colors.grey[500], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(notificationsProvider);
              ref.invalidate(unreadCountProvider);
            },
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: notifs.length,
              separatorBuilder: (_, __) =>
                  const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (_, i) => _NotifItem(
                notif: notifs[i],
                onTap: () async {
                  // Tandai dibaca
                  if (!notifs[i].isRead) {
                    await ref
                        .read(ticketServiceProvider)
                        .markNotificationRead(notifs[i].id);
                    ref.invalidate(notificationsProvider);
                    ref.invalidate(unreadCountProvider);
                  }
                  // Navigasi ke tiket
                  if (notifs[i].ticketId != null && context.mounted) {
                    context.push('/tickets/${notifs[i].ticketId}');
                  }
                },
              ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _NotifItem extends StatelessWidget {
  final NotificationModel notif;
  final VoidCallback onTap;

  const _NotifItem({required this.notif, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final timeStr = _formatTime(notif.createdAt);
    final isUnread = !notif.isRead;

    return InkWell(
      onTap: onTap,
      child: Container(
        color: isUnread ? AppColors.primaryLight : Colors.transparent,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _iconColor().withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(_iconData(), color: _iconColor(), size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.title,
                          style: TextStyle(
                            fontWeight: isUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      if (isUnread)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notif.body,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    timeStr,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconData() {
    if (notif.title.contains('Selesai')) return Icons.task_alt;
    if (notif.title.contains('Dikerjakan') || notif.title.contains('Mulai')) {
      return Icons.play_circle_outline;
    }
    if (notif.title.contains('Ditugaskan')) return Icons.engineering;
    return Icons.notifications_outlined;
  }

  Color _iconColor() {
    if (notif.title.contains('Selesai')) return AppColors.statusDone;
    if (notif.title.contains('Dikerjakan') || notif.title.contains('Mulai')) {
      return AppColors.statusInProgress;
    }
    if (notif.title.contains('Ditugaskan')) return AppColors.categoryFasilitas;
    return AppColors.primary;
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt.toLocal());
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return DateFormat('dd MMM yyyy', 'id_ID').format(dt.toLocal());
  }
}