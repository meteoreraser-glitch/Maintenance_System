// lib/core/models/ticket_model.dart
class TicketModel {
  final String id;
  final String? ticketNumber;
  final String title;
  final String description;
  final String? photoUrl;
  final String category;
  final String priority;
  final String status;
  final String reportedBy;
  final String? assignedTo;
  final DateTime? respondedAt;
  final DateTime? startedAt;
  final DateTime? completedAt;
  final DateTime createdAt;

  // Join data
  final String? reporterName;
  final String? reporterUnit;
  final String? assigneeName;

  TicketModel({
    required this.id,
    this.ticketNumber,
    required this.title,
    required this.description,
    this.photoUrl,
    required this.category,
    this.priority = 'normal',
    this.status = 'new',
    required this.reportedBy,
    this.assignedTo,
    this.respondedAt,
    this.startedAt,
    this.completedAt,
    required this.createdAt,
    this.reporterName,
    this.reporterUnit,
    this.assigneeName,
  });

  factory TicketModel.fromMap(Map<String, dynamic> map) {
    return TicketModel(
      id: map['id'],
      ticketNumber: map['ticket_number'],
      title: map['title'],
      description: map['description'],
      photoUrl: map['photo_url'],
      category: map['category'],
      priority: map['priority'] ?? 'normal',
      status: map['status'] ?? 'new',
      reportedBy: map['reported_by'],
      assignedTo: map['assigned_to'],
      respondedAt: map['responded_at'] != null
          ? DateTime.parse(map['responded_at']) : null,
      startedAt: map['started_at'] != null
          ? DateTime.parse(map['started_at']) : null,
      completedAt: map['completed_at'] != null
          ? DateTime.parse(map['completed_at']) : null,
      createdAt: DateTime.parse(map['created_at']),
      reporterName: map['reporter']?['full_name'],
      reporterUnit: map['reporter']?['unit_name'],
      assigneeName: map['assignee']?['full_name'],
    );
  }

  String get statusLabel {
    switch (status) {
      case 'new': return 'Baru';
      case 'responded': return 'Direspons';
      case 'in_progress': return 'Dikerjakan';
      case 'done': return 'Selesai';
      default: return status;
    }
  }

  String get categoryLabel =>
      category == 'fasilitas' ? 'Fasilitas' : 'IT';

  String get priorityLabel {
    switch (priority) {
      case 'low': return 'Rendah';
      case 'normal': return 'Normal';
      case 'high': return 'Tinggi';
      case 'urgent': return 'Urgent';
      default: return priority;
    }
  }
}

class ChatModel {
  final String id;
  final String ticketId;
  final String senderId;
  final String message;
  final DateTime createdAt;
  final String? senderName;

  ChatModel({
    required this.id,
    required this.ticketId,
    required this.senderId,
    required this.message,
    required this.createdAt,
    this.senderName,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map) {
    return ChatModel(
      id: map['id'],
      ticketId: map['ticket_id'],
      senderId: map['sender_id'],
      message: map['message'],
      createdAt: DateTime.parse(map['created_at']),
      senderName: map['sender']?['full_name'],
    );
  }
}

class NotificationModel {
  final String id;
  final String userId;
  final String? ticketId;
  final String title;
  final String body;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.id,
    required this.userId,
    this.ticketId,
    required this.title,
    required this.body,
    required this.isRead,
    required this.createdAt,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map) {
    return NotificationModel(
      id: map['id'],
      userId: map['user_id'],
      ticketId: map['ticket_id'],
      title: map['title'],
      body: map['body'],
      isRead: map['is_read'] ?? false,
      createdAt: DateTime.parse(map['created_at']),
    );
  }
}
