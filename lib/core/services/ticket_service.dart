// lib/core/services/ticket_service.dart
import 'dart:io';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/ticket_model.dart';
import '../models/profile_model.dart';

class TicketService {
  final _supabase = Supabase.instance.client;

  String get _userId => _supabase.auth.currentUser!.id;

  // ============================================================
  // AMBIL DAFTAR TIKET (filter otomatis berdasarkan role)
  // ============================================================
  Future<List<TicketModel>> getTickets({
    String? status,
    required ProfileModel profile,
  }) async {
    var query = _supabase
        .from('tickets')
        .select('''
          *,
          reporter:profiles!reported_by(full_name, unit_name),
          assignee:profiles!assigned_to(full_name)
        ''');

    // Filter berdasarkan role
    if (profile.isUnit) {
      query = query.eq('reported_by', _userId) as dynamic;
    } else if (profile.isAdminFasilitas) {
      query = query.eq('category', 'fasilitas') as dynamic;
    } else if (profile.isAdminIT) {
      query = query.eq('category', 'it') as dynamic;
    } else if (profile.isTeknisiFasilitas) {
      query = query
          .eq('category', 'fasilitas')
          .eq('assigned_to', _userId) as dynamic;
    } else if (profile.isTeknisiIT) {
      query = query
          .eq('category', 'it')
          .eq('assigned_to', _userId) as dynamic;
    }

    if (status != null && status != 'all') {
      query = query.eq('status', status) as dynamic;
    }

    final data = await query.order('created_at', ascending: false);
    return (data as List).map((e) => TicketModel.fromMap(e)).toList();
  }

  // ============================================================
  // DETAIL TIKET
  // ============================================================
  Future<TicketModel> getTicketDetail(String ticketId) async {
    final data = await _supabase
        .from('tickets')
        .select('''
          *,
          reporter:profiles!reported_by(full_name, unit_name),
          assignee:profiles!assigned_to(full_name)
        ''')
        .eq('id', ticketId)
        .single();
    return TicketModel.fromMap(data);
  }

  // ============================================================
  // BUAT TIKET BARU
  // ============================================================
  Future<void> createTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
    File? photo,
  }) async {
    String? photoUrl;

    if (photo != null) {
      final ext = photo.path.split('.').last;
      final fileName = '${_userId}_${DateTime.now().millisecondsSinceEpoch}.$ext';
      await _supabase.storage
          .from('ticket-photos')
          .upload(fileName, photo, fileOptions: const FileOptions(upsert: false));
      photoUrl = _supabase.storage
          .from('ticket-photos')
          .getPublicUrl(fileName);
    }

    await _supabase.from('tickets').insert({
      'title': title,
      'description': description,
      'category': category,
      'priority': priority,
      'photo_url': photoUrl,
      'reported_by': _userId,
      'status': 'new',
    });
  }

  // ============================================================
  // ADMIN: RESPONS TIKET
  // ============================================================
  Future<void> respondTicket(String ticketId) async {
    await _supabase.from('tickets').update({
      'status': 'responded',
      'responded_at': DateTime.now().toIso8601String(),
    }).eq('id', ticketId);
  }

  // ============================================================
  // ADMIN: ASSIGN KE TEKNISI
  // ============================================================
  Future<void> assignTicket(String ticketId, String technicianId) async {
    await _supabase.from('tickets').update({
      'assigned_to': technicianId,
      'status': 'responded',
      'responded_at': DateTime.now().toIso8601String(),
    }).eq('id', ticketId);
  }

  // ============================================================
  // TEKNISI: MULAI PENGERJAAN
  // ============================================================
  Future<void> startTicket(String ticketId) async {
    await _supabase.from('tickets').update({
      'status': 'in_progress',
      'started_at': DateTime.now().toIso8601String(),
    }).eq('id', ticketId);
  }

  // ============================================================
  // TEKNISI: SELESAI PENGERJAAN
  // ============================================================
  Future<void> completeTicket(String ticketId) async {
    await _supabase.from('tickets').update({
      'status': 'done',
      'completed_at': DateTime.now().toIso8601String(),
    }).eq('id', ticketId);
  }

  // ============================================================
  // AMBIL DAFTAR TEKNISI (untuk admin assign)
  // ============================================================
  Future<List<ProfileModel>> getTechnicians(String category) async {
    final role = category == 'fasilitas' ? 'teknisi_fasilitas' : 'teknisi_it';
    final data = await _supabase
        .from('profiles')
        .select()
        .eq('role', role)
        .order('full_name');
    return (data as List).map((e) => ProfileModel.fromMap(e)).toList();
  }

  // ============================================================
  // CHAT
  // ============================================================
  Future<List<ChatModel>> getChats(String ticketId) async {
    final data = await _supabase
        .from('ticket_chats')
        .select('*, sender:profiles!sender_id(full_name)')
        .eq('ticket_id', ticketId)
        .order('created_at');
    return (data as List).map((e) => ChatModel.fromMap(e)).toList();
  }

  Future<void> sendChat(String ticketId, String message) async {
    await _supabase.from('ticket_chats').insert({
      'ticket_id': ticketId,
      'sender_id': _userId,
      'message': message,
    });
  }

  // Realtime stream untuk chat
  Stream<List<Map<String, dynamic>>> chatStream(String ticketId) {
    return _supabase
        .from('ticket_chats')
        .stream(primaryKey: ['id'])
        .eq('ticket_id', ticketId)
        .order('created_at');
  }

  // ============================================================
  // NOTIFIKASI
  // ============================================================
  Future<List<NotificationModel>> getNotifications() async {
    final data = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', _userId)
        .order('created_at', ascending: false)
        .limit(30);
    return (data as List).map((e) => NotificationModel.fromMap(e)).toList();
  }

  Future<void> markNotificationRead(String notifId) async {
    await _supabase
        .from('notifications')
        .update({'is_read': true})
        .eq('id', notifId);
  }

  Future<int> getUnreadCount() async {
    final data = await _supabase
        .from('notifications')
        .select()
        .eq('user_id', _userId)
        .eq('is_read', false);
    return (data as List).length;
  }

  // Realtime stream notifikasi
  Stream<List<Map<String, dynamic>>> notificationStream() {
    return _supabase
        .from('notifications')
        .stream(primaryKey: ['id'])
        .eq('user_id', _userId)
        .order('created_at', ascending: false);
  }

  // ============================================================
  // STATISTIK (untuk superadmin / admin)
  // ============================================================
  Future<Map<String, int>> getStats(ProfileModel profile) async {
    var query = _supabase.from('tickets').select('status, category');

    if (profile.isAdminFasilitas) {
      query = query.eq('category', 'fasilitas') as dynamic;
    } else if (profile.isAdminIT) {
      query = query.eq('category', 'it') as dynamic;
    }

    final data = await query as List;
    return {
      'total': data.length,
      'new': data.where((t) => t['status'] == 'new').length,
      'responded': data.where((t) => t['status'] == 'responded').length,
      'in_progress': data.where((t) => t['status'] == 'in_progress').length,
      'done': data.where((t) => t['status'] == 'done').length,
    };
  }
}
