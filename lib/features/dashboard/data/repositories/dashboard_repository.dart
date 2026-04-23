import '../../../../core/utils/mock_api.dart';

class DashboardRepository {
  Future<Map<String, dynamic>> getDashboardData(String userId, String role)
async {
    return await MockApi.getDashboardStats(userId, role);
  }
}