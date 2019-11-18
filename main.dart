import 'package:flutter/material.dart';
import 'dart:convert' show json;
import 'package:http/http.dart' as http;
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart' show FacebookSignInButton, GoogleSignInButton;
import 'camera.dart' show Camera;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:simple_permissions/simple_permissions.dart';

// TODO: improve splash screen

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      home: new LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  final String name = "Inicio de Sesión";

  bool isLoggedIn;

  String userName;
  String userNameEmail;

  String facebookToken;
  String googleToken;

  String accesToken; // accesToken del servidor para identificar al usuario

  SharedPreferences disk;
  BuildContext contexto;

  void changeActivity(BuildContext _contexto, String name) {
    Navigator.pushReplacement(
      _contexto,
      new MaterialPageRoute(builder: (_context) {
        Camera.disk = disk;
        return Camera(name: name);
      }),
    );
  }

  Future<SharedPreferences> getDiskAccess() async {
    Camera.gotPermission = await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
    final disk = await SharedPreferences.getInstance();
    return disk;
  }

  LoginPage() {

    getDiskAccess().then(
        (diskRef) {
          disk = diskRef;
          isLoggedIn = disk.getBool("isLoggedIn") ?? false;
          userName = disk.getString("userName") ?? "No has iniciado sesión";
          userNameEmail = disk.getString("userNameEmail") ?? "";
          facebookToken = disk.get("facebookToken") ?? "";
          googleToken = disk.get("googleToken") ?? "";
          if (isLoggedIn) {
            changeActivity(contexto, userName);
          }
        }
    );
  }

  void getAccesToken(String loginProvider) async {
    String token = disk.getString("accessToken");
    if (token != null) {
      return; // accessToken exists
    } else {
      // FIXME: no agarra el token, debug with Postman
//      final respuesta = await http.get('http://35.226.71.159/rest-auth/$loginProvider/');
//      final profile = json.decode(respuesta.body);
//      disk.setString("accessToken", profile['token']);
//      print("ACCESS TOKEN DEL SERVIDOR: ${profile['token']}");
    }
  }

  @override
  Widget build(BuildContext context) {
    contexto = context;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.lightGreen,
        title: Center(
          child: Text(name, style: TextStyle(color: Colors.black),),
        ),
      ),
      body: Container(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                flex: 2,
                child:
                FacebookSignInButton(
                  text: "Continuar con Facebook",
                  onPressed: () {
                    Future<void> loginWithFacebook = initiateFacebookLogin();

//                    getAccesToken('facebook');

                    loginWithFacebook.then(
                        (nothing) {
                          changeActivity(context, userName);
                        }
                    );
                  },
                ),
              ),

              Padding(padding: EdgeInsets.all(4.0),),

              Flexible(
                flex: 2,
                child:
                GoogleSignInButton(
                  text: "Continuar con Google",
                  onPressed: () {
                    Future<String> loginWithGoogle = signInWithGoogle();

//                    getAccesToken('google');

                    loginWithGoogle.then(
                        (welcomeMessage) {
                          changeActivity(context, welcomeMessage);
                        }
                    );

                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// LogIn/LogOut Stuff

  FacebookLogin facebookLogin = new FacebookLogin();
  GoogleSignIn googleSignIn = new GoogleSignIn(
    scopes: <String>[
      'email'
    ],
  );
  final FirebaseAuth _auth = FirebaseAuth.instance;


  Future<void> initiateFacebookLogin() async {
    final facebookLoginResult = await facebookLogin.logInWithReadPermissions(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        disk.setBool("isLoggedIn", false);
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        disk.setBool("isLoggedIn", false);
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        String token = facebookLoginResult.accessToken.token;
        final graphResponse = await http.get('https://graph.facebook.com/v5.0/me?fields=name,first_name,last_name,email&access_token=$token');
        final profile = json.decode(graphResponse.body);
        String name = profile["name"]; // the user name
        disk.setBool("isLoggedIn", true);
        disk.setString("userName", "Bienvenido " + name);
        disk.setString("name", name);
        userName = disk.getString("userName");
        disk.setString("userNameEmail", profile["email"]);
//        disk.setString("facebookToken", token);
        print("Facebook token: $token");
        break;
    }
  }

  Future<String> signInWithGoogle() async {
    final GoogleSignInAccount googleSignInAccount = await googleSignIn.signIn();
    final GoogleSignInAuthentication googleSignInAuthentication =
    await googleSignInAccount.authentication;
    final AuthCredential credential = GoogleAuthProvider.getCredential(
        accessToken: googleSignInAuthentication.accessToken,
        idToken: googleSignInAuthentication.idToken);

    final AuthResult authResult = await _auth.signInWithCredential(credential);
    final FirebaseUser user = authResult.user;

    final FirebaseUser currentUser = await _auth.currentUser();
    assert(user.uid == currentUser.uid);

    String email = user.email;
    String name = user.displayName;

    print("USERNAME: $name");
    print("EMAIL: $email");
    disk.setBool("isLoggedIn", true);
    disk.setString("userName", "Bienvenido $name");
    disk.setString("name", name);
    userName = disk.getString("userName");
    disk.setString("userNameEmail", email);
    return "Bienvenido $name";
  }

}








































