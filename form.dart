import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'camera.dart' show Camera;
import 'package:http/http.dart' as http;
import 'package:path/path.dart' show join;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'specie_form.dart' show sform, Specie;
import 'package:http_parser/http_parser.dart' show MediaType;

class form extends StatefulWidget {

  List<File> chosenPhotosFromGallery; // list of paths to the images the user chose from his or her gallery
  SharedPreferences disk;
  int imagesTaken;
  String name;
  String email;
  String accessToken;
  String longitude;
  String latitude;
  static String specie;

  form({this.chosenPhotosFromGallery, this.disk, this.imagesTaken}) {
    name = disk.getString("name");
    email = disk.getString("userNameEmail");
    accessToken = disk.getString("accessToken");
    specie = disk.getString("specie");
    longitude = disk.getString("longitude");
    latitude = disk.getString("latitude");
  }

  final List<Specie> choices = const <Specie> [
    const Specie(icon: Image(image: AssetImage('assets/libary_animals/LoboMarinoChusco_Otaria_flavescens.jpg')), title: "Mamífero Marino"),
    const Specie(icon: Image(image: AssetImage('assets/libary_animals/Guanay_Leucocarbo_bougainvillii.jpg')), title: "Ave"),
    const Specie(icon: Image(image: AssetImage('assets/libary_animals/TortugaLaud_Dermochelys_coriacea.jpg')), title: "Reptil"),
    const Specie(icon: Image(image: AssetImage('assets/libary_animals/CangrejoCarretero_Ocypode gaudichaudii.jpg')), title: "Invertebrado"),
  ];

  @override
  _formState createState() {
    return _formState();
  }
}

class _formState extends State<form> {
  bool _isDead = true;
  String _explanation = '';
  String _comments = '';
  static bool buttonIsDisabled = false;

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
                actions: <Widget>[
                  FlatButton(
                    child: Text("Ok"),
                    onPressed: () {
                      Navigator.of(alertDialogContext).pop();
                    },
                  ),
                ],
              );
            }
        );
      }

    });
  }

  void change_explanation(String value) {
    setState( () {
      this._explanation = value; // causa de muerte
    });
  }

  void change_comments(String value) {
    setState( () {
      this._comments = value; // comentarios
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cuéntanos más sobre el animal"),
      ),
      body: Center( // Center
        child: Align(
          alignment: Alignment.topCenter,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget> [
                Flexible( // Padding
                  flex: 2, // padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        "Especie: ",
                        style: TextStyle(fontSize: 20.0),
                      ),
                      if (form.specie == null) RaisedButton(
                          child: Text("Seleccionar especie"),
                          onPressed: () {
                            sform.disk = widget.disk;
                            Navigator.push(
                              context,
                              new MaterialPageRoute(
                                builder: (context) => sform(title: "Especie del animal varado", lista: widget.choices),
                              ),
                            );
                          }
                      ),
                      if (form.specie != null) Column(
                        children: <Widget>[
                           Text(
                            form.specie,
                            style: TextStyle(fontSize: 20.0),
                          ),
                          Padding(
                            padding: EdgeInsets.all(3.0),
                          ),
                          RaisedButton(
                              child: Text("Cambiar especie"),
                              onPressed: () {
                                sform.disk = widget.disk;
                                Navigator.push(
                                  context,
                                  new MaterialPageRoute(
                                    builder: (context) => sform(title: "Especie del animal varado", lista: widget.choices),
                                  ),
                                );
                              }
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                
                Padding(
                  padding: EdgeInsets.all(5.0),
                ),

                Flexible( // Padding
                  flex: 2, // padding: EdgeInsets.all(16.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
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
                  padding: EdgeInsets.all(5.0),
                ),

                Flexible( // Padding
                  flex: 2, // padding: EdgeInsets.all(16.0),
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
                  padding: EdgeInsets.all(5.0),
                ),

                Flexible( // Padding
                  flex: 2, // padding: EdgeInsets.all(16.0),
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
                  padding: EdgeInsets.all(5.0),
                ),

                Flexible( // Padding
                  flex: 2, // // padding: EdgeInsets.all(20.0),
                  child: RaisedButton(
                    onPressed: _formState.buttonIsDisabled ? null : () async {

                      _formState.buttonIsDisabled = true;

                      // draw screen again so that user knows that request is in progress
                      setState(() {});

//                      Map<String, String> headers = {
//                        'Content-type': 'application/json',
//                        'Accept': 'application/json',
//                        'Authorization': 'Bearer ${widget.accessToken}'
//                      };
//
//                      var baseURL = Uri.parse("http://35.226.71.159/api/v1/");
//                      var request = new http.MultipartRequest("POST", baseURL)
//                          ..headers.addAll(headers)
//                          ..fields['is_alive'] = '$_isDead'
//                          ..fields['cause_of_death'] = '$_explanation'
//                          ..fields['comment'] = '$_comments'
//                          ..fields['longitude'] = '${widget.longitude}'
//                          ..fields['latitude'] = '${widget.latitude}'
//                          ..fields['species'] = '${form.specie}';


                      List<File> images = List<File>();
                      int imagenesTomadas = widget.imagesTaken;
                      String documentsDirectoryPath = Camera.documentsDirectoryPath;

                      for (int i = 1; i <= imagenesTomadas; ++i) {
                        String path = join(documentsDirectoryPath, '$i.png');
                        File fileToAdd = File(path);
                        images.add(fileToAdd);
                        print("IMAGE FILE: ${fileToAdd.path}");
                      }

//                      int i = 1;
//                      for (File image in images) {
//                        request.files.add(
//                            http.MultipartFile.fromBytes(
//                                'Image $i',
//                                await File(image.path).readAsBytes(),
//                                contentType: MediaType('image', 'png')
//                            )
//                        );
//                        i++;
//                      }
//
//                      var response = await request.send();
//
//                      if (response.statusCode == 200) {
//                          //// TODO: thank the user for his or her contribution
//                          print("REQUEST SEND!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!");
//                      }

                      print("IMAGENES TOMADAS: ${widget.imagesTaken}");
                      Camera.directoryErased = false;
                      Camera.deleteAllImages(widget.imagesTaken);
                      Camera.directoryErased = true;

                      form.specie = null;
                      widget.disk.setString("specie", null);

                      _formState.buttonIsDisabled = false;

                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pop(context);
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