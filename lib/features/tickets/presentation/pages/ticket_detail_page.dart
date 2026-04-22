import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uts_mobile/features/tickets/providers/ticket_provider.dart';
import 'package:uts_mobile/features/auth/providers/auth_provider.dart';

class TicketDetailPage extends ConsumerWidget {
  final String ticketId;

  const TicketDetailPage({super.key, required this.ticketId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(ticketDetailProvider);
    final user = ref.watch(authProvider).user;

    // load data
    Future.microtask(() {
      if (state.ticket == null) {
        ref.read(ticketDetailProvider.notifier).load(ticketId);
      }
    });

    if (state.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final ticket = state.ticket;
    if (ticket == null) {
      return const Scaffold(
        body: Center(child: Text("Tiket tidak ditemukan")),
      );
    }

    final controller = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text("Detail Ticket")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(ticket.title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(ticket.description),

            const SizedBox(height: 10),
            Text("Status: ${ticket.status}"),
            Text("Priority: ${ticket.priority}"),

            const Divider(height: 30),

            const Text("Comments", style: TextStyle(fontWeight: FontWeight.bold)),

            Expanded(
              child: ListView.builder(
                itemCount: ticket.comments.length,
                itemBuilder: (context, index) {
                  final c = ticket.comments[index];
                  return ListTile(
                    title: Text(c.userName),
                    subtitle: Text(c.content),
                  );
                },
              ),
            ),

            // 🔥 ADD COMMENT
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      hintText: "Tulis komentar...",
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () async {
                    if (user == null || controller.text.isEmpty) return;

                    await ref.read(ticketDetailProvider.notifier).addComment(
                      userId: user.id,
                      userName: user.name,
                      role: user.role,
                      content: controller.text,
                    );

                    controller.clear();
                  },
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}