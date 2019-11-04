import 'dart:async';
import 'package:animal_recog/camera.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' show join;
import 'package:path_provider/path_provider.dart';
import 'form.dart';
import 'dart:io' show File;
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TakePictureScreen extends StatefulWidget {

  SharedPreferences disk;
  CameraDescription camera;
  int imagesTaken = 0;
  bool firstImageTaken = false;

  TakePictureScreen({Key key, this.camera, this.disk}) : super(key: key);

  @override
  TakePictureScreenState createState() => TakePictureScreenState(disk: disk);
}


// A screen that allows users to take a picture using a given camera.

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

    widget.imagesTaken = newImageCount;
  }

  void imageTaken() {
    setState(() {
      if (widget.imagesTaken != 5) {
        widget.imagesTaken += 1;
      }
    });
  }

  CameraController _controller;
  Future<void> _initializeControllerFuture;

  var availableCamera;

  @override
  void initState() {

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
        // Provide an onPressed callback.
        onPressed: () async {
            imageTaken();
            widget.firstImageTaken = true;

            // Take the Picture in a try / catch block. If anything goes wrong,
            // catch the error.
            try {
              // Ensure that the camera is initialized.
              await _initializeControllerFuture;

              final path = join(
                (await getApplicationDocumentsDirectory()).path,
                '${widget.imagesTaken}.png');

              // Attempt to take a picture and log where it's been saved.
              await _controller.takePicture(path);

              // If the picture was taken, display it on a new screen.
              navigate(context: context, path: path, imagesTaken: widget.imagesTaken);

              print('Saved image at ${path}');
              getUserLocation(); // called on a background thread, hopefully

            } catch (e) {
              // If an error occurs, log the error to the console.
              print(e);
            }
        },
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
  final String imagePath;
  bool fivePhotosTaken;
  int imagesTaken;

  @override
  DisplayPictureScreenState createState() => DisplayPictureScreenState();
}

class DisplayPictureScreenState extends State<DisplayPictureScreen> {

   void imageDeleted() {
     setState(() {
       --widget.imagesTaken;
     });
   }

   @override
   Widget build(BuildContext context) {
     return Scaffold(
       appBar: AppBar(
           title: Text('¿Esta imagen está bien?'),
       ),
       // The image is stored as a file on the device. Use the `Image.file`
       // constructor with the given path to display the image.
       body: Column(
//         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
                       flex: 2,
                       fit: FlexFit.loose,
                       child: FlatButton.icon(
                         color: Colors.lightGreen,
                         icon: Icon(Icons.add_a_photo),
                         label: Text('Añadir Foto'),
                         onPressed: () {
                           Navigator.pop(context, widget.imagesTaken);
                         },
                       ),
                     ),
                     Flexible(
                       flex: 2,
                       fit: FlexFit.loose,
                       child: FlatButton.icon(
                           color: Colors.lightGreen,
                           icon: Icon(Icons.delete),
                           label: const Text('Borrar Foto'),
                           onPressed: () {
                             final imageFile = File(widget.imagePath);
                             imageFile.deleteSync(); // delete current photo from files
                             print('Images taken count before deletion: ${widget.imagesTaken}');
                             imageDeleted();
                             print('Images taken count after deletion: ${widget.imagesTaken}');
                             print('Delete image at ${widget.imagePath}');
                             Navigator.pop(context, widget.imagesTaken);
                           }
                       ),
                     ),
                     Flexible(
                       flex: 2,
                       fit: FlexFit.loose,
                       child: FlatButton.icon(
                           color: Colors.lightGreen,
                           icon: Icon(Icons.arrow_right),
                           label: const Text('Confirmar'),
                           onPressed: () {
                             Navigator.push(
                               context,
                               new MaterialPageRoute(
                                   builder: (context) => form(disk: widget.disk)),
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








































