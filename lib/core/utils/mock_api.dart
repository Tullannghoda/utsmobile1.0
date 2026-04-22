import '../constants/app_constants.dart';

/// Mock API yang mensimulasikan response dari backend RESTful.
/// Siap diganti dengan DioClient + endpoint nyata.
class MockApi {
  static Future<void> _delay([int ms = 600]) =>
      Future.delayed(Duration(milliseconds: ms));

  // ─── AUTH ───────────────────────────────────────────────────────────
  static final _users = [
    {
      'id': 'u001',
      'name': 'Budi Santoso',
      'email': 'user@mail.com',
      'password': '123456',
      'role': AppConstants.roleUser,
      'phone': '081234567890',
      'department': 'Teknik Informatika',
      'avatar': null,
      'createdAt': '2026-01-15',
    },
    {
      'id': 'u002',
      'name': 'Dewi Helpdesk',
      'email': 'helpdesk@mail.com',
      'password': '123456',
      'role': AppConstants.roleHelpdesk,
      'phone': '082345678901',
      'department': 'IT Support',
      'avatar': null,
      'createdAt': '2025-12-01',
    },
    {
      'id': 'u003',
      'name': 'Admin Sistem',
      'email': 'admin@mail.com',
      'password': '123456',
      'role': AppConstants.roleAdmin,
      'phone': '083456789012',
      'department': 'IT Management',
      'avatar': null,
      'createdAt': '2025-11-01',
    },
  ];

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    await _delay();
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email dan password wajib diisi');
    }
    final user = _users.firstWhere(
          (u) => u['email'] == email && u['password'] == password,
      orElse: () => {},
    );
    if (user.isEmpty) throw Exception('Email atau password salah');
    return {
      'success': true,
      'token': 'mock_jwt_${DateTime.now().millisecondsSinceEpoch}',
      'user': {
        'id': user['id'],
        'name': user['name'],
        'email': user['email'],
        'role': user['role'],
        'phone': user['phone'],
        'department': user['department'],
      },
    };
  }

  static Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _delay();
    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      throw Exception('Semua field wajib diisi');
    }
    if (password.length < 6) throw Exception('Password minimal 6 karakter');
    final exists = _users.any((u) => u['email'] == email);
    if (exists) throw Exception('Email sudah terdaftar');
    return {'success': true, 'message': 'Registrasi berhasil, silakan login'};
  }

  // ─── TICKETS ────────────────────────────────────────────────────────
  static final List<Map<String, dynamic>> _tickets = [
    {
      'id': 'TCK-2026-001',
      'title': 'WiFi tidak bisa connect di Lab A',
      'description':
      'Sudah mencoba restart modem dan laptop, namun WiFi kantor tetap tidak bisa terkoneksi. Sudah berlangsung sejak pagi hari.',
      'status': AppConstants.statusOpen,
      'priority': 'high',
      'category': 'Jaringan',
      'createdAt': '2026-04-23 09:00:00',
      'updatedAt': '2026-04-23 09:00:00',
      'userId': 'u001',
      'userName': 'Budi Santoso',
      'assignedTo': null,
      'assignedToId': null,
      'comments': [],
      'attachments': [],
    },
    {
      'id': 'TCK-2026-002',
      'title': 'Printer ruang meeting tidak merespon',
      'description':
      'Printer Canon di ruang meeting lantai 2 tidak bisa digunakan untuk print. Sudah dicoba dari berbagai laptop.',
      'status': AppConstants.statusInProgress,
      'priority': 'medium',
      'category': 'Hardware',
      'createdAt': '2026-04-22 14:30:00',
      'updatedAt': '2026-04-23 08:00:00',
      'userId': 'u001',
      'userName': 'Budi Santoso',
      'assignedTo': 'Dewi Helpdesk',
      'assignedToId': 'u002',
      'comments': [
        {
          'id': 'cmt001',
          'userId': 'u002',
          'userName': 'Dewi Helpdesk',
          'role': AppConstants.roleHelpdesk,
          'content':
          'Sudah kami cek, sepertinya ada masalah pada driver. Sedang dalam proses perbaikan.',
          'createdAt': '2026-04-23 08:00:00',
        },
      ],
      'attachments': [],
    },
    {
      'id': 'TCK-2026-003',
      'title': 'Email tidak bisa kirim attachment',
      'description':
      'Saat mencoba kirim email dengan file PDF ukuran 5MB, selalu gagal dan muncul error "Message size exceeds limit".',
      'status': AppConstants.statusResolved,
      'priority': 'low',
      'category': 'Email',
      'createdAt': '2026-04-21 10:00:00',
      'updatedAt': '2026-04-22 16:00:00',
      'userId': 'u001',
      'userName': 'Budi Santoso',
      'assignedTo': 'Admin Sistem',
      'assignedToId': 'u003',
      'comments': [
        {
          'id': 'cmt002',
          'userId': 'u002',
          'userName': 'Dewi Helpdesk',
          'role': AppConstants.roleHelpdesk,
          'content': 'Masalah ini sudah kami eskalasi ke admin.',
          'createdAt': '2026-04-21 11:00:00',
        },
        {
          'id': 'cmt003',
          'userId': 'u003',
          'userName': 'Admin Sistem',
          'role': AppConstants.roleAdmin,
          'content':
          'Limit attachment email sudah dinaikkan menjadi 25MB. Silakan coba kembali.',
          'createdAt': '2026-04-22 16:00:00',
        },
      ],
      'attachments': [],
    },
    {
      'id': 'TCK-2026-004',
      'title': 'Aplikasi SIMAK error saat login',
      'description':
      'Saat membuka SIMAK dan memasukkan credentials, muncul pesan "Connection timeout". Sudah dicoba beberapa kali.',
      'status': AppConstants.statusClosed,
      'priority': 'high',
      'category': 'Aplikasi',
      'createdAt': '2026-04-20 08:00:00',
      'updatedAt': '2026-04-21 10:00:00',
      'userId': 'u001',
      'userName': 'Budi Santoso',
      'assignedTo': 'Admin Sistem',
      'assignedToId': 'u003',
      'comments': [
        {
          'id': 'cmt004',
          'userId': 'u003',
          'userName': 'Admin Sistem',
          'role': AppConstants.roleAdmin,
          'content':
          'Server SIMAK sempat down untuk maintenance. Sudah kembali normal.',
          'createdAt': '2026-04-21 10:00:00',
        },
      ],
      'attachments': [],
    },
    {
      'id': 'TCK-2026-005',
      'title': 'Proyektor ruang kelas B tidak menyala',
      'description':
      'Proyektor di ruang kelas B102 tidak menyala sama sekali. Lampu indikator juga tidak menyala.',
      'status': AppConstants.statusOpen,
      'priority': 'medium',
      'category': 'Hardware',
      'createdAt': '2026-04-23 11:00:00',
      'updatedAt': '2026-04-23 11:00:00',
      'userId': 'u001',
      'userName': 'Budi Santoso',
      'assignedTo': null,
      'assignedToId': null,
      'comments': [],
      'attachments': [],
    },
  ];

  static Future<List<Map<String, dynamic>>> getTickets(
      String userId, String role) async {
    await _delay();
    if (role == AppConstants.roleAdmin || role == AppConstants.roleHelpdesk) {
      return List.from(_tickets);
    }
    return _tickets.where((t) => t['userId'] == userId).toList();
  }

  static Future<Map<String, dynamic>> getTicketDetail(String id) async {
    await _delay();
    return Map.from(
        _tickets.firstWhere((t) => t['id'] == id, orElse: () => {}));
  }

  static Future<Map<String, dynamic>> createTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
    required String userId,
    required String userName,
    List<String> attachments = const [],
  }) async {
    await _delay(800);
    final now = DateTime.now();
    final id =
        'TCK-${now.year}-${(_tickets.length + 1).toString().padLeft(3, '0')}';
    final newTicket = {
      'id': id,
      'title': title,
      'description': description,
      'status': AppConstants.statusOpen,
      'priority': priority,
      'category': category,
      'createdAt': now.toString().substring(0, 19),
      'updatedAt': now.toString().substring(0, 19),
      'userId': userId,
      'userName': userName,
      'assignedTo': null,
      'assignedToId': null,
      'comments': [],
      'attachments': attachments,
    };
    _tickets.insert(0, newTicket);
    return newTicket;
  }

  static Future<Map<String, dynamic>> updateTicketStatus(
      String id, String status) async {
    await _delay();
    final idx = _tickets.indexWhere((t) => t['id'] == id);
    if (idx == -1) throw Exception('Tiket tidak ditemukan');
    _tickets[idx]['status'] = status;
    _tickets[idx]['updatedAt'] =
        DateTime.now().toString().substring(0, 19);
    return Map.from(_tickets[idx]);
  }

  static Future<Map<String, dynamic>> assignTicket(
      String id, String assignedTo, String assignedToId) async {
    await _delay();
    final idx = _tickets.indexWhere((t) => t['id'] == id);
    if (idx == -1) throw Exception('Tiket tidak ditemukan');
    _tickets[idx]['assignedTo'] = assignedTo;
    _tickets[idx]['assignedToId'] = assignedToId;
    _tickets[idx]['status'] = AppConstants.statusInProgress;
    _tickets[idx]['updatedAt'] =
        DateTime.now().toString().substring(0, 19);
    return Map.from(_tickets[idx]);
  }

  static Future<Map<String, dynamic>> addComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String role,
    required String content,
  }) async {
    await _delay();
    final idx = _tickets.indexWhere((t) => t['id'] == ticketId);
    if (idx == -1) throw Exception('Tiket tidak ditemukan');
    final comment = {
      'id': 'cmt${DateTime.now().millisecondsSinceEpoch}',
      'userId': userId,
      'userName': userName,
      'role': role,
      'content': content,
      'createdAt': DateTime.now().toString().substring(0, 19),
    };
    (_tickets[idx]['comments'] as List).add(comment);
    _tickets[idx]['updatedAt'] = DateTime.now().toString().substring(0, 19);
    return comment;
  }

  // ─── DASHBOARD ──────────────────────────────────────────────────────
  static Future<Map<String, dynamic>> getDashboardStats(
      String userId, String role) async {
    await _delay(400);
    final tickets = (role == AppConstants.roleAdmin ||
        role == AppConstants.roleHelpdesk)
        ? _tickets
        : _tickets.where((t) => t['userId'] == userId).toList();

    return {
      'total': tickets.length,
      'open': tickets.where((t) => t['status'] == AppConstants.statusOpen).length,
      'inProgress':
      tickets.where((t) => t['status'] == AppConstants.statusInProgress).length,
      'resolved':
      tickets.where((t) => t['status'] == AppConstants.statusResolved).length,
      'closed': tickets.where((t) => t['status'] == AppConstants.statusClosed).length,
      'recentTickets': tickets.take(3).toList(),
    };
  }

  // ─── NOTIFICATIONS ──────────────────────────────────────────────────
  static Future<List<Map<String, dynamic>>> getNotifications(
      String userId) async {
    await _delay(400);
    return [
      {
        'id': 'n001',
        'title': 'Tiket TCK-2026-002 diperbarui',
        'message': 'Status berubah menjadi In Progress',
        'type': 'ticket_update',
        'ticketId': 'TCK-2026-002',
        'isRead': false,
        'createdAt': '2026-04-23 08:05:00',
      },
      {
        'id': 'n002',
        'title': 'Tiket TCK-2026-003 selesai',
        'message': 'Tiket Anda telah diselesaikan oleh Admin',
        'type': 'ticket_resolved',
        'ticketId': 'TCK-2026-003',
        'isRead': false,
        'createdAt': '2026-04-22 16:05:00',
      },
      {
        'id': 'n003',
        'title': 'Komentar baru di TCK-2026-002',
        'message': 'Dewi Helpdesk menambahkan komentar',
        'type': 'new_comment',
        'ticketId': 'TCK-2026-002',
        'isRead': true,
        'createdAt': '2026-04-23 08:01:00',
      },
    ];
  }
}