import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:http/http.dart' as http;
import 'camara.dart'; // activity para tomarte foto al animal

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
        home: new LoginPage());
  }
}

class LoginPage extends StatelessWidget {
  bool isLoggedIn = false;
  var name = "Facebook Login";

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
          title: Text(name),
        ),
        body: Container(
          child: Center(
            child: isLoggedIn ? Text("Logged In") : RaisedButton(
              child: Text("Login with Facebook"),
              onPressed: () {
                Future<String> loginWithFacebook = initiateFacebookLogin();

                loginWithFacebook.then( (userName) {
                  changeActivity(context, userName.toString());
                });
              },
            ),
          ),
        ),
      );
  }

  Future<String> initiateFacebookLogin() async {
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








































