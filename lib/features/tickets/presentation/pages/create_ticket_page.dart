import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:uts_mobile/features/tickets/providers/ticket_provider.dart';
import 'package:uts_mobile/features/auth/providers/auth_provider.dart';

class CreateTicketPage extends ConsumerWidget {
  const CreateTicketPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final title = TextEditingController();
    final desc = TextEditingController();

    String category = "Jaringan";
    String priority = "medium";

    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text("Buat Tiket")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: title,
              decoration: const InputDecoration(labelText: "Judul"),
            ),
            TextField(
              controller: desc,
              decoration: const InputDecoration(labelText: "Deskripsi"),
              maxLines: 3,
            ),

            const SizedBox(height: 10),

            DropdownButtonFormField(
              value: category,
              items: const [
                DropdownMenuItem(value: "Jaringan", child: Text("Jaringan")),
                DropdownMenuItem(value: "Hardware", child: Text("Hardware")),
                DropdownMenuItem(value: "Aplikasi", child: Text("Aplikasi")),
              ],
              onChanged: (v) => category = v.toString(),
              decoration: const InputDecoration(labelText: "Kategori"),
            ),

            DropdownButtonFormField(
              value: priority,
              items: const [
                DropdownMenuItem(value: "low", child: Text("Low")),
                DropdownMenuItem(value: "medium", child: Text("Medium")),
                DropdownMenuItem(value: "high", child: Text("High")),
              ],
              onChanged: (v) => priority = v.toString(),
              decoration: const InputDecoration(labelText: "Prioritas"),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () async {
                if (user == null) return;

                final success = await ref
                    .read(ticketListProvider.notifier)
                    .createTicket(
                  title: title.text,
                  description: desc.text,
                  category: category,
                  priority: priority,
                  userId: user.id,
                  userName: user.name,
                );

                if (success) {
                  Navigator.pop(context);
                }
              },
              child: const Text("Submit"),
            ),
          ],
        ),
      ),
    );
  }
}