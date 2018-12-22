import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class Profil extends StatefulWidget {
  @override
  ProfilState createState() {
    return new ProfilState();
  }
}

class ProfilState extends State<Profil> {
  var name;
  String _namaUser, _statusUser, _jurusan, _jenisKel, _kontak, _alamat;
  List<String> _requirementNya;
  bool _isActive;
  Future getDataUser() async {
    var user = await FirebaseAuth.instance.currentUser();
    var firestore = Firestore.instance;
    var userQuery = firestore
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          name = data.documents[0].data['data'] as Map<dynamic, dynamic>;
          _namaUser = name["displayName"];
          _statusUser = data.documents[0].data['role'];
          _jurusan = name["jurusan"];
          _isActive = name["isActive"];
          _jenisKel = name["gender"];
          _kontak = name["contact"];
          _alamat = name["address"];
          _requirementNya = List.from(name["skills"]);
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getDataUser();
  }

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
          actions: <Widget>[
            new FlatButton(
              child: new Icon(Icons.settings, color: Colors.white),
              onPressed: () {},
            )
          ],
        ),
        body: new Container(
          child: new ListView(
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
                            _namaUser == null
                                ? "Mengambil data"
                                : _namaUser.toUpperCase(),
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
                            "Nama Instansi Terkait".toString(),
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
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Column(
                    children: <Widget>[
                      new Text(
                        "Status",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      new Text(_isActive == null
                          ? "Mengambil data"
                          : _isActive == false ? "Tidak Magang" : "Magang"),
                    ],
                  ),
                  new Column(
                    children: <Widget>[
                      new Text(
                        "Jurusan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      new Text(_jurusan == null ? "Mengambil data" : _jurusan),
                    ],
                  ),
                ],
              ),
              new Divider(
                color: Colors.grey,
              ),
              new Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            "Jenis kelamin",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          new Text(
                              _jenisKel == null ? "Mengambil data" : _jenisKel)
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            "Kontak",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          new Text(_kontak == null ? "Mengambil data" : _kontak)
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            "Alamat",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          new Text(_alamat == null ? "Mengambil data" : _alamat)
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            "Skills",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                                height: 25.0,
                                color: Colors.transparent,
                                child: Requir(
                                  req: _requirementNya == null
                                      ? ["Mengambil data"]
                                      : _requirementNya,
                                )),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                    )
                  ],
                ),
              ),
              new Container(
                margin: const EdgeInsets.all(5.0),
                child: new Text(
                  "Riwayat Magang",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              new Container(
                margin: const EdgeInsets.all(5.0),
                child: Card(
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    child: new Text(
                      "Data Riwayat Magang",
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

class Requir extends StatelessWidget {
  Requir({this.req});
  final List<String> req;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: req.length,
      itemBuilder: (_, index) {
        return Container(
          padding: const EdgeInsets.only(right: 5.0),
          child: KompetensiUser(
            judulKompetensi: req[index].toString(),
          ),
        );
      },
    );
  }
}

class KompetensiUser extends StatelessWidget {
  KompetensiUser({this.judulKompetensi});
  final String judulKompetensi;
  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        decoration: new BoxDecoration(
            color: Colors.transparent,
            border: new Border.all(color: const Color(0xFFe87c55), width: 1.0),
            borderRadius: new BorderRadius.all(Radius.circular(20.0))),
        child: new Center(
          child: new Text(
            judulKompetensi,
            style: TextStyle(
                fontSize: 15.0,
                color: const Color(0xFFe87c55),
                fontWeight: FontWeight.bold),
          ),
        ));
  }
}
