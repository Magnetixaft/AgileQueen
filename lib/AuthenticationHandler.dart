import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';

class AuthenticationHandler {
  static final AuthenticationHandler _instance = AuthenticationHandler._();

  static final Config config = Config(
    tenant: '48306bc3-49ff-43e2-8964-4bd7d2dbba92',
    clientId: '8ba1b2e9-e630-4e49-909f-26101178f40d',
    scope: 'openid profile offline_access',
    redirectUri: 'https://login.live.com/oauth20_desktop.srf',
  );
  final AadOAuth oauth = AadOAuth(config);

  AuthenticationHandler._();

  static void initialize(){
  }

  static AuthenticationHandler getInstance() {
    return _instance;
  }

  void login() async {
    try {
      await oauth.login();
      var accessToken = await oauth.getAccessToken();
      print('Logged in successfully, your access token: $accessToken');
      } catch (e) {
      print(e);
    }
  }
  void logout() async {
    await oauth.logout();
    print('Logged out');
  }

  String dummyLogin() {
    return"test@gmail.com";
  }

}