import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_auth_buttons/flutter_auth_buttons.dart' show FacebookSignInButton, GoogleSignInButton;
import 'camera.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new LoginPage(),
    );
  }
}

class LoginPage extends StatelessWidget {
  bool isLoggedIn = false;
  var name = "Login Page";

  void changeActivity(BuildContext contexto, String name) {
    Navigator.push(
      contexto,
      new MaterialPageRoute(builder: (context) => Camera(name: name)),
    );
  }

  @override
  Widget build(BuildContext context) {
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
                  onPressed: () {
                    Future<String> loginWithFacebook = initiateFacebookLogin();

                    loginWithFacebook.then( (userName) {
                      changeActivity(context, userName.toString());
                    });

                  },
                ),
              ),

              Padding(
                padding: EdgeInsets.all(8.0),
                child:
                GoogleSignInButton(
                  text: "Continue with Google",
                  onPressed: () {
                    // TODO: GOOGLE SIGN IN LOGIC
                    changeActivity(context, "Not logged in!");
                  },
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: RaisedButton(
                  child: const Text("Skip"),

                  onPressed: () {
                    changeActivity(context, "Not logged in!");
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<String> initiateFacebookLogin() async {
    // TODO: manual facebook login flow, save token and user info to disk
    var facebookLogin = FacebookLogin();
    var facebookLoginResult = await facebookLogin.logInWithReadPermissions(['email']);
    switch (facebookLoginResult.status) {
      case FacebookLoginStatus.error:
        print("Error");
        isLoggedIn = false;
        return "You are not logged in!";
        break;
      case FacebookLoginStatus.cancelledByUser:
        print("CancelledByUser");
        isLoggedIn = false;
        return "You are not logged in!";
        break;
      case FacebookLoginStatus.loggedIn:
        print("LoggedIn");
        isLoggedIn = true;
        final token = facebookLoginResult.accessToken.token;
        final graphResponse = await http.get('https://graph.facebook.com/v2.12/me?fields=name,first_name,last_name,email&access_token=${token}');
        final profile = json.decode(graphResponse.body);
        name = "Logged in as " + profile["name"];
        return name;
        break;
    }
  }
}








































