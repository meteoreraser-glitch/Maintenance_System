// lib/features/tickets/ticket_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../core/services/providers.dart';
import '../../core/models/ticket_model.dart';
import '../../core/models/profile_model.dart';
import '../../shared/theme/app_theme.dart';

class TicketDetailScreen extends ConsumerWidget {
  final String ticketId;
  const TicketDetailScreen({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketAsync = ref.watch(ticketDetailProvider(ticketId));
    final profileAsync = ref.watch(currentProfileProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tiket'),
        actions: [
          // Tombol chat
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline),
            tooltip: 'Chat',
            onPressed: () => context.push('/tickets/$ticketId/chat'),
          ),
        ],
      ),
      body: ticketAsync.when(
        data: (ticket) => profileAsync.when(
          data: (profile) => _DetailBody(
            ticket: ticket,
            profile: profile,
            onRefresh: () {
              ref.invalidate(ticketDetailProvider(ticketId));
              ref.invalidate(ticketsProvider('all'));
              ref.invalidate(statsProvider);
            },
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _DetailBody extends ConsumerStatefulWidget {
  final TicketModel ticket;
  final ProfileModel? profile;
  final VoidCallback onRefresh;

  const _DetailBody({
    required this.ticket,
    required this.profile,
    required this.onRefresh,
  });

  @override
  ConsumerState<_DetailBody> createState() => _DetailBodyState();
}

class _DetailBodyState extends ConsumerState<_DetailBody> {
  bool _loading = false;

  Future<void> _doAction(Future<void> Function() action) async {
    setState(() => _loading = true);
    try {
      await action();
      widget.onRefresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Berhasil diperbarui'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  // Admin: pilih teknisi lalu assign
  Future<void> _showAssignDialog() async {
    final techsAsync = ref.read(techniciansProvider(widget.ticket.category));
    final techs = await techsAsync.when(
      data: (t) async => t,
      loading: () async => <ProfileModel>[],
      error: (_, __) async => <ProfileModel>[],
    );

    if (!mounted) return;

    if (techs.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Belum ada teknisi terdaftar')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 8),
            Container(
              width: 40, height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Pilih Teknisi',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const Divider(height: 1),
            ...techs.map(
              (tech) => ListTile(
                leading: CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Text(
                    tech.fullName.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                title: Text(tech.fullName),
                subtitle: Text(tech.roleLabel),
                trailing: const Icon(Icons.arrow_forward_ios, size: 14),
                onTap: () {
                  Navigator.pop(context);
                  _doAction(() => ref
                      .read(ticketServiceProvider)
                      .assignTicket(widget.ticket.id, tech.id));
                },
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.ticket;
    final p = widget.profile;
    final svc = ref.read(ticketServiceProvider);
    final fmt = DateFormat('dd MMM yyyy, HH:mm', 'id_ID');

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header card
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            t.ticketNumber ?? '#',
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                            ),
                          ),
                          const Spacer(),
                          CategoryBadge(t.category),
                          const SizedBox(width: 6),
                          StatusBadge(t.status),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        t.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      PriorityBadge(t.priority),
                    ],
                  ),
                ),
              ),

              // Foto
              if (t.photoUrl != null) ...[
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: CachedNetworkImage(
                    imageUrl: t.photoUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(
                      height: 200,
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (_, __, ___) => Container(
                      height: 150,
                      color: Colors.grey[200],
                      child: const Center(
                        child: Icon(Icons.broken_image, size: 40, color: Colors.grey),
                      ),
                    ),
                  ),
                ),
              ],

              // Deskripsi
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Deskripsi Masalah',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(t.description, style: const TextStyle(fontSize: 15)),
                    ],
                  ),
                ),
              ),

              // Info pelapor & timeline
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Informasi',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _InfoRow(
                        icon: Icons.person_outline,
                        label: 'Pelapor',
                        value: t.reporterName ?? '-',
                      ),
                      _InfoRow(
                        icon: Icons.business_outlined,
                        label: 'Unit',
                        value: t.reporterUnit ?? '-',
                      ),
                      if (t.assigneeName != null)
                        _InfoRow(
                          icon: Icons.engineering_outlined,
                          label: 'Teknisi',
                          value: t.assigneeName!,
                        ),
                      const Divider(height: 24),
                      _InfoRow(
                        icon: Icons.schedule,
                        label: 'Dibuat',
                        value: fmt.format(t.createdAt.toLocal()),
                      ),
                      if (t.respondedAt != null)
                        _InfoRow(
                          icon: Icons.check_circle_outline,
                          label: 'Direspons',
                          value: fmt.format(t.respondedAt!.toLocal()),
                          color: AppColors.statusResponded,
                        ),
                      if (t.startedAt != null)
                        _InfoRow(
                          icon: Icons.play_circle_outline,
                          label: 'Mulai dikerjakan',
                          value: fmt.format(t.startedAt!.toLocal()),
                          color: AppColors.statusInProgress,
                        ),
                      if (t.completedAt != null)
                        _InfoRow(
                          icon: Icons.task_alt,
                          label: 'Selesai',
                          value: fmt.format(t.completedAt!.toLocal()),
                          color: AppColors.statusDone,
                        ),
                    ],
                  ),
                ),
              ),

              // ============================================================
              // TOMBOL AKSI BERDASARKAN ROLE
              // ============================================================
              if (p != null) ...[
                const SizedBox(height: 8),

                // ADMIN: Respons + Assign
                if ((p.isAdminFasilitas && t.category == 'fasilitas') ||
                    (p.isAdminIT && t.category == 'it') ||
                    p.isSuperadmin) ...[
                  if (t.status == 'new')
                    _ActionButton(
                      label: 'Respons Tiket',
                      icon: Icons.reply,
                      color: AppColors.statusResponded,
                      loading: _loading,
                      onPressed: () => _doAction(
                        () => svc.respondTicket(t.id),
                      ),
                    ),
                  const SizedBox(height: 8),
                  if (t.status == 'new' || t.status == 'responded')
                    _ActionButton(
                      label: t.assignedTo == null
                          ? 'Assign ke Teknisi'
                          : 'Ganti Teknisi',
                      icon: Icons.engineering,
                      color: AppColors.categoryFasilitas,
                      loading: _loading,
                      onPressed: _showAssignDialog,
                    ),
                ],

                // TEKNISI: Mulai & Selesai
                if ((p.isTeknisiFasilitas || p.isTeknisiIT) &&
                    t.assignedTo == p.id) ...[
                  if (t.status == 'responded')
                    _ActionButton(
                      label: 'Mulai Pengerjaan',
                      icon: Icons.play_arrow,
                      color: AppColors.statusInProgress,
                      loading: _loading,
                      onPressed: () => _doAction(
                        () => svc.startTicket(t.id),
                      ),
                    ),
                  if (t.status == 'in_progress')
                    _ActionButton(
                      label: 'Tandai Selesai',
                      icon: Icons.check_circle,
                      color: AppColors.statusDone,
                      loading: _loading,
                      onPressed: () => _showCompleteConfirm(svc),
                    ),
                ],
              ],

              // Chat shortcut button
              const SizedBox(height: 8),
              OutlinedButton.icon(
                onPressed: () => context.push('/tickets/$ticketId/chat'),
                icon: const Icon(Icons.chat_bubble_outline),
                label: const Text('Buka Chat dengan Unit'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 48),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
        if (_loading)
          Container(
            color: Colors.black.withOpacity(0.1),
            child: const Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }

  void _showCompleteConfirm(svc) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konfirmasi Selesai'),
        content: const Text(
          'Apakah pengerjaan tiket ini sudah benar-benar selesai?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _doAction(() => ref
                  .read(ticketServiceProvider)
                  .completeTicket(widget.ticket.id));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.statusDone,
            ),
            child: const Text('Ya, Selesai'),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? color;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color ?? AppColors.textSecondary),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w500,
                fontSize: 13,
                color: color ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;
  final bool loading;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.loading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50,
      child: ElevatedButton.icon(
        onPressed: loading ? null : onPressed,
        icon: Icon(icon),
        label: Text(label, style: const TextStyle(fontSize: 15)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
    );
  }
}
