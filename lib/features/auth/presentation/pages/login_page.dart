import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/auth_provider.dart';

class LoginPage extends ConsumerWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final email = TextEditingController();
    final pass = TextEditingController();
    final auth = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(title: const Text("Login")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: email,
              decoration: const InputDecoration(labelText: "Email"),
            ),
            TextField(
              controller: pass,
              decoration: const InputDecoration(labelText: "Password"),
              obscureText: true,
            ),

            const SizedBox(height: 10),

            if (auth.isLoading)
              const CircularProgressIndicator(),

            ElevatedButton(
              onPressed: () async {
                final success =
                await ref.read(authProvider.notifier).login(
                  email.text,
                  pass.text,
                );

                if (success) {
                  Navigator.pushReplacementNamed(
                      context, '/dashboard');
                }
              },
              child: const Text("Login"),
            ),

            if (auth.error != null)
              Text(
                auth.error!,
                style: const TextStyle(color: Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}