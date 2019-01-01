import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class RiwayatMagang extends StatefulWidget {
  RiwayatMagang({this.id});
  final String id;
  _RiwayatMagangState createState() => _RiwayatMagangState();
}

class _RiwayatMagangState extends State<RiwayatMagang> {
  DateTime dateNow = DateTime.now();
  IconData _icon;
  MaterialColor _colors;
  final loadingLoad = CircularProgressIndicator(
    backgroundColor: Colors.deepOrange,
    strokeWidth: 1.5,
  );
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        backgroundColor: const Color(0xFFe87c55),
        title: new Text("Riwayat Magang"),
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
      body: new Container(
        child: StreamBuilder(
          stream: Firestore.instance
              .collection("internship")
              .where('ownerAgency', isEqualTo: widget.id)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[loadingLoad, Text("Loading Data..")],
                ),
              );
            } else if (!snapshot.hasData) {
              return Center(
                  child: new Text("Yah.. Belum ada riwayat magang.."));
            } else if (snapshot.hasError) {
              return Center(child: new Text("Yah.. ada yang salah nih.."));
            } else {
              if (snapshot.data.documents.length > 0) {
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (_, index) {
                    DocumentSnapshot ds = snapshot.data.documents[index];
                    Timestamp _validUntil = ds["timeEndIntern"];
                    DateTime _until = _validUntil.toDate();
                    print("ini valid until : 3");
                    final difference = dateNow.difference(_until).inDays;
                    if (difference >= 0) {
                      _icon = Icons.warning;
                      _colors = Colors.red;
                    } else {
                      _icon = Icons.check;
                      _colors = Colors.blue;
                    }
                    return TileLowongan(
                      idLowongan: ds["vacanciesId"],
                      no: (index + 1).toString(),
                      iconData: _icon,
                      warna: _colors,
                    );
                  },
                );
              } else {
                return Center(
                  child: new Text(
                    "Belum ada riwayat magang..",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.grey),
                  ),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

class TileLowongan extends StatefulWidget {
  TileLowongan({this.idLowongan, this.no, this.iconData, this.warna});
  final String idLowongan, no;
  final IconData iconData;
  final MaterialColor warna;

  @override
  TileLowonganState createState() {
    return new TileLowonganState();
  }
}

class TileLowonganState extends State<TileLowongan> {
  String _judulLowongan;
  int totPemagang = 0;
  Future getLowongan() async {
    var firestore = Firestore.instance;
    var userQuery = firestore
        .collection('vacancies')
        .where('id', isEqualTo: widget.idLowongan)
        .limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          _judulLowongan = data.documents[0].data['title'];
        });
      }
    });

    var queryTotal = firestore
        .collection('internship')
        .where('vacanciesId', isEqualTo: widget.idLowongan)
        .limit(1);
    queryTotal.getDocuments().then((data) {
      if (data.documents.length > 0) {
        totPemagang = data.documents.length;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getLowongan();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Column(
      children: <Widget>[
        new ListTile(
          onTap: () {},
          leading: new Text(
            widget.no,
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
          title: new Text(
            _judulLowongan == null ? "" : _judulLowongan,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: new Text("Total pemagang : $totPemagang"),
          trailing: new Icon(widget.iconData, color: widget.warna),
        ),
        new Divider(),
      ],
    ));
  }
}
