import '../../../../core/utils/mock_api.dart';
import '../../../../core/services/local_storage_service.dart';
import '../models/user_model.dart';

class AuthRepository {
  Future<UserModel> login(String email, String password) async {
    final res = await MockApi.login(email, password);
    final user = UserModel.fromJson(res['user']);
    await LocalStorageService.saveToken(res['token']);
    await LocalStorageService.saveUser(
      id: user.id,
      name: user.name,
      email: user.email,
      role: user.role,
    );
    return user;
  }

  Future<void> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await MockApi.register(name: name, email: email, password: password);
  }

  Future<void> logout() async {
    await LocalStorageService.clearAll();
  }

  UserModel? getCurrentUser() {
    final id = LocalStorageService.getUserId();
    if (id == null) return null;
    return UserModel(
      id: id,
      name: LocalStorageService.getUserName() ?? '',
      email: LocalStorageService.getUserEmail() ?? '',
      role: LocalStorageService.getUserRole() ?? 'user',
    );
  }

  bool isLoggedIn() => LocalStorageService.isLoggedIn();
}