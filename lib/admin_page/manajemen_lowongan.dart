import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class InternManage extends StatefulWidget {
  _InternManageState createState() => _InternManageState();
}

class _InternManageState extends State<InternManage> {
  DateTime dateNow = DateTime.now();
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          elevation:
              defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
          backgroundColor: const Color(0xFFe87c55),
          title: new Text("Data Lowongan"),
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
              child: StreamBuilder(
                stream: Firestore.instance.collection('vacancies').snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return new Text(
                      "0",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0),
                    );
                  return new Text(
                    snapshot.data.documents.length.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0),
                  );
                },
              ),
              onPressed: null,
            )
          ],
        ),
        body: Container(
          margin: const EdgeInsets.only(top: 10.0, left: 10.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              StreamBuilder(
                stream: Firestore.instance
                    .collection('vacancies')
                    .where("validUntil", isGreaterThanOrEqualTo: dateNow)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return new Text(
                      "Lowongan Aktif : 0",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15.0),
                    );
                  return new Text(
                    "Lowongan Aktif : ${snapshot.data.documents.length.toString()}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 15.0),
                  );
                },
              ),
              StreamBuilder(
                stream: Firestore.instance
                    .collection('vacancies')
                    .where("validUntil", isLessThan: dateNow)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return new Text(
                      "Lowongan NonAktif : 0",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15.0),
                    );
                  return new Text(
                    "Lowongan NonAktif : ${snapshot.data.documents.length.toString()}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 15.0),
                  );
                },
              ),
              new Expanded(
                child: ListLowongan(),
              ),
            ],
          ),
        ));
  }
}

class ListLowongan extends StatefulWidget {
  @override
  ListLowonganState createState() {
    return new ListLowonganState();
  }
}

class ListLowonganState extends State<ListLowongan> {
  DateTime dateNow = DateTime.now();
  IconData _icon;
  MaterialColor _colors;
  Future getLowongan() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore
        .collection('vacancies')
        .orderBy("validUntil", descending: true)
        .getDocuments();

    return qn.documents;
  }

  final loadingLoad = CircularProgressIndicator(
    backgroundColor: Colors.deepOrange,
    strokeWidth: 1.5,
  );

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: getLowongan(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[loadingLoad, Text("Loading Data..")],
              ),
            );
          } else {
            if (snapshot.data.length == 0) {
              return new Center(
                child: new Text("Belum ada lowongan"),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, index) {
                  DateTime _validUntil =
                      snapshot.data[index].data["validUntil"];
                  final difference = dateNow.difference(_validUntil).inDays;
                  if (difference >= 0) {
                    _icon = Icons.warning;
                    _colors = Colors.red;
                  } else {
                    _icon = Icons.check;
                    _colors = Colors.blue;
                  }
                  return new TileLowongan(
                    judul: snapshot.data[index].data["title"],
                    penyelenggara: snapshot.data[index].data["ownerAgency"],
                    iconData: _icon,
                    warna: _colors,
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}

class TileLowongan extends StatefulWidget {
  TileLowongan({this.judul, this.penyelenggara, this.iconData, this.warna});
  final String judul, penyelenggara;
  final IconData iconData;
  final MaterialColor warna;

  @override
  TileLowonganState createState() {
    return new TileLowonganState();
  }
}

class TileLowonganState extends State<TileLowongan> {
  var name;
  String _namaUser;
  Future getDataUser() async {
    var firestore = Firestore.instance;
    var userQuery = firestore
        .collection('users')
        .where('uid', isEqualTo: widget.penyelenggara)
        .limit(1);

    userQuery.getDocuments().then((data2) {
      if (data2.documents.length > 0) {
        setState(() {
          name = data2.documents[0].data['data'] as Map<dynamic, dynamic>;
          _namaUser = name["displayName"];
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
    return new Container(
      child: new ListTile(
        leading: new Icon(widget.iconData, color: widget.warna),
        title: new Text(
          widget.judul == null ? "" : widget.judul,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle:
            new Text("Dibuat oleh : ${_namaUser == null ? "" : _namaUser}"),
      ),
    );
  }
}
