import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class LamaranPemagang extends StatefulWidget {
  @override
  LamaranPemagangState createState() {
    return new LamaranPemagangState();
  }
}

class LamaranPemagangState extends State<LamaranPemagang> {
  String _userId;

  Future getDataUser() async {
    var user = await FirebaseAuth.instance.currentUser();
    setState(() {
      _userId = user.uid;
    });
  }

  Future getLamaran() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore
        .collection('registerIntern')
        .where('userId', isEqualTo: _userId)
        .getDocuments();

    return qn.documents;
  }

  final loadingLoad = CircularProgressIndicator(
    backgroundColor: Colors.deepOrange,
    strokeWidth: 1.5,
  );

  @override
  void initState() {
    super.initState();
    getDataUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          elevation:
              defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
          backgroundColor: const Color(0xFFe87c55),
          title: new Text("Pengajuan Anda"),
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
          margin: const EdgeInsets.only(top: 10.0),
          child: FutureBuilder(
            future: getLamaran(),
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
                    child: new Text("Anda belum mengajukan magang"),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (_, index) {
                      return new TileLowongan(
                        registeAt: snapshot.data[index].data["registerAt"],
                        vacanciesId: snapshot.data[index].data["vacanciesId"],
                        status: snapshot.data[index].data["status"],
                      );
                    },
                  );
                }
              }
            },
          ),
        ));
  }
}

class TileLowongan extends StatefulWidget {
  TileLowongan({this.vacanciesId, this.registeAt, this.status});
  final String vacanciesId;
  final bool status;
  final Timestamp registeAt;

  @override
  TileLowonganState createState() {
    return new TileLowonganState();
  }
}

class TileLowonganState extends State<TileLowongan> {
  var name;
  String _nameLamaran;
  String regAt;
  bool _isAccepted;

  // Future getDataUser() async {
  //   var firestore = Firestore.instance;
  //   var userQuery = firestore
  //       .collection('users')
  //       .where('uid', isEqualTo: widget.penyelenggara)
  //       .limit(1);

  //   userQuery.getDocuments().then((data2) {
  //     if (data2.documents.length > 0) {
  //       setState(() {
  //         name = data2.documents[0].data['data'] as Map<dynamic, dynamic>;
  //         _namaUser = name["displayName"];
  //       });
  //     }
  //   });
  // }

  Future getDataUser() async {
    var user = await FirebaseAuth.instance.currentUser();
    var firestore = Firestore.instance;
    var userQuery2 =
        firestore.collection('vacancies').document(widget.vacanciesId);
    userQuery2.get().then((doc) {
      if (doc.exists) {
        setState(() {
          _nameLamaran = doc.data["title"];
          regAt = formatDate(widget.registeAt.toDate(),
              [dd, ' ', MM, ' ', yyyy, ' ', HH, ':', nn]);
        });
      }
    });

    String _idInternship = "${widget.vacanciesId}_${user.uid}";
    var cekVacanciesStatus =
        firestore.collection('internship').document('$_idInternship');
    cekVacanciesStatus.get().then((dat) {
      if (dat.exists) {
        _isAccepted = true;
      } else {
        _isAccepted = false;
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
        trailing: new ButtonTheme(
          height: 40.0,
          child: new RaisedButton(
            onPressed: null,
            color: const Color(0xFFff9977),
            elevation: 4.0,
            splashColor: Colors.blueGrey,
            child: new Text(
              widget.status == true
                  //kalo false cek dulu apakah ada id lowongan_iduser itu ada di internship, kalo gaada ditolak kalo ada diterima
                  ? "Review"
                  : _isAccepted == true ? "Diterima" : "Ditolak",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
        title: new Text(
          _nameLamaran == null ? "Mengambil data" : _nameLamaran,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: new Text(
            "Diajukan pada : ${regAt == null ? "Mengambil data" : regAt}"),
      ),
    );
  }
}
