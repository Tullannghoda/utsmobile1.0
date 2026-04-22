import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uts_mobile/features/auth/providers/auth_provider.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return Scaffold(
      appBar: AppBar(title: const Text("Profile")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 40),
            const SizedBox(height: 10),

            Text(user?.name ?? '-', style: const TextStyle(fontSize: 18)),
            Text(user?.email ?? '-'),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                ref.read(authProvider.notifier).logout();
                Navigator.pushReplacementNamed(context, '/');
              },
              child: const Text("Logout"),
            ),
          ],
        ),
      ),
    );
  }
}