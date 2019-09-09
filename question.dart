import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';



class Question extends StatefulWidget {
  Question({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _QuestionState createState() => _QuestionState();
}

class _QuestionState extends State<Question> {
  Future<File> _image;

  void _openCamara(){
    var photo = ImagePicker.pickImage(
      source: ImageSource.camera,
    );
    setState(() {
      _image = photo;
    });
  }

  void _openGalery(){
    var photo = ImagePicker.pickImage(
      source: ImageSource.gallery,
    );
    setState(() {
      _image = photo;
    });
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

  @override
  Widget build(BuildContext context) {
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
}