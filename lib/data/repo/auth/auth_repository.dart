import 'package:invoice/core/api/api_client.dart';
import 'package:invoice/core/api/api_endpoints.dart';
import 'package:invoice/data/models/auth/login_response_model.dart';

class AuthRepository {
  final ApiClient apiClient;

  AuthRepository(this.apiClient);

  Future<LoginResponseModel> login({
    required String email,
    required String password,
  }) {
    return apiClient.post(
      ApiEndpoints.login,
      data: {'email': email, 'password': password},
      parser: LoginResponseModel.fromJson,
    );
  }
}
