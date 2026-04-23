import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/ticket_provider.dart';
import '../../data/models/ticket_model.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/widgets/common_widgets.dart';
import '../../../../core/constants/app_constants.dart';

class TicketDetailPage extends ConsumerStatefulWidget {
  final String ticketId;
  const TicketDetailPage({super.key, required this.ticketId});

  @override
  ConsumerState<TicketDetailPage> createState() => _TicketDetailPageState();
}

class _TicketDetailPageState extends ConsumerState<TicketDetailPage> {
  final _commentCtrl = TextEditingController();
  final _scrollCtrl = ScrollController();

  @override
  void initState() {
    super.initState();
    Future.microtask(() =>
        ref.read(ticketDetailProvider.notifier).load(widget.ticketId));
  }

  @override
  void dispose() {
    _commentCtrl.dispose();
    _scrollCtrl.dispose();
    super.dispose();
  }

  Future<void> _sendComment() async {
    final user = ref.read(authProvider).user;
    if (user == null || _commentCtrl.text.trim().isEmpty) return;
    await ref.read(ticketDetailProvider.notifier).addComment(
      userId: user.id,
      userName: user.name,
      role: user.role,
      content: _commentCtrl.text.trim(),
    );
    _commentCtrl.clear();
    await Future.delayed(const Duration(milliseconds: 100));
    if (_scrollCtrl.hasClients) {
      _scrollCtrl.animateTo(_scrollCtrl.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300), curve: Curves.easeOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(ticketDetailProvider);
    final user = ref.watch(authProvider).user;

    if (state.isLoading) return const Scaffold(body: AppLoadingIndicator());
    if (state.ticket == null) return const Scaffold(body: AppErrorView(message: 'Tiket tidak ditemukan'));

    final ticket = state.ticket!;
    final canManage = user?.canManageTickets ?? false;
    final colors = AppTheme.ticketBlockPalette;
    final hash = ticket.id.codeUnits.fold(0, (p, e) => p + e);
    final blockColors = List.generate(6, (i) => colors[(hash * (i + 1) * 13) % colors.length]);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Tiket'),
        actions: [
          if (canManage)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert),
              onSelected: (v) => _handleAdminAction(context, ref, ticket, v),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'status', child: Row(children: [
                  Icon(Icons.swap_horiz, size: 18), SizedBox(width: 8), Text('Update Status')])),
                const PopupMenuItem(value: 'assign', child: Row(children: [
                  Icon(Icons.person_add, size: 18), SizedBox(width: 8), Text('Assign Tiket')])),
              ],
            ),
        ],
      ),
      body: Column(
        children: [
          // --- Color Block Header ---
          SizedBox(
            height: 8,
            child: Row(
              children: blockColors.map((c) => Expanded(child: Container(color: c))).toList(),
            ),
          ),
          // --- Body ---
          Expanded(
            child: ListView(
              controller: _scrollCtrl,
              padding: const EdgeInsets.all(16),
              children: [
                // Ticket ID & status
                Row(
                  children: [
                    Text(ticket.id, style: const TextStyle(fontFamily: 'monospace', color: Colors.grey, fontSize: 12)),
                    const Spacer(),
                    StatusBadge(status: ticket.status),
                  ],
                ),
                const SizedBox(height: 10),
                // Title
                Text(ticket.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                // Info chips row
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: [
                    _InfoChip(icon: Icons.folder, label: ticket.category),
                    PriorityBadge(priority: ticket.priority),
                    _InfoChip(icon: Icons.person, label: ticket.userName),
                    if (ticket.assignedTo != null)
                      _InfoChip(icon: Icons.support_agent, label: 'Ditangani: ${ticket.assignedTo!}', color: AppTheme.secondary),
                  ],
                ),
                const SizedBox(height: 16),
                // Description
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Deskripsi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                        const SizedBox(height: 8),
                        Text(ticket.description, style: const TextStyle(height: 1.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Timestamps
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 13, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text('Dibuat: ${ticket.createdAt.substring(0, 10)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                    const SizedBox(width: 16),
                    Text('Diperbarui: ${ticket.updatedAt.substring(0, 10)}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    const Text('Komentar', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(color: AppTheme.primary.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
                      child: Text('${ticket.comments.length}', style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                // Comments
                if (ticket.comments.isEmpty)
                  const AppEmptyState(message: 'Belum ada komentar', icon: Icons.chat_bubble_outline)
                else
                  ...ticket.comments.map((c) => _CommentBubble(comment: c, currentUserId: user?.id ?? '')),
                const SizedBox(height: 8),
              ],
            ),
          ),
          // --- Comment Input ---
          if (ticket.status != AppConstants.statusClosed)
            Container(
              padding: const EdgeInsets.fromLTRB(12, 8, 8, 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -2))],
              ),
              child: SafeArea(
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _commentCtrl,
                        decoration: InputDecoration(
                          hintText: 'Tulis komentar...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                          filled: true,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        ),
                        maxLines: null,
                        textInputAction: TextInputAction.newline,
                      ),
                    ),
                    const SizedBox(width: 8),
                    state.isSending
                        ? const Padding(
                      padding: EdgeInsets.all(12),
                      child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)),
                    )
                        : IconButton.filled(
                      onPressed: _sendComment,
                      icon: const Icon(Icons.send),
                      style: IconButton.styleFrom(backgroundColor: AppTheme.primary, foregroundColor: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _handleAdminAction(BuildContext context, WidgetRef ref, TicketModel ticket, String action) {
    if (action == 'status') {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => _StatusBottomSheet(ticket: ticket, ref: ref),
      );
    } else if (action == 'assign') {
      showModalBottomSheet(
        context: context,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
        builder: (_) => _AssignBottomSheet(ref: ref),
      );
    }
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;

  const _InfoChip({required this.icon, required this.label, this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: (color ?? Colors.grey).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color ?? Colors.grey.shade600),
          const SizedBox(width: 5),
          Text(label, style: TextStyle(fontSize: 12, color: color ?? Colors.grey.shade700)),
        ],
      ),
    );
  }
}

class _CommentBubble extends StatelessWidget {
  final dynamic comment;
  final String currentUserId;
  const _CommentBubble({required this.comment, required this.currentUserId});

  @override
  Widget build(BuildContext context) {
    final isMe = comment.userId == currentUserId;
    final isStaff = comment.role == AppConstants.roleAdmin || comment.role == AppConstants.roleHelpdesk;

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            children: [
              if (!isMe) ...[
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isStaff ? AppTheme.secondary : Colors.grey.shade300,
                  child: Icon(isStaff ? Icons.support_agent : Icons.person, size: 16, color: Colors.white),
                ),
                const SizedBox(width: 8),
              ],
              Text(isMe ? 'Kamu' : comment.userName, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
              if (isStaff) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                  decoration: BoxDecoration(color: AppTheme.secondary, borderRadius: BorderRadius.circular(6)),
                  child: Text(comment.role == AppConstants.roleAdmin ? 'Admin' : 'Helpdesk',
                      style: const TextStyle(fontSize: 9, color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? AppTheme.primary : (isStaff ? AppTheme.secondary.withOpacity(0.1) : Colors.grey.shade100),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isMe ? 16 : 4),
                bottomRight: Radius.circular(isMe ? 4 : 16),
              ),
            ),
            child: Text(comment.content, style: TextStyle(color: isMe ? Colors.white : null, height: 1.4)),
          ),
          const SizedBox(height: 2),
          Text(comment.createdAt.substring(0, 16), style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }
}

class _StatusBottomSheet extends StatelessWidget {
  final TicketModel ticket;
  final WidgetRef ref;
  const _StatusBottomSheet({required this.ticket, required this.ref});

  @override
  Widget build(BuildContext context) {
    final statuses = [
      AppConstants.statusOpen,
      AppConstants.statusInProgress,
      AppConstants.statusResolved,
      AppConstants.statusClosed,
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Update Status Tiket', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...statuses.map((s) => ListTile(
            leading: Container(width: 12, height: 12, decoration: BoxDecoration(color: AppTheme.getStatusColor(s), shape: BoxShape.circle)),
            title: Text(AppTheme.getStatusLabel(s)),
            trailing: ticket.status == s ? const Icon(Icons.check, color: AppTheme.primary) : null,
            onTap: () async {
              await ref.read(ticketDetailProvider.notifier).updateStatus(s);
              if (context.mounted) Navigator.pop(context);
            },
          )),
        ],
      ),
    );
  }
}

class _AssignBottomSheet extends StatelessWidget {
  final WidgetRef ref;
  const _AssignBottomSheet({required this.ref});

  @override
  Widget build(BuildContext context) {
    final staff = [
      {'id': 'u002', 'name': 'Dewi Helpdesk', 'role': 'Helpdesk'},
      {'id': 'u003', 'name': 'Admin Sistem', 'role': 'Admin'},
    ];

    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Assign Tiket ke', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          ...staff.map((s) => ListTile(
            leading: CircleAvatar(backgroundColor: AppTheme.secondary, child: const Icon(Icons.person, color: Colors.white)),
            title: Text(s['name']!),
            subtitle: Text(s['role']!),
            onTap: () async {
              await ref.read(ticketDetailProvider.notifier).assignTicket(s['name']!, s['id']!);
              if (context.mounted) Navigator.pop(context);
            },
          )),
        ],
      ),
    );
  }
}