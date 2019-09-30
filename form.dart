import 'package:flutter/material.dart';

class form extends StatefulWidget {
  @override
  _formState createState() {
    return _formState();
  }
}

class _formState extends State<form> {
  var _species = ['Desconocido', 'Pez', 'Mamífero'];
  var _actualspecie = 'Desconocido';
  bool _isDead = false;
  var _explanation = '';
  var _comments = '';

  void changeSpecie(String value){
    setState(() {
      this._actualspecie = value;
    });
  }

  void changeIsDead(bool value){
    setState(() {
      this._isDead = value;
    });
  }

  void change_explanation(String value){
    setState(() {
      this._explanation = value;
    });
  }

  void change_comments(String value){
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
                  padding: EdgeInsets.all(16.0),
                  child: Row(
                    children: <Widget>[
                      Text("¿Está vivo? : ", style: TextStyle(fontSize: 20.0),),
                      Padding(
                        padding: EdgeInsets.all(10.0),
                      ),
                      Checkbox(
                          value: _isDead,
                          onChanged: (bool newboolvalue){
                            changeIsDead(newboolvalue);
                          }
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: <Widget>[
                      Text("Causa de muerte : ", style: TextStyle(fontSize: 20.0), textAlign: TextAlign.left,),
                      TextField(
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