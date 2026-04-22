import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uts_mobile/features/profile/presentation/pages/profile_page.dart';
import '../../../auth/providers/auth_provider.dart';
import '../../providers/dashboard_provider.dart';

class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final dashboard = ref.watch(dashboardProvider);
    final user = ref.watch(authProvider).user;

    // load data sekali
    Future.microtask(() {
      if (user != null && dashboard.data == null) {
        ref.read(dashboardProvider.notifier).load(user.id, user.role);
      }
    });

    if (dashboard.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (dashboard.error != null) {
      return Scaffold(
        body: Center(child: Text(dashboard.error!)),
      );
    }

    final data = dashboard.data;
    if (data == null) return const SizedBox();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const ProfilePage(),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () {
              ref.read(authProvider.notifier).logout();
              Navigator.pushReplacementNamed(context, '/');
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Statistik Tiket",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _statCard("Total", data['total'], Colors.black),
                _statCard("Open", data['open'], Colors.orange),
                _statCard("Progress", data['inProgress'], Colors.blue),
              ],
            ),

            const SizedBox(height: 20),

            const Text(
              "Recent Tickets",
              style: TextStyle(fontSize: 16),
            ),

            ...List.generate(data['recentTickets'].length, (i) {
              final t = data['recentTickets'][i];
              return ListTile(
                title: Text(t['title']),
                subtitle: Text(t['status']),
              );
            }),
            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () {
                Navigator.pushNamed(context, '/tickets');
              },
              child: const Text("Lihat Semua Tiket"),
            ),
          ],
        ),
      ),
    );
  }
  Widget _statCard(String title, int value, Color color) {
    return Expanded(
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              Text(title),
              const SizedBox(height: 5),
              Text(
                "$value",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
