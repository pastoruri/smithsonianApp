import 'dart:io';
import 'package:flutter/material.dart';
import 'camera.dart' show Camera;
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

// TODO: get token from piero's server
// TODO: once we get that token, send request with token as header

class form extends StatefulWidget {

  List<File> chosenPhotosFromGallery; // list of paths to the images the user chose from his or her gallery
  SharedPreferences disk;
  String name;
  String email;
  String accessToken;

  form({this.chosenPhotosFromGallery, @required this.disk}) {
    disk.getString("name");
    disk.getString("userNameEmail");
    disk.getString("accessToken");
  }

  @override
  _formState createState() {
    return _formState();
  }
}

class _formState extends State<form> {
  var _species = ['Desconocido', 'Pez', 'Mamífero'];
  var _actualspecie = 'Desconocido';
  bool _isDead = true;
  var _explanation = '';
  var _comments = '';

  void changeSpecie(String value) {
    setState(() {
      this._actualspecie = value;
    });
  }

  void changeIsDead(bool value) {
    setState(() {
      this._isDead = value;

      if (!_isDead) {
        showDialog(
            context: context,
            builder: (BuildContext alertDialogContext) {
              return AlertDialog(
                title: Text("¡Atención!"),
                content: SingleChildScrollView(
                  child: ListBody(
                    children: <Widget>[
                      Text("Además de reportar al animal mediante este aplicación, recomendamos que llame al SERFOR para reportar al animal vivo.\nSu número es: (01) 2259005."),
                    ],
                  ),
                ),
              );
            }
        );
      }

    });
  }

  void change_explanation(String value) {
    setState(() {
      this._explanation = value; // causa de muerte
    });
  }

  void change_comments(String value) {
    setState(() {
      this._comments = value; // comentarios
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cuéntanos más sobre el animal"),
      ),
      body: Center(
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: <Widget>[
                      Text(
                        "Especie : ",
                        style: TextStyle(fontSize: 20.0),
                      ),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                      DropdownButton<String>(
                        items: _species.map((String dropDownStringItem){
                          return DropdownMenuItem<String>(
                              value: dropDownStringItem,
                              child: Text(dropDownStringItem, style: TextStyle(fontSize: 18.0),)
                          );
                        }).toList(),
                        onChanged: (String newValueSelected) {
                          changeSpecie(newValueSelected);
                        },
                        value: _actualspecie,
                      ),
                    ],
                  ),
                ),

                Padding(
                  /// Qué bonito me salio esto csm
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: <Widget>[
                      Text("¿Está vivo? : ", style: TextStyle(fontSize: 20.0),),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                      Row(
                        children: <Widget>[
                          Column(
                            children: <Widget>[
                              Checkbox(
                                  value: !_isDead,
                                  // se marco que el animal esta vivo
                                  onChanged: (bool newboolvalue) {
                                    changeIsDead(!newboolvalue);
                                    print("IS THE ANIMAL DEAD? $_isDead");
                                  }
                              ),
                              Text("Sí")
                            ],
                          ),
                          Column(
                            children: <Widget>[
                              Checkbox(
                                value: _isDead,
                                  onChanged: (bool newBoolValue) {
                                    changeIsDead(newBoolValue);
                                    print("IS THE ANIMAL DEAD? $_isDead");
                                  },
                              ),
                              Text("No")
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      if (_isDead) Text("Causa de muerte : ", style: TextStyle(fontSize: 20.0), textAlign: TextAlign.left,),
                      if (_isDead) TextField(
                        onChanged: (String value){
                          change_explanation(value);
                        },
                      )
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Text("Comentarios : ", style: TextStyle(fontSize: 20.0), textAlign: TextAlign.left,),
                      TextField(
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        onChanged: (String value){
                          change_comments(value);
                        },
                      )
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(20.0),
                  child: RaisedButton(
                    onPressed: () async {
                      Directory imageDir = Directory('/data/user/0/com.pi2.animal_recog/app_flutter/');
                      var files = imageDir.listSync();

                      for (var file in files) {
                        print("FILE: $file");
                      }

                      /// sending the data to the server
                      //////////////////////////////////////////

//                      // base url
//                      String url = 'https://jsonplaceholder.typicode.com/posts';
//
//                      // headers
//                      // FIXME?
//                      Map<String, String> headers = {
//                        'Content-type': 'application/json',
//                        'Accept': 'application/json',
//                        'Authorization': '${widget.accessToken}'
//                      };
//
//                      // data to send
//                      String data = '{"name": "${widget.name}", "email": "${widget.email}", "esta_muerto": "$_isDead", "cause_de_muerte": "$_explanation", "comentarios": "$_comments"}';
//
//                      // make post request
//                      final response = await http.post(url, headers: headers, body: data);
//
//                      // check the status code for the result
//                      int statusCode = response.statusCode;
//
//                      // body of the response
//                      String body = response.body;

                      //////////////////////////////////////////

                      // FIXME? for debug purposes maybe comment these lines
                      Camera.directoryErased = false;
                      Camera.deleteAllImages(); // delete all images after sending request with images
                      Camera.directoryErased = null;

                      print("REQUEST SENT!");
                    },
                    color: Colors.lightGreen,
                    child: Text(
                        'Enviar',
                        style: TextStyle(fontSize: 20)
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }
}