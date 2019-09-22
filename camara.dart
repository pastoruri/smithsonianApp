import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'take_picture.dart';

class Camera extends StatelessWidget {

  Future<CameraDescription> getAvailableCameras() async {
    final cameras = await availableCameras();
    final firstCamera = cameras.first;

    return firstCamera;
  }

  var camera;

  String name = "You are not logged in!";

  Camera({Key key, this.name}) : super(key: key) {
    camera = getAvailableCameras();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: name,
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: Question(title: name, camera: camera,),
    );
  }
}

// en caso de que el usuario tome la foto offline, guardar esas fotos/video en una base de datos local y apenas
// el usuario tenga acceso a internet, mandar las fotos

class Question extends StatefulWidget {
  Question({Key key, this.title, this.camera}) : super(key: key);

  final String title;
  final CameraDescription camera;

  @override
  _QuestionState createState() => _QuestionState(camera: camera);
}

class _QuestionState extends State<Question> {

  final CameraDescription camera;

  _QuestionState({Key key, this.camera});

  @override
  Widget build(BuildContext context) {
    _context = context;
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: RawMaterialButton(
          onPressed: AccessCamera,
          shape: CircleBorder(),
          fillColor: Colors.lightGreen,
          padding: const EdgeInsets.all(80.0),
          child: Icon(Icons.add_a_photo, size: 80.0),
        ),
      ),
    );
  }

  void changeActivity(BuildContext contexto) {
    Navigator.push(
      contexto,
      new MaterialPageRoute(builder: (context) => TakePictureScreen(camera: camera)),
    );
  }

  var _context;

  void _openCamara() {
    changeActivity(_context);
  }

  void _openGalery() {
    var photo = ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
  }

  Future<void> AccessCamera() {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: SingleChildScrollView(
              child: ListBody(
                children: <Widget>[
                  GestureDetector(
                    child: Text('Tomar foto'),
                    onTap: _openCamara,
                  ),
                  Padding(
                    padding: EdgeInsets.all(20.0),
                  ),
                  GestureDetector(
                    child: Text('Elegir foto'),
                    onTap: _openGalery,
                  ),
                ],
              ),
            ),
          );
        }
    );
  }
}
