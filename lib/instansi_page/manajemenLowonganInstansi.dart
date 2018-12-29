import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ManajemenLowonganInstansi extends StatefulWidget {
  ManajemenLowonganInstansi({this.idAgency});
  final String idAgency;
  _ManajemenLowonganInstansiState createState() =>
      _ManajemenLowonganInstansiState();
}

class _ManajemenLowonganInstansiState extends State<ManajemenLowonganInstansi> {
  DateTime dateNow = DateTime.now();
  @override
  void initState() {
    super.initState();
  }

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
                stream: Firestore.instance
                    .collection('vacancies')
                    .where('ownerAgency', isEqualTo: widget.idAgency)
                    .snapshots(),
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
                    .where("expiredAt", isGreaterThanOrEqualTo: dateNow)
                    .where('ownerAgency', isEqualTo: widget.idAgency)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return new Text(
                      "Lowongan Aktif Anda: 0",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15.0),
                    );
                  return new Text(
                    "Lowongan Aktif Anda: ${snapshot.data.documents.length.toString()}",
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
                    .where("expiredAt", isLessThan: dateNow)
                    .where('ownerAgency', isEqualTo: widget.idAgency)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return new Text(
                      "Lowongan NonAktif Anda: 0",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15.0),
                    );
                  return new Text(
                    "Lowongan NonAktif Anda: ${snapshot.data.documents.length.toString()}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 15.0),
                  );
                },
              ),
              new Expanded(
                child: ListLowongan(
                  id: widget.idAgency,
                ),
              ),
            ],
          ),
        ));
  }
}

class ListLowongan extends StatefulWidget {
  ListLowongan({this.id});
  final String id;
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
        .where('ownerAgency', isEqualTo: widget.id)
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
                  DateTime _validUntil = snapshot.data[index].data["expiredAt"];
                  final difference = dateNow.difference(_validUntil).inDays;
                  if (difference >= 0) {
                    _icon = Icons.warning;
                    _colors = Colors.red;
                  } else {
                    _icon = Icons.check;
                    _colors = Colors.blue;
                  }
                  return new TileLowongan(
                    no: (index + 1).toString(),
                    judul: snapshot.data[index].data["title"],
                    created: snapshot.data[index].data["createdAt"],
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
  TileLowongan({this.judul, this.created, this.iconData, this.no, this.warna});
  final String judul, no;
  final DateTime created;
  final IconData iconData;
  final MaterialColor warna;

  @override
  TileLowonganState createState() {
    return new TileLowonganState();
  }
}

class TileLowonganState extends State<TileLowongan> {
  var name;
  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Column(
      children: <Widget>[
        new Divider(),
        new ListTile(
          leading: new Text(
            widget.no,
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
          title: new Text(
            widget.judul == null ? "" : widget.judul,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: new Text(
              "Dibuat pada : ${widget.created == null ? "" : widget.created}"),
          trailing: new Icon(widget.iconData, color: widget.warna),
        ),
      ],
    ));
  }
}
