import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tempat_magang/auth.dart';
import 'package:uuid/uuid.dart';
import 'dashboard.dart' as dashboard;

class DetailLowongan extends StatefulWidget {
  DetailLowongan(
      {this.judulNya,
      this.kuota,
      this.tglUpload,
      this.instansi,
      this.tglAkhir,
      this.tglAwal,
      this.deskripsiNya,
      this.requirementNya,
      this.idNya});
  final String judulNya,
      deskripsiNya,
      idNya,
      tglUpload,
      tglAwal,
      tglAkhir,
      instansi;

  final int kuota;

  final List<String> requirementNya;
  _DetailLowonganState createState() => _DetailLowonganState();
}

class _DetailLowonganState extends State<DetailLowongan> {
  List<String> _skills;
  bool _terDaftar = false;
  var name;
  String _idUser;
  bool tekan = false;

  void _showToast(String pesan, Color warna) {
    Fluttertoast.showToast(
      msg: pesan,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: warna,
      textColor: Colors.white,
    );
  }

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
          _skills = List.from(name["skills"]);
          _idUser = data.documents[0].data['uid'];
        });
      }
    });

    var userQuery2 = firestore
        .collection('registerIntern')
        .document('${user.uid}_${widget.idNya}');
    userQuery2.get().then((data) {
      if (data.exists) {
        setState(() {
          _terDaftar = true;
        });
      } else {
        tekan = true;
      }
    });
  }

  void _inPressed() {
    setState(() {
      tekan = false;
    });
    if (_idUser == null) {
      _showToast("Harap bersabar", Colors.red);
    } else {
      String _idRegister = "${_idUser}_${widget.idNya}";
      var today = new DateTime.now();

      Map<String, dynamic> data = <String, dynamic>{
        "userId": _idUser,
        "vacanciesId": widget.idNya,
        "registerAt": today,
        "requirement": widget.requirementNya,
        "skills": _skills,
        "ownerAgency": widget.instansi
      };

      Firestore.instance
          .collection("registerIntern")
          .document("$_idRegister")
          .setData(data)
          .whenComplete(() {
        _showToast("Berhasil Mengajukan", Color(0xFFe87c55));

        Navigator.of(context).pop();
      }).catchError((e) {
        print(e);
      });
    }
  }

  final loadingLoad = CircularProgressIndicator(
    backgroundColor: Colors.white,
    strokeWidth: 1.5,
  );

  @override
  void initState() {
    super.initState();
    getDataUser();
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return new Scaffold(
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: new Icon(
            Icons.chevron_left,
            color: Colors.white,
          ),
        ),
        title: new Text("Detail"),
        backgroundColor: const Color(0xFFe87c55),
        actions: <Widget>[
          new FlatButton(
            child: new Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: new ListView(
        children: <Widget>[
          new Card(
            color: Colors.white,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  child: new Center(
                    child: new Text("Foto"),
                  ),
                  height: 110.0,
                  width: 110.0,
                  // color: Colors.red,
                  decoration: new BoxDecoration(
                      color: Color(0xFFe87c55),
                      borderRadius: new BorderRadius.only(
                          bottomLeft: Radius.circular(5.0),
                          topLeft: Radius.circular(5.0))),
                ),
                Expanded(
                  child: new Container(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text("${widget.judulNya}",
                              style: new TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800])),
                          new Text("Kuota ${widget.kuota}"),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                child: ButtonTheme(
                                  minWidth: 200.0,
                                  height: 40.0,
                                  child: new RaisedButton(
                                      color: const Color(0xFFff9977),
                                      elevation: 4.0,
                                      splashColor: Colors.blueGrey,
                                      onPressed: _idUser == null
                                          ? null
                                          : _terDaftar == true
                                              ? null
                                              : tekan == false
                                                  ? null
                                                  : _inPressed,
                                      child: _idUser == null
                                          ? loadingLoad
                                          : new Text(
                                              _terDaftar == false
                                                  ? 'Ajukan'.toUpperCase()
                                                  : 'Proses Review'
                                                      .toUpperCase(),
                                              style: TextStyle(
                                                  fontSize: 15.0,
                                                  color: Colors.white),
                                            )),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.0),
          Container(
            decoration: new BoxDecoration(
                border:
                    new Border.all(color: const Color(0xFFe87c55), width: 1.0),
                borderRadius: new BorderRadius.all(Radius.circular(20.0))),
            margin: const EdgeInsets.only(left: 5.0, right: 5.0),
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new Text(
                      "Periode".toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                        child: Column(
                      children: <Widget>[
                        new Text("Mulai",
                            style: new TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800])),
                        new Text("${widget.tglAwal}"),
                      ],
                    )),
                    new Divider(),
                    Container(
                        child: Column(
                      children: <Widget>[
                        new Text("Akhir",
                            style: new TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800])),
                        new Text("${widget.tglAkhir}"),
                      ],
                    ))
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 5.0),
          new Card(
            child: new Container(
              margin: const EdgeInsets.all(10.0),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          "Diupload pada ${widget.tglUpload}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        new Text(
                          widget.deskripsiNya,
                          textAlign: TextAlign.justify,
                        ),
                        new Padding(
                          padding: const EdgeInsets.all(8.0),
                        ),
                        new Text(
                          "Requirement :",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                              height: 25.0,
                              color: Colors.transparent,
                              child: Requir(
                                req: widget.requirementNya,
                              )),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
          new Container(
            margin: const EdgeInsets.all(5.0),
            child: new Text(
              "Pertanyaan terkait",
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
            ),
          ),
          new Container(
            margin: const EdgeInsets.all(5.0),
            child: Card(
              child: Container(
                margin: const EdgeInsets.all(10.0),
                child: new Text(
                  "Coming Soon...",
                ),
              ),
            ),
          )
        ],
      ),
    );
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
