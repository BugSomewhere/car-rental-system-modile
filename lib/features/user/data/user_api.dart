import 'package:dio/dio.dart';

import '../../../core/network/api_client.dart';
import '../../../core/network/api_exception.dart';
import '../domain/user_profile.dart';

/// Suggested user-facing backend API from docs/mobile-api-and-database-spec.md.
class UserApi {
  UserApi(this._client);

  final ApiClient _client;

  Future<void> startRegistration({
    required String email,
    required String fullName,
    required String password,
  }) =>
      _post('/api/account/registrations', {
        'email': email,
        'fullName': fullName,
        'password': password,
      });

  Future<void> verifyRegistration({
    required String email,
    required String otp,
  }) =>
      _post('/api/account/registrations/verify', {'email': email, 'otp': otp});

  Future<void> resendRegistrationOtp(String email) =>
      _post('/api/account/registrations/resend', {'email': email});

  Future<void> login({
    required String email,
    required String password,
    bool rememberMe = true,
  }) =>
      _post('/api/auth/login', {
        'email': email,
        'password': password,
        'rememberMe': rememberMe,
      });

  Future<void> logout() async {
    await _post('/api/auth/logout', const {});
    await _client.clearSession();
  }

  Future<void> requestPasswordReset(String email) =>
      _post('/api/account/password-resets', {'email': email});

  Future<void> resetPassword({
    required String email,
    required String otp,
    required String newPassword,
  }) =>
      _post('/api/account/password-resets/verify', {
        'email': email,
        'otp': otp,
        'newPassword': newPassword,
      });

  Future<UserProfile> getProfile() async {
    final response =
        await _request(() => _client.dio.get('/api/account/profile'));
    return UserProfile.fromJson(_data(response.data));
  }

  Future<UserProfile> updateProfile({
    required String fullName,
    String? gender,
    String? phone,
  }) async {
    final response =
        await _request(() => _client.dio.put('/api/account/profile', data: {
              'fullName': fullName,
              'gender': gender,
              'phone': phone,
            }));
    return UserProfile.fromJson(_data(response.data));
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) =>
      _post('/api/account/password', {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      });

  Future<void> _post(String path, Map<String, dynamic> data) =>
      _request(() => _client.dio.post(path, data: data));

  Future<Response<dynamic>> _request(
      Future<Response<dynamic>> Function() call) async {
    try {
      return await call();
    } on DioException catch (error) {
      final body = error.response?.data;
      final message = body is Map<String, dynamic>
          ? (body['detail'] ?? body['title'] ?? 'Request failed').toString()
          : 'Unable to contact the server.';
      throw ApiException(message, statusCode: error.response?.statusCode);
    }
  }

  Map<String, dynamic> _data(dynamic body) {
    if (body is Map<String, dynamic> && body['data'] is Map<String, dynamic>) {
      return body['data'] as Map<String, dynamic>;
    }
    if (body is Map<String, dynamic>) return body;
    throw const ApiException('The server returned an unexpected response.');
  }
}
