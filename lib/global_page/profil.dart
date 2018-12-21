import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Profil extends StatefulWidget {
  Profil({this.idNya});
  String idNya;

  @override
  ProfilState createState() {
    return new ProfilState();
  }
}

class ProfilState extends State<Profil> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          elevation:
              defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
          backgroundColor: const Color(0xFFe87c55),
          title: new Text("Profil"),
          leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: new Icon(
              Icons.chevron_left,
              color: Colors.white,
            ),
          ),
        ),
        body: Container(
          child: new Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Expanded(
                    child: new Column(
                      children: <Widget>[
                        new CircleAvatar(
                          radius: 40.0,
                          backgroundColor: Colors.amber,
                          child: new Text("A"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                        ),
                        new Container(
                          padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                          child: new Text(
                            "Muhammad Alfin Nurul Firdaus".toUpperCase(),
                            style: new TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[850]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        new Container(
                          padding:
                              const EdgeInsets.only(bottom: 8.0, left: 8.0),
                          child: new Text(
                            "Sekolah Tinggi Teknik PLN".toString(),
                            style: new TextStyle(
                                color: Colors.grey, fontSize: 13.0),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Text("data"),
            ],
          ),
        ));
  }
}
