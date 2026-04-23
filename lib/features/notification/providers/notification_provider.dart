import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/utils/mock_api.dart';

class NotificationState {
  final List<Map<String, dynamic>> notifications;
  final bool isLoading;

  const NotificationState({
    this.notifications = const [],
    this.isLoading = false,
  });

  int get unreadCount =>
      notifications.where((n) => n['isRead'] == false).length;

  NotificationState copyWith({
    List<Map<String, dynamic>>? notifications,
    bool? isLoading,
  }) {
    return NotificationState(
      notifications: notifications ?? this.notifications,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class NotificationNotifier extends StateNotifier<NotificationState> {
  NotificationNotifier() : super(const NotificationState());

  Future<void> load(String userId) async {
    state = state.copyWith(isLoading: true);

    final data = await MockApi.getNotifications(userId);

    state = state.copyWith(
      notifications: List<Map<String, dynamic>>.from(data),
      isLoading: false,
    );
  }

  void markRead(String id) {
    final updated = state.notifications.map((n) {
      if (n['id'] == id) {
        return {...n, 'isRead': true};
      }
      return n;
    }).toList();

    state = state.copyWith(notifications: updated);
  }

  void markAllRead() {
    final updated = state.notifications
        .map((n) => {...n, 'isRead': true})
        .toList();

    state = state.copyWith(notifications: updated);
  }
}

final notificationProvider =
StateNotifierProvider<NotificationNotifier, NotificationState>((ref) {
  return NotificationNotifier();
});