// lib/core/models/profile_model.dart
class ProfileModel {
  final String id;
  final String fullName;
  final String role;
  final String? unitName;
  final String? avatarUrl;

  ProfileModel({
    required this.id,
    required this.fullName,
    required this.role,
    this.unitName,
    this.avatarUrl,
  });

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id'],
      fullName: map['full_name'],
      role: map['role'],
      unitName: map['unit_name'],
      avatarUrl: map['avatar_url'],
    );
  }

  bool get isUnit => role == 'unit';
  bool get isAdminFasilitas => role == 'admin_fasilitas';
  bool get isAdminIT => role == 'admin_it';
  bool get isTeknisiFasilitas => role == 'teknisi_fasilitas';
  bool get isTeknisiIT => role == 'teknisi_it';
  bool get isSuperadmin => role == 'superadmin';
  bool get isAdmin => isAdminFasilitas || isAdminIT || isSuperadmin;
  bool get isTeknisi => isTeknisiFasilitas || isTeknisiIT;

  String get roleLabel {
    switch (role) {
      case 'unit': return unitName ?? 'Unit Pelayanan';
      case 'admin_fasilitas': return 'Admin Fasilitas';
      case 'admin_it': return 'Admin IT';
      case 'teknisi_fasilitas': return 'Teknisi Fasilitas';
      case 'teknisi_it': return 'Teknisi IT';
      case 'superadmin': return 'Super Admin';
      default: return role;
    }
  }
}