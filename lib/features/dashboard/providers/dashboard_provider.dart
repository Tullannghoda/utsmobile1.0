import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/repositories/dashboard_repository.dart';

final dashboardRepositoryProvider = Provider<DashboardRepository>((ref) => DashboardRepository());

class DashboardState {
  final Map<String, dynamic>? data;
  final bool isLoading;
  final String? error;

  const DashboardState({this.data, this.isLoading = false, this.error});

  DashboardState copyWith({Map<String, dynamic>? data, bool? isLoading, String? error, bool clearError = false}) =>
      DashboardState(
        data: data ?? this.data,
        isLoading: isLoading ?? this.isLoading,
        error: clearError ? null : error ?? this.error,
      );
}

class DashboardNotifier extends StateNotifier<DashboardState> {
  final DashboardRepository _repo;
  DashboardNotifier(this._repo) : super(const DashboardState());

  Future<void> load(String userId, String role) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await _repo.getDashboardData(userId, role);
      state = state.copyWith(data: data, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }
}

final dashboardProvider = StateNotifierProvider<DashboardNotifier, DashboardState>((ref) {
  return DashboardNotifier(ref.watch(dashboardRepositoryProvider));
});