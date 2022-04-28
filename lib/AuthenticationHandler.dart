import 'dart:convert';

import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:http/http.dart' as http;

class AuthenticationHandler {
  static final AuthenticationHandler _instance = AuthenticationHandler._();
  var accessToken;

  static final Config config = Config(
    tenant: '48306bc3-49ff-43e2-8964-4bd7d2dbba92',
    clientId: '8ba1b2e9-e630-4e49-909f-26101178f40d',
    scope: 'openid profile offline_access',
    redirectUri: 'msauth://com.example.flutter_application_1/Nwn3Du03NhXB4Wt4ZMuGlrxrLH8%3D',
  );
  final AadOAuth oauth = AadOAuth(config);

  AuthenticationHandler._();

  static void initialize() {
  }

  static AuthenticationHandler getInstance() {
    return _instance;
  }

  void login() async {
    try {
      await oauth.login();
      accessToken = await oauth.getAccessToken();
      print('Logged in successfully, your access token: $accessToken');
    } catch (e) {
      print(e);
    }
  }

  void logout() async {
    await oauth.logout();
    print('Logged out');
  }

  void testing() async {
    User test = await fetchUser() as User;
    print(test.id);
  }

  Future<User> fetchUser() async {
    final response = await http
        .get(Uri.parse('https://graph.microsoft.com/'),headers: { "Authorization": "Bearer $accessToken", "Content-Type": "application/json"});
    print(response.toString());
    print(response.statusCode);
    if (response.statusCode == 200) {
      // If the server did return a 200 OK response, then parse the JSON.
      return User.fromJson(jsonDecode(response.body));
    } else {
      // If the server did not return a 200 OK response,
      throw Exception('Failed');
    }
  }

}
class User {
  final String id;

  const User({
    required this.id,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['displayName'],
    );
  }
}