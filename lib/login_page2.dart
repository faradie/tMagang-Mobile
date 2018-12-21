import 'package:flutter/material.dart';

class LoginPage2 extends StatefulWidget {
  @override
  _LoginPage2State createState() => _LoginPage2State();
}

class _LoginPage2State extends State<LoginPage2> {
  var iconicon = [
    {
      "judul": "Informasi",
      "icon": Icons.info,
      "warna": Colors.green[200],
      "isi": "Ini isi dari inRformasi"
    },
    {
      "judul": "Peraturan",
      "icon": Icons.power_input,
      "warna": Colors.red[300],
      "isi": "Ini isi dari Peraturan"
    },
    {
      "judul": "Tata Cara",
      "icon": Icons.settings,
      "warna": Colors.yellow[300],
      "isi": "Ini isi dari Tata Cara"
    },
    {
      "judul": "Benefit",
      "icon": Icons.file_download,
      "warna": Colors.blue[200],
      "isi": "Ini isi dari Benefit"
    },
  ];

  List<Container> listMyWidgets() {
    List<Container> list = new List();
    for (var i = 0; i < iconicon.length; i++) {
      final data = iconicon[i];
      final String judulpakai = data["judul"];
      final Color warnapakai = data["warna"];
      final IconData iconpakai = data["icon"];
      final String isipakai = data["isi"];

      list.add(Container(
        child: Column(
          children: <Widget>[
            new Hero(
              tag: judulpakai,
              child: new Material(
                color: Colors.transparent,
                child: new InkWell(
                  onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) => new Detail(
                              judulDetail: judulpakai,
                              iconDetail: iconpakai,
                              warnaDetail: warnapakai,
                              isiDetail: isipakai,
                            ),
                      )),
                  child: Container(
                      padding: const EdgeInsets.all(7.0),
                      decoration: new BoxDecoration(
                        shape: BoxShape
                            .circle, // You can use like this way or like the below line
                        //borderRadius: new BorderRadius.circular(30.0),
                        color: warnapakai,
                      ),
                      child: Icon(
                        iconpakai,
                        color: Colors.brown[900],
                      )),
                ),
              ),
            ),
            Text(judulpakai)
          ],
        ),
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        new Column(
          children: <Widget>[
            new Container(
              height: MediaQuery.of(context).size.height * .55,
              color: Colors.blue,
            ),
            new Container(
              height: MediaQuery.of(context).size.height * .45,
              color: Colors.white,
            )
          ],
        ),
        new Container(
          alignment: Alignment.topCenter,
          padding: new EdgeInsets.only(
              top: MediaQuery.of(context).size.height * .30,
              right: 20.0,
              left: 20.0),
          child: new Container(
            height: 400.0,
            width: MediaQuery.of(context).size.width,
            child: new Card(
              color: Colors.white,
              elevation: 4.0,
            ),
          ),
        ),
      ],
    );
  }
}

class Detail extends StatelessWidget {
  Detail({this.judulDetail, this.iconDetail, this.isiDetail, this.warnaDetail});

  final String judulDetail, isiDetail;
  final IconData iconDetail;
  final Color warnaDetail;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new ListView(
        children: <Widget>[
          new Container(
            color: warnaDetail,
            height: 80.0,
            child: new Hero(
              tag: judulDetail,
              child: new Material(
                child: new InkWell(
                  child: new Container(
                    color: warnaDetail,
                    child: new Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Icon(iconDetail),
                          new Text(
                            judulDetail.toUpperCase(),
                            style: TextStyle(
                                color: Colors.brown[900], fontSize: 20.0),
                          ),
                          new Icon(iconDetail),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
