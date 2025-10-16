class HttpTools {
  static const String baseUrl = String.fromEnvironment("SERVER_URL", defaultValue: "http://localhost:8001");
  static const String _api = "/api";

  static Uri generateUri(String path, {int version = 1, Map<String, String>? queryParameters}) {
    assert(path.startsWith("/"));

    final decodedBase = Uri.parse(baseUrl);
    final fullPath = "$_api/v$version$path";

    if (decodedBase.scheme == "https") {
      return Uri.https(decodedBase.authority, fullPath, queryParameters);
    } else {
      final result = Uri.http(
        "${decodedBase.host}:${decodedBase.port}",
        fullPath,
        queryParameters,
      );

      return result;
    }
  }

  // static Map<String, String> generateAuthHeaders() {
  //   final token = TokenManager().getToken();
  //   return {
  //     "Authorization": "Bearer $token",
  //     "X-Agent": "Neptuno",
  //   };
  // }
}
