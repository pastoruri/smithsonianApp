import 'package:flutter/material.dart';
import 'dart:convert' show json;
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart' show FacebookSignInButton, GoogleSignInButton;
import 'camera.dart';
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

// TODO: agregar logica de login con google

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
          print("CONT: $cont");
          cont++;
          if (isLoggedIn) {
            changeActivity(contexto, userName);
          }
        }
    );
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
              Padding(
                padding: EdgeInsets.all(8.0),
                child:
                FacebookSignInButton(
                  text: "Continuar con Facebook",
                  onPressed: () {
                    Future<void> loginWithFacebook = initiateFacebookLogin();

                    loginWithFacebook.then(
                        (x) {
                          changeActivity(context, userName);
                        }
                    );

                  },
                ),
              ),

              Padding(
                padding: EdgeInsets.all(8.0),
                child:
                GoogleSignInButton(
                  text: "Continuar con Google",
                  onPressed: () {
                    Future<void> loginWithGoogle = initiateGoogleLogin();

                    loginWithGoogle.then(
                        (x) {
                          changeActivity(context, userName);
                        }
                    );

                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: Text(
                    "Saltar Inicio de Sesión",
                    style: TextStyle(fontSize: 18.0),
                  ),

                  onPressed: () {
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

  Future<void> initiateFacebookLogin() async {
    FacebookLogin facebookLogin = FacebookLogin();
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
        // TODO: añadir el header al request con el token que me regrese el primer requets a AWS
        final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=$token');
        final profile = json.decode(graphResponse.body);
        disk.setBool("isLoggedIn", true);
        disk.setString("userName", "Bienvenido " + profile["name"]);
        userName = disk.getString("userName");
        disk.setString("userNameEmail", profile["email"]);
        disk.setString("facebookToken", token);
        print("Facebook token: $token");
        break;
    }
  }

  Future<void> initiateGoogleLogin() async {
    // TODO: implement google log in logic...
  }

}








































