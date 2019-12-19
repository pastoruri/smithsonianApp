import 'dart:async';
import 'package:animal_recog/camera.dart' show Camera;
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'form.dart' show form;
import 'dart:io' show File;
import 'package:path/path.dart' show join;
import 'package:geolocator/geolocator.dart' show Geolocator, LocationAccuracy, Position;
import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;

class TakePictureScreen extends StatefulWidget {

  SharedPreferences disk;
  CameraDescription camera;
  static int imagesTaken = 0;
  static String imagePath;

  TakePictureScreen({Key key, this.camera, this.disk}) : super(key: key);

  @override
  TakePictureScreenState createState() {
    return TakePictureScreenState(disk: disk, cameraDescription: camera);
  }
}

class TakePictureScreenState extends State<TakePictureScreen> {

  CameraDescription cameraDescription;
  SharedPreferences disk;

  TakePictureScreenState({Key key, this.disk, this.cameraDescription});

  void imageTaken() {
    if (TakePictureScreen.imagesTaken != 5) {
      TakePictureScreen.imagesTaken += 1;
      TakePictureScreen.imagePath = "${Camera.documentsDirectoryPath}/${TakePictureScreen.imagesTaken}.png";
    }
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
      cameraDescription,
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
      body: FutureBuilder<void>( /// FutureBuilder es una clase muy importate
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
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat, // center the button
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.camera_alt),
          onPressed: () async {

            imageTaken();

            try {
              // Ensure that the camera is initialized.
              await _initializeControllerFuture;

              // Attempt to take a picture and log where it's been saved.
              await _controller.takePicture(TakePictureScreen.imagePath);

              // If the picture was taken, display it on a new screen.
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DisplayPictureScreen(disk: disk),
                ),
              );

              disk.setInt("imagesTaken", TakePictureScreen.imagesTaken);
              print('Saved image at ${TakePictureScreen.imagePath}');

              if (TakePictureScreen.imagesTaken == 1) { // get user coordinates only once
                getCoordinates();
              }

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
  DisplayPictureScreen({Key key, @required this.disk}) : super(key: key) {
    if (TakePictureScreen.imagesTaken != 5) {
      fivePhotosTaken = false;
    } else {
      fivePhotosTaken = true;
    }
  }

  SharedPreferences disk;
  bool fivePhotosTaken;

  @override
  DisplayPictureScreenState createState() => DisplayPictureScreenState();
}

class DisplayPictureScreenState extends State<DisplayPictureScreen> {

  Image imageTaken = Image.file(File(TakePictureScreen.imagePath));
  String imagePath = join(Camera.documentsDirectoryPath, '${TakePictureScreen.imagesTaken}.png');

   void imageDeleted() {
     setState(() {
       TakePictureScreen.imagesTaken -= 1;
       if (TakePictureScreen.imagesTaken != 0) {
         imagePath = join(Camera.documentsDirectoryPath, '${TakePictureScreen.imagesTaken}.png');
         imageTaken = Image.file(File(TakePictureScreen.imagePath));
       }
     });
   }

   @override
   Widget build(BuildContext context) {
     print("ABOUT TO DISPLAY AN IMAGE AT PATH: $imagePath");
     print("BY THE WAY, IMAGES TAKEN: ${TakePictureScreen.imagesTaken}");
     return Scaffold(
       appBar: AppBar(
           title: Text('¿Esta imagen está bien?'),
       ),
       body: Column(
         mainAxisSize: MainAxisSize.min,
         children: <Widget>[
           Expanded(
             flex: 28,
             child: imageTaken,
           ),
           Expanded(
             flex: 4,
             child: Column(
               children: <Widget>[
                 Flexible(
                   fit: FlexFit.loose,
                   flex: 2,
                   child: Text("Imágenes tomadas: ${TakePictureScreen.imagesTaken}"),
                 ),
                 Row(
                   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                   children: <Widget>[
                     if (!widget.fivePhotosTaken) Flexible(
                       flex: 1,
                       fit: FlexFit.loose,
                       child: RaisedButton(
                         color: Colors.lightGreen,
                         child: Text('Añadir Foto'),
                         onPressed: () {
                           Navigator.pop(context);
                         },
                       ),
                     ),
                     Flexible(
                       flex: 1,
                       fit: FlexFit.loose,
                       child: RaisedButton(
                         color: Colors.lightGreen,
                         child: Text('Borrar Foto'),
                         onPressed: () {
                           File imageToDelete = File(imagePath);
                           imageToDelete.deleteSync();
                           PaintingBinding.instance.imageCache.clear();
                           imageDeleted();
                           print("IMAGE JUST TAKEN DELETED!");
                           Navigator.pop(context);
                         },
                       ),
                     ),
                     Flexible(
                       flex: 1,
                       fit: FlexFit.loose,
                       child: RaisedButton(
                           color: Colors.lightGreen,
                           child: Text('Confirmar'),
                           onPressed: () {
                             Navigator.push(
                               context,
                               new MaterialPageRoute(
                                   builder: (context) => form(disk: widget.disk, imagesTaken: TakePictureScreen.imagesTaken)),
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








































