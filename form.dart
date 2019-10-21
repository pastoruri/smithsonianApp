import 'package:flutter/material.dart';
import 'dart:io' show File;

// TODO: list view que muestra las especies que varan más de perú

class form extends StatefulWidget {

  List<File> chosenPhotosFromGallery; // list of paths to the images the user chose from his or her gallery

  form({this.chosenPhotosFromGallery});

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
      this._explanation = value;
    });
  }

  void change_comments(String value) {
    setState(() {
      this._comments = value;
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
                    onPressed: () {
                      // TODO: mandar la data al servidor o guardarla a un staging area
                      // TODO: get access token to identify each user uniquely
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