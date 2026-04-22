import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uts_mobile/features/auth/providers/auth_provider.dart';
import 'package:uts_mobile/features/tickets/providers/ticket_provider.dart';
import 'ticket_detail_page.dart';
import 'create_ticket_page.dart';

class TicketListPage extends ConsumerWidget {
  const TicketListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ticketState = ref.watch(ticketListProvider);
    final user = ref.watch(authProvider).user;

    // load data sekali
    Future.microtask(() {
      if (user != null && ticketState.tickets.isEmpty) {
        ref
            .read(ticketListProvider.notifier)
            .loadTickets(user.id, user.role);
      }
    });

    return Scaffold(
      appBar: AppBar(title: const Text("Ticket List")),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const CreateTicketPage(),
            ),
          );
        },
        icon: const Icon(Icons.add),
        label: const Text("Tambah"),
      ),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // 🔹 FILTER BUTTON
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _filterButton(ref, "", "All"),
                _filterButton(ref, "open", "Open"),
                _filterButton(ref, "in_progress", "Progress"),
                _filterButton(ref, "resolved", "Done"),
              ],
            ),

            const SizedBox(height: 10),

            // 🔹 LIST
            Expanded(
              child: _buildList(ticketState),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(TicketListState state) {
    if (state.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.error != null) {
      return Center(child: Text(state.error!));
    }

    final tickets = state.filteredTickets;

    if (tickets.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inbox, size: 50, color: Colors.grey),
            SizedBox(height: 10),
            Text("Belum ada tiket"),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: tickets.length,
      itemBuilder: (context, index) {
        final t = tickets[index];

        return Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: ListTile(
            title: Text(
              t.title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text("${t.category} • ${t.status}"),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _statusColor(t.status),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                t.priority,
                style: const TextStyle(color: Colors.white),
              ),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TicketDetailPage(ticketId: t.id),
                ),
              );
            },
          ),
        );

      },
    );
  }

  Widget _filterButton(WidgetRef ref, String status, String label) {
    return ElevatedButton(
      onPressed: () {
        ref.read(ticketListProvider.notifier).setFilter(status);
      },
      child: Text(label),
    );
  }
  Color _statusColor(String status) {
    switch (status) {
      case 'open':
        return Colors.orange;
      case 'in_progress':
        return Colors.blue;
      case 'resolved':
        return Colors.green;
      case 'closed':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }
}