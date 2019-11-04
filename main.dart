import 'package:flutter/material.dart';
import 'dart:convert' show json;
import 'package:http/http.dart' as http;
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart' show FacebookSignInButton, GoogleSignInButton;
import 'camera.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:firebase_auth/firebase_auth.dart';

// TODO: conseguir el access token del servidor

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
      new MaterialPageRoute(builder: (_context) => Camera(name: name, disk: disk)),
    );
  }

  Future<SharedPreferences> getDiskAccess() async {
    final disk = await SharedPreferences.getInstance();
    return disk;
  }

  static int cont = 0;

  LoginPage() {

    getDiskAccess().then(
        (diskRef) {
          disk = diskRef;
          isLoggedIn = disk.getBool("isLoggedIn") ?? false;
          userName = disk.getString("userName") ?? "No has iniciado sesión";
          userNameEmail = disk.getString("userNameEmail") ?? "";
          facebookToken = disk.get("facebookToken") ?? "";
          googleToken = disk.get("googleToken") ?? "";
          print("LOGIN PAGE HAS BEEN CREATED $cont TIMES");
          cont++;
          if (isLoggedIn) {
            changeActivity(contexto, userName);
          }
        }
    );
  }

  void getAccesToken() async {
    // TODO: get access token from server and save it on disk
    // TODO: cuidado, que si el token ya se obtuvo, no se debe hacer el request nuevamente
  }

  @override
  Widget build(BuildContext context) {
    contexto = context;
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Text(name),
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

                    getAccesToken();

                    loginWithFacebook.then(
                        (x) {
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
                    Future<void> loginWithGoogle = signInWithGoogle();

                    getAccesToken();

                    loginWithGoogle.then(
                        (x) {
                          changeActivity(context, userName);
                        }
                    );

                  },
                ),
              ),

              Padding(padding: EdgeInsets.all(4.0),),

              Flexible(
                flex: 2,
                child: RaisedButton(
                  child: Text(
                    "Saltar Inicio de Sesión",
                    style: TextStyle(fontSize: 18.0),
                  ),

                  onPressed: () {
                    getAccesToken();
                    changeActivity(context, userName);
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
        final token = facebookLoginResult.accessToken.token;
        final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
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

    print("############################");
    print("USERNAME: $name");
    print("EMAIL: $email");
    disk.setBool("isLoggedIn", true);
    disk.setString("userName", "Bienvenido $name");
    disk.setString("name", name);
    userName = disk.getString("userName");
    disk.setString("userNameEmail", email);
    return "Bienvenido $name";
  }

  void signOutGoogle() async {
    await googleSignIn.signOut();
  }

}








































