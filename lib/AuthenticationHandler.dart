import 'package:aad_oauth/aad_oauth.dart';
import 'package:aad_oauth/model/config.dart';
import 'package:jwt_decode/jwt_decode.dart';

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
      accessToken = await oauth.getIdToken();
      print('Logged in successfully, your access token: $accessToken');
    } catch (e) {
      print(e);
    }
  }

   Future<bool> isUserSignedIn() async{
    if(await oauth.getIdToken()==null){
      return false;
    }else{
      return true;
    }
  }

  void logout() async {
    await oauth.logout();
    accessToken="";
  }
  ///Parsing token and extracts users email
  String extractUserEmail(String token){
    Map<String, dynamic> payload = Jwt.parseJwt(token);
    return payload["preferred_username"];
  }
  ///Parsing token and extracts users name
  String extractUserName(String token){
    Map<String, dynamic> payload = Jwt.parseJwt(token);
    return payload["name"];
  }
  ///Returns parsed email
  String getUserEmail(){
    return extractUserEmail(accessToken);
  }
  ///Returns parsed name
  String getUserName(){
    return extractUserName(accessToken);
  }


}