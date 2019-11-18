import 'dart:async';
import 'package:animal_recog/camera.dart' show Camera;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'form.dart' show form;
import 'dart:io' show File;
import 'package:geolocator/geolocator.dart' show Geolocator, LocationAccuracy, Position;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

class TakePictureScreen extends StatefulWidget {

  SharedPreferences disk;
  CameraDescription camera;
  static int imagesTaken = 0;

  TakePictureScreen({Key key, this.camera, this.disk}) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState(disk: disk);
}

class TakePictureScreenState extends State<TakePictureScreen> {

  SharedPreferences disk;

  TakePictureScreenState({Key key, this.disk});

  navigate({BuildContext context, String path, int imagesTaken}) async {
    final newImageCount = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DisplayPictureScreen(imagePath: path, imagesTaken: imagesTaken, disk: disk),
      ),
    );

    imagesTaken = newImageCount;
  }

  void imageTaken() {
    setState(() {
      if (TakePictureScreen.imagesTaken != 5) {
        TakePictureScreen.imagesTaken += 1;
      }
    });
  }

  CameraController _controller;
  Future<void> _initializeControllerFuture;

  Camera availableCamera;

  @override
  void initState() {
    super.initState();
    // To display the current output from the Camera,
    // create a CameraController.
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.camera,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<Position> getUserLocation() async {
    Position location = await Geolocator().getCurrentPosition(LocationAccuracy.high);
    return location;
  }

  void getCoordinates() async {
    var userLocation = await getUserLocation();
    disk.setString("latitude", userLocation.latitude.toString());
    disk.setString("longitude", userLocation.longitude.toString());
    print("LATITUDE: ${userLocation.latitude}");
    print("LONGITUDE: ${userLocation.longitude}");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Tome una foto')),
      // Wait until the controller is initialized before displaying the
      // camera preview. Use a FutureBuilder to display a loading spinner
      // until the controller has finished initializing
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            // If the Future is complete, display the preview.
            return CameraPreview(_controller);
          } else {
            // Otherwise, display a loading indicator.
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
          onPressed: () async {

            imageTaken();

            // Take the Picture in a try / catch block. If anything goes wrong,
            // catch the error.
            try {
              // Ensure that the camera is initialized.
              await _initializeControllerFuture;

              final path = join(Camera.documentsDirectoryPath, '${TakePictureScreen.imagesTaken}.png');

              // Attempt to take a picture and log where it's been saved.
              await _controller.takePicture(path);

              // If the picture was taken, display it on a new screen.
              navigate(context: context, path: path, imagesTaken: TakePictureScreen.imagesTaken);

              disk.setInt("imagesTaken", TakePictureScreen.imagesTaken);
              print('Saved image at ${path}');
              getUserLocation(); // called on a background thread, hopefully

            } catch (e) {
              // If an error occurs, log the error to the console.
              print(e);
            }
          }
      ),
    );
  }
}

class DisplayPictureScreen extends StatefulWidget {
  DisplayPictureScreen({Key key, this.imagePath, this.imagesTaken, @required this.disk}) : super(key: key) {
    if (imagesTaken != 5) {
      fivePhotosTaken = false;
    } else {
      fivePhotosTaken = true;
    }
  }

  SharedPreferences disk;
  String imagePath;
  bool fivePhotosTaken;
  int imagesTaken;

  @override
  DisplayPictureScreenState createState() => DisplayPictureScreenState();
}

class DisplayPictureScreenState extends State<DisplayPictureScreen> {

   void imageDeleted() {
     setState(() {
       widget.imagesTaken -= 1;
     });
   }

   @override
   Widget build(BuildContext context) {
     print("ABOUT TO DISPLAY AN IMAGE AT PATH: ${widget.imagePath}");
     print("BY THE WAY, IMAGES TAKEN: ${widget.imagesTaken}");
     return Scaffold(
       appBar: AppBar(
           title: Text('¿Esta imagen está bien?'),
       ),
       body: Column(
         mainAxisSize: MainAxisSize.min,
         children: <Widget>[
           Expanded(
             flex: 28,
             child: Image.file(File(widget.imagePath)),
           ),
           Expanded(
             flex: 4,
             child: Column(
               children: <Widget>[
                 Flexible(
                   fit: FlexFit.loose,
                   flex: 2,
                   child: Text("Imágenes tomadas: ${widget.imagesTaken}"),
                 ),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: <Widget>[
                     if (!widget.fivePhotosTaken) Flexible(
                       flex: 1,
                       fit: FlexFit.loose,
                       child: FlatButton.icon(
                         color: Colors.lightGreen,
                         icon: const Icon(Icons.add_a_photo),
                         label: const Text('Añadir Foto'),
                         onPressed: () {
                           Navigator.pop(context, TakePictureScreen.imagesTaken);
                         },
                       ),
                     ),
                     Flexible(
                       flex: 1,
                       fit: FlexFit.loose,
                       child: FlatButton.icon(
                           icon: const Icon(Icons.arrow_right),
                           label: const Text('Confirmar'),
                           color: Colors.lightGreen,
                           onPressed: () {
                             Navigator.push(
                               context,
                               new MaterialPageRoute(
                                   builder: (context) => form(disk: widget.disk, imagesTaken: widget.imagesTaken)),
                             );
                           }
                       ),
                     ),
                   ],
                 ),
               ],
             ),
           ),
         ],
       ),
     );
   }

}








































