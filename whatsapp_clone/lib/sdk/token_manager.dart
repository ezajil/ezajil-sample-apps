import 'api_error.dart';  // Assuming you have an equivalent Dart class for APIError.

class TokenManager {
  String? accessToken;
  Future<String> Function()? fetchTokenCallback;

  // Private constructor
  TokenManager._privateConstructor();

  // Single instance, private static
  static final TokenManager _instance = TokenManager._privateConstructor();

  // Public factory constructor to access the instance
  factory TokenManager() {
    return _instance;
  }

  void setToken(String token) {
    accessToken = token;
  }

  void setFetchTokenCallback(Future<String> Function() callback) {
    fetchTokenCallback = callback;
  }

  Future<String> get([bool forceTokenRefresh = false]) async {
    if (accessToken != null && !forceTokenRefresh) {
      return accessToken!;
    }
    if (fetchTokenCallback == null) {
      throw APIError(401, "Authorization failed: make sure to define a valid token or a correct callback");
    }
    try {
      String newToken = await fetchTokenCallback!();
      accessToken = newToken;
      return newToken;
    } catch (error) {
      if (error is APIError) {
        rethrow;
      }
      throw APIError(500, "Error fetching token: ${error.toString()}");
    }
  }
}
