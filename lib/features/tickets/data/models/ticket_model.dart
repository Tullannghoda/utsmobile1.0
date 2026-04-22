import 'comment_model.dart';

class TicketModel {
  final String id;
  final String title;
  final String description;
  final String status;
  final String priority;
  final String category;
  final String createdAt;
  final String updatedAt;
  final String userId;
  final String userName;
  final String? assignedTo;
  final String? assignedToId;
  final List<CommentModel> comments;
  final List<String> attachments;

  const TicketModel({
    required this.id,
    required this.title,
    required this.description,
    required this.status,
    required this.priority,
    required this.category,
    required this.createdAt,
    required this.updatedAt,
    required this.userId,
    required this.userName,
    this.assignedTo,
    this.assignedToId,
    required this.comments,
    required this.attachments,
  });

  factory TicketModel.fromJson(Map<String, dynamic> json) => TicketModel(
    id: json['id'] ?? '',
    title: json['title'] ?? '',
    description: json['description'] ?? '',
    status: json['status'] ?? 'open',
    priority: json['priority'] ?? 'medium',
    category: json['category'] ?? '',
    createdAt: json['createdAt'] ?? '',
    updatedAt: json['updatedAt'] ?? '',
    userId: json['userId'] ?? '',
    userName: json['userName'] ?? '',
    assignedTo: json['assignedTo'],
    assignedToId: json['assignedToId'],
    comments: (json['comments'] as List? ?? [])
        .map((c) => CommentModel.fromJson(c))
        .toList(),
    attachments: List<String>.from(json['attachments'] ?? []),
  );

  TicketModel copyWith({
    String? status,
    String? assignedTo,
    String? assignedToId,
    List<CommentModel>? comments,
  }) =>
      TicketModel(
        id: id,
        title: title,
        description: description,
        status: status ?? this.status,
        priority: priority,
        category: category,
        createdAt: createdAt,
        updatedAt: DateTime.now().toString().substring(0, 19),
        userId: userId,
        userName: userName,
        assignedTo: assignedTo ?? this.assignedTo,
        assignedToId: assignedToId ?? this.assignedToId,
        comments: comments ?? this.comments,
        attachments: attachments,
      );

  /// Generates deterministic colors from ticket ID (BatakFest-inspired)
  List<int> get colorIndices {
    final hash = id.codeUnits.fold(0, (prev, e) => prev + e);
    return List.generate(
        6, (i) => (hash * (i + 1) * 13) % 12);
  }

  bool get isOpen => status == 'open';
  bool get isInProgress => status == 'in_progress';
  bool get isResolved => status == 'resolved';
  bool get isClosed => status == 'closed';
}