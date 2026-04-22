import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/models/ticket_model.dart';
import '../data/repositories/ticket_repository.dart';

// ─── Repository Provider ──────────────────────────────────────────────────────
final ticketRepositoryProvider = Provider<TicketRepository>((ref) {
  return TicketRepository();
});

// ─── Ticket List State ────────────────────────────────────────────────────────
class TicketListState {
  final List<TicketModel> tickets;
  final bool isLoading;
  final String? error;
  final String filterStatus; // '' = all

  const TicketListState({
    this.tickets = const [],
    this.isLoading = false,
    this.error,
    this.filterStatus = '',
  });

  List<TicketModel> get filteredTickets => filterStatus.isEmpty
      ? tickets
      : tickets.where((t) => t.status == filterStatus).toList();

  TicketListState copyWith({
    List<TicketModel>? tickets,
    bool? isLoading,
    String? error,
    String? filterStatus,
    bool clearError = false,
  }) =>
      TicketListState(
        tickets: tickets ?? this.tickets,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
        filterStatus: filterStatus ?? this.filterStatus,
      );
}

// ─── Ticket List Notifier ─────────────────────────────────────────────────────
class TicketListNotifier extends StateNotifier<TicketListState> {
  final TicketRepository _repo;

  TicketListNotifier(this._repo) : super(const TicketListState());

  Future<void> loadTickets(String userId, String role) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final tickets = await _repo.getTickets(userId, role);
      state = state.copyWith(tickets: tickets, isLoading: false);
    } catch (e) {
      state = state.copyWith(
          isLoading: false, error: e.toString().replaceAll('Exception: ', ''));
    }
  }

  Future<bool> createTicket({
    required String title,
    required String description,
    required String category,
    required String priority,
    required String userId,
    required String userName,
    List<String> attachments = const [],
  }) async {
    try {
      final ticket = await _repo.createTicket(
        title: title,
        description: description,
        category: category,
        priority: priority,
        userId: userId,
        userName: userName,
        attachments: attachments,
      );
      state = state.copyWith(tickets: [ticket, ...state.tickets]);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<void> updateStatus(String id, String status) async {
    final updated = await _repo.updateStatus(id, status);
    state = state.copyWith(
      tickets: state.tickets
          .map((t) => t.id == id ? updated : t)
          .toList(),
    );
  }

  void setFilter(String status) => state = state.copyWith(filterStatus: status);
}

// ─── Providers ────────────────────────────────────────────────────────────────
final ticketListProvider =
StateNotifierProvider<TicketListNotifier, TicketListState>((ref) {
  return TicketListNotifier(ref.watch(ticketRepositoryProvider));
});

// ─── Ticket Detail State ──────────────────────────────────────────────────────
class TicketDetailState {
  final TicketModel? ticket;
  final bool isLoading;
  final bool isSending;
  final String? error;

  const TicketDetailState({
    this.ticket,
    this.isLoading = false,
    this.isSending = false,
    this.error,
  });

  TicketDetailState copyWith({
    TicketModel? ticket,
    bool? isLoading,
    bool? isSending,
    String? error,
    bool clearError = false,
  }) =>
      TicketDetailState(
        ticket: ticket ?? this.ticket,
        isLoading: isLoading ?? this.isLoading,
        isSending: isSending ?? this.isSending,
        error: clearError ? null : error ?? this.error,
      );
}

class TicketDetailNotifier extends StateNotifier<TicketDetailState> {
  final TicketRepository _repo;

  TicketDetailNotifier(this._repo) : super(const TicketDetailState());

  Future<void> load(String id) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final ticket = await _repo.getTicketDetail(id);
      state = state.copyWith(ticket: ticket, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> addComment({
    required String userId,
    required String userName,
    required String role,
    required String content,
  }) async {
    if (state.ticket == null) return;
    state = state.copyWith(isSending: true);
    try {
      final comment = await _repo.addComment(
        ticketId: state.ticket!.id,
        userId: userId,
        userName: userName,
        role: role,
        content: content,
      );
      final updatedComments = [...state.ticket!.comments, comment];
      state = state.copyWith(
        ticket: state.ticket!.copyWith(comments: updatedComments),
        isSending: false,
      );
    } catch (e) {
      state = state.copyWith(isSending: false, error: e.toString());
    }
  }

  Future<void> updateStatus(String status) async {
    if (state.ticket == null) return;
    final updated = await _repo.updateStatus(state.ticket!.id, status);
    state = state.copyWith(ticket: updated);
  }

  Future<void> assignTicket(String assignedTo, String assignedToId) async {
    if (state.ticket == null) return;
    final updated =
    await _repo.assignTicket(state.ticket!.id, assignedTo, assignedToId);
    state = state.copyWith(ticket: updated);
  }
}

final ticketDetailProvider =
StateNotifierProvider.autoDispose<TicketDetailNotifier, TicketDetailState>(
        (ref) {
      return TicketDetailNotifier(ref.watch(ticketRepositoryProvider));
    });
