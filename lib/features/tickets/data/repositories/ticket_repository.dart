import '../../../../core/utils/mock_api.dart';
import '../models/ticket_model.dart';
import '../models/comment_model.dart';

class TicketRepository {
  Future<List<TicketModel>> getTickets(String userId, String role) async {
    final data = await MockApi.getTickets(userId, role);
    return data.map((e) => TicketModel.fromJson(e)).toList();
  }

  Future<TicketModel> getTicketDetail(String id) async {
    final data = await MockApi.getTicketDetail(id);
    return TicketModel.fromJson(data);
  }

  Future<TicketModel> createTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
    required String userId,
    required String userName,
    List<String> attachments = const [],
  }) async {
    final data = await MockApi.createTicket(
      title: title,
      description: description,
      category: category,
      priority: priority,
      userId: userId,
      userName: userName,
      attachments: attachments,
    );
    return TicketModel.fromJson(data);
  }

  Future<TicketModel> updateStatus(String id, String status) async {
    final data = await MockApi.updateTicketStatus(id, status);
    return TicketModel.fromJson(data);
  }

  Future<TicketModel> assignTicket(
      String id, String assignedTo, String assignedToId) async {
    final data = await MockApi.assignTicket(id, assignedTo, assignedToId);
    return TicketModel.fromJson(data);
  }

  Future<CommentModel> addComment({
    required String ticketId,
    required String userId,
    required String userName,
    required String role,
    required String content,
  }) async {
    final data = await MockApi.addComment(
      ticketId: ticketId,
      userId: userId,
      userName: userName,
      role: role,
      content: content,
    );
    return CommentModel.fromJson(data);
  }
}