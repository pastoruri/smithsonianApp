import 'package:flutter/cupertino.dart';
import 'package:camera/camera.dart';
import 'take_picture.dart';
import 'dart:io' show Directory, File;
import 'form.dart';
import 'package:multi_image_picker/multi_image_picker.dart';
import 'main.dart' show LoginPage;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import 'package:simple_permissions/simple_permissions.dart';

// TODO: agregar video-tutorial

class Camera extends StatelessWidget {

  String name;
  SharedPreferences disk;

  Future<SharedPreferences> getDiskAccess() async {
    final disk = await SharedPreferences.getInstance();
    return disk;
  }

  static bool directoryErased;

  Camera({Key key, this.name, this.disk}) : super(key: key) {
    deleteAllImages();
  }

  static void deleteAllImages() async {
    Directory imageDir;
    if (directoryErased != null && !directoryErased) { // if someone already initialized directoryExists and it's set to false
      bool gotPermission = await SimplePermissions.requestPermission(Permission.WriteExternalStorage);
      if (gotPermission) {
        imageDir = Directory('/data/user/0/com.pi2.animal_recog/app_flutter/');
        imageDir.deleteSync(recursive: true);
        print("ALL IMAGES DELETED!");
        directoryErased = true;
      }
    } else {
      print("TRIED TO ILEGALLY ERASE DIRECTORY!");
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

// en caso de que el usuario tome la foto offline, guardar esas fotos/video en una base de datos local y apenas
// el usuario tenga acceso a internet, mandar las fotos

class Question extends StatefulWidget {
  Question({Key key, this.title, this.camera, this.disk}) : super(key: key) {
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
                "Click Para Borrar Todas Las Fotos Tomadas",
              ),
              onPressed: () {
                Camera.directoryErased = false;
                Camera.deleteAllImages();
                Camera.directoryErased = null;
              },
            ),
          ),
          Flexible( // 64 en todos pero mas arriba
            flex: 2,
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
            flex: 6,
            child: Center(
              child: RawMaterialButton(
                onPressed: AccessCamera,
                shape: CircleBorder(),
                fillColor: Colors.lightGreen,
                padding: const EdgeInsets.all(80.0),
                child: Icon(Icons.add_a_photo, size: 80.0),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
          onPressed: logout,
          elevation: 1.0,
//          shape: BeveledRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(16.0)), side: BorderSide(color: Colors.black, width: 1.0)),
          child: Icon(Icons.exit_to_app, size: 30.0)
      ),
    ),
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

  void _openGalery() async {
    Future<List<File>> choosePhotos;

    final userLocation = await getUserLocation();
    disk.setString("latitude", userLocation.latitude.toString());
    disk.setString("longitude", userLocation.longitude.toString());
    print("LATITUDE: ${userLocation.latitude}");
    print("LONGITUDE: ${userLocation.longitude}");

    try {
      choosePhotos = MultiImagePicker.pickImages(maxImages: 5);
      choosePhotos.then((photos) {
        print("PHOTOS:");
        for (var photo in photos) {
          print(photo);
        }
        Navigator.pop(_context); // dismiss alert dialog
        Navigator.push( // change activity
            context,
            new MaterialPageRoute(
                builder: (_context) => form(chosenPhotosFromGallery: photos, disk: disk,))
        );
      });
    } on Exception catch (e) {
      // TODO: alert user that only 5 images can be chosen
      print(e.toString());
    }
  }

  Future<void> AccessCamera() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          _context = context;
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget> [
                  GestureDetector(
                    child: Text('Tomar foto'),
                    onTap: () {
                        availableCameras().then(
                          (availableCameras) {
                            Navigator.pop(context); // dismiss dialog
                            changeActivity(_context, availableCameras.first); // change activity
                        }
                      );
                    },
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                  ),
                  GestureDetector(
                    child: Text('Elegir foto'),
                    // FIXME: al elegir las fotos, la app crashea
                    onTap: () {
                      _openGalery();
                    },
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}
