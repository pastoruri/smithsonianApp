import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart' show getApplicationDocumentsDirectory;
import 'take_picture.dart' show TakePictureScreen;
import 'dart:io' show File;
import 'package:path/path.dart' show join;
import 'main.dart' show LoginPage;
import 'package:geolocator/geolocator.dart' show Geolocator, Position, LocationAccuracy;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'package:flutter/material.dart';

class Camera extends StatelessWidget {

  String name;
  static SharedPreferences disk;

  static bool directoryErased;
  static String documentsDirectoryPath;
  static bool gotPermission;

  Camera({Key key, this.name}) : super(key: key) {
    if (documentsDirectoryPath == null) {
      getApplicationDocumentsDirectory().then(
          (d) => documentsDirectoryPath = d.path
      );
    }
  }

  static void deleteAllImages(int imagesTaken) {

    if (imagesTaken == null) {
      imagesTaken = disk.getInt("imagesTaken") ?? null;
    }

    if (directoryErased != null && !directoryErased && imagesTaken != null && imagesTaken >= 1) {
      if (gotPermission) {
        disk.setInt("imagesTaken", 0);
        TakePictureScreen.imagesTaken = 0;
        TakePictureScreen.imagePath = "";
        print("ABOUT TO DELETE ALL IMAGES...");
        for (int i = 1; i <= imagesTaken; ++i) {
          String path = join(documentsDirectoryPath, '$i.png');
          File fileToDelete = File(path);
          fileToDelete.delete(recursive: true).then(
            (_) {
              print("DELETED FILE: ${fileToDelete.path}");
            }
          );
        }
        return;
      }
    } else {
      print("TRIED TO ILLEGALLY ERASE DIRECTORY!");
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: name,
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: Question(title: name, disk: disk),
    );
  }
}

class Question extends StatefulWidget { // en caso de que el usuario tome la foto offline, guardar esas fotos/video en una base de datos local y apenas
  Question({Key key, this.title, this.camera, this.disk}) : super(key: key) { // el usuario tenga acceso a internet, mandar las fotos
    isLoggedIn = disk.getBool("isLoggedIn") ?? false; // if isLoggedIn was not saved on disk, then user did not sign in, so set isLoggedIn to false
  }

  final SharedPreferences disk;
  bool isLoggedIn;
  final String title;
  final CameraDescription camera;

  @override
  _QuestionState createState() => _QuestionState(disk: disk, isLoggedIn: isLoggedIn);
}

class _QuestionState extends State<Question> {

  SharedPreferences disk;
  bool isLoggedIn;

  _QuestionState({Key key, this.disk, this.isLoggedIn});

  BuildContext _context;

  void logout() {
    showDialog(
      context: context,
      builder: (BuildContext alertDialogContext) {
        return AlertDialog(
          title: Text(isLoggedIn ? "¿Cerrar Sesión?" : "¿Registrarse?"),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                if (isLoggedIn) GestureDetector(
                  child: Text("Sí"),
                  onTap: () {
                    if (isLoggedIn) {
                      disk.setBool("isLoggedIn", false);
                      disk.setString("userName", "No has iniciado sesión");
                      disk.setString("userNameEmail", "");
                      isLoggedIn = false;
                      widget.isLoggedIn = false;

                      Navigator.of(alertDialogContext).pop(); // dismiss alert dialog
                      Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(builder: (_context) => LoginPage())
                      );
                    } else {
                      Navigator.of(alertDialogContext).pop(); // dismiss alert dialog
                    }
                  },
                ),
                if (isLoggedIn) Padding(
                  padding: EdgeInsets.all(20.0),
                ),
                if (isLoggedIn) GestureDetector(
                  child: Text('No'),
                  onTap: () {
                    Navigator.pop(alertDialogContext); // dismiss alert dialog
                  },
                ),
                if (!isLoggedIn) GestureDetector(
                  child: Text("Sí"),
                  onTap: () {
                    Navigator.pop(alertDialogContext); // dismiss alert dialog
                    Navigator.pushReplacement(
                        context,
                        new MaterialPageRoute(builder: (_context) => LoginPage())
                    );
                  },
                ),
                if (!isLoggedIn) Padding(
                  padding: EdgeInsets.all(20.0),
                ),
                if (!isLoggedIn) GestureDetector(
                  child: Text("No"),
                  onTap: () {
                    Navigator.pop(alertDialogContext); // dismiss alert dialog
                  },
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    _context = context;
    return new WillPopScope(
        child: Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Column(
        children: <Widget>[
          Padding(padding: EdgeInsets.all(6.0),),
          Flexible(
            flex: 2,
            child: RaisedButton(
              child: Text(
                "Borrar Todas Las Fotos Tomadas",
              ),
              onPressed: () {
                Camera.directoryErased = false;
                Camera.deleteAllImages(null);
                Camera.directoryErased = null;
              },
            ),
          ),
          Flexible( // 64 en todos pero mas arriba
            flex: 1,
            child: Center(
              child: Text(
                "Haga click en la cámara para tomar la foto del animal varado",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Flexible(
            flex: 5,
            child: Center(
              child: RawMaterialButton(
                onPressed: () {
                  availableCameras().then(
                    (availableCameras) {
                      changeActivity(_context, availableCameras.first);
                    }
                  );
                },
                shape: CircleBorder(),
                fillColor: Colors.lightGreen,
                padding: EdgeInsets.all(80.0),
                child: Icon(Icons.add_a_photo, size: 80.0),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: logout,
          elevation: 1.0,
          child: Icon(Icons.exit_to_app, size: 30.0)
      ),
    ),
        // prevent user from going back
        onWillPop: () async => false);
  }

  void changeActivity(BuildContext contexto, CameraDescription camera) {
    Navigator.push(
      contexto,
      new MaterialPageRoute(builder: (context) => TakePictureScreen(camera: camera, disk: disk)),
    );
  }

  Future<Position> getUserLocation() async {
    Position location = await Geolocator().getCurrentPosition(LocationAccuracy.high);
    return location;
  }
}
