import 'package:shared_preferences/shared_preferences.dart' show SharedPreferences;
import 'form.dart' show form;
import 'package:flutter/material.dart';

class sform extends StatefulWidget {

  static SharedPreferences disk;
  final String title;
  final List lista;

  sform({Key key,
    this.title,
    this.lista,
  }) : super(key: key);

  @override
  _sformState createState() => _sformState();
}

class _sformState extends State<sform> {

  _sformState();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        leading: IconButton(icon:Icon(Icons.arrow_back),
          onPressed:() => Navigator.pop(context, false),
        ),
      ),
      body: ListView.builder(
          shrinkWrap: true,
          padding: EdgeInsets.all(20.0),
          itemCount: widget.lista/*choices*/ == null ? 0 : widget.lista/*choices*/.length,
          itemBuilder: (BuildContext context, int index){
            return ChoiceCard(choice: widget.lista/*choices*/[index], item: widget.lista/*choices*/[index], disk: sform.disk);
          }
        ),
      );
  }
}

class Specie {
  const Specie({this.icon, this.title});

  final Image icon;
  final String title;
}

const List<Specie> choices = const <Specie>[
  const Specie(icon: Image(image: AssetImage('assets/libary_animals/LoboMarinoChusco_Otaria_flavescens.jpg')), title: "Mamífero Marino"),
  const Specie(icon: Image(image: AssetImage('assets/libary_animals/Guanay_Leucocarbo_bougainvillii.jpg')), title: "Ave"),
  const Specie(icon: Image(image: AssetImage('assets/libary_animals/TortugaLaud_Dermochelys_coriacea.jpg')), title: "Reptil"),
  const Specie(icon: Image(image: AssetImage('assets/libary_animals/CangrejoCarretero_Ocypode gaudichaudii.jpg')), title: "Invertebrado"),
];

const List<Specie> Aves = const <Specie>[
  const Specie(icon: Image(image: AssetImage('assets/libary_animals/PelicanoPeruano_Pelecanus_thagus.jpg')), title: "Pelicano Peruano"),
  const Specie(icon: Image(image: AssetImage('assets/libary_animals/Guanay_Leucocarbo_bougainvillii.jpg')), title: "Guanay"),
  const Specie(icon: Image(image: AssetImage('assets/libary_animals/PinguinodeHumboldt_Spheniscus_humboldti.jpg')), title: "Pingüino de Humboldt"),
  const Specie(icon: Image(image: AssetImage('assets/libary_animals/Piquero_Sula_variegata.jpg')), title: "Piquiero"),
];

const List<Specie> MM = const <Specie>[
  const Specie(icon: Image(image: AssetImage('assets/libary_animals/LoboMarinoChusco_Otaria_flavescens.jpg')), title: "Lobo Marino Chusco"),
  const Specie(icon: Image(image: AssetImage('assets/libary_animals/DelfinOscuro_Lagenorhynchus obscurus.jpg')), title: "Delfin Oscuro"),
  const Specie(icon: Image(image: AssetImage('assets/libary_animals/DelfinPicodeBotella_Tursiops_truncatus.jpg')), title: "Delfin Pico de Botella"),
  const Specie(icon: Image(image: AssetImage('assets/libary_animals/MarsopadeBurmeister_Phocoena_spinipinnis.jpg')), title: "Marsopa de Burmeister"),
];

const List<Specie> Reptiles = const <Specie>[
  const Specie(icon: Image(image: AssetImage('assets/libary_animals/TortugaNegra_Chelonia_mydas.jpg')), title: "Tortuga Negra"),
  const Specie(icon: Image(image: AssetImage('assets/libary_animals/TortugaLaud_Dermochelys_coriacea.jpg')), title: "Tortuga Laud"),
];

const List<Specie> Invert = const <Specie>[
  const Specie(icon: Image(image: AssetImage('assets/libary_animals/MuyMuy_Emerita_analoga.jpg')), title: "Muy Muy"),
  const Specie(icon: Image(image: AssetImage('assets/libary_animals/CangrejoCarretero_Ocypode gaudichaudii.jpg')), title: "Cangrejo Carretero"),
];

class ChoiceCard extends StatelessWidget {

  final SharedPreferences disk;
  final Specie choice;
  final VoidCallback onTap;
  final Specie item;

  ChoiceCard({Key key,
    this.choice,
    this.onTap,
    @required this.item,
    @required this.disk
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: () {
          switch (choice.title){
            case 'Mamífero Marino':
              Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (_context) => sform(title: choice.title, lista: MM,))
              );
              break;
            case 'Ave':
              Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (_context) => sform(title: choice.title, lista: Aves,))
              );
              break;
            case 'Reptil':
              Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (_context) => sform(title: choice.title, lista: Reptiles,))
              );
              break;
            case 'Invertebrado':
              Navigator.push(
                  context,
                  new MaterialPageRoute(builder: (_context) => sform(title: choice.title, lista: Invert,))
              );
              break;
            default:
              disk.setString("specie", choice.title);
              form.specie = choice.title;
              Navigator.pop(context);
              Navigator.pop(context);
          }
        },
        child: Card(
          color: Colors.white,
          elevation: 6.0,
          child: Row(
          //mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              height: 100.0,
              padding: EdgeInsets.all(8.0),
              alignment: Alignment.topCenter,
              child: choice.icon,
            ),
            Expanded(
              child: new Container(
                padding: EdgeInsets.all(10.0),
                alignment: Alignment.centerLeft,
                color: Colors.lightGreen,
                child: Text(choice.title, style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2
                ),
              ),
            ),
          ],
          crossAxisAlignment: CrossAxisAlignment.start,
        ),
      ),
    );
  }


}

