import 'package:cloud_firestore/cloud_firestore.dart';
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
  TileLowongan({this.vacanciesId, this.registeAt});
  final String vacanciesId;
  final DateTime registeAt;

  @override
  TileLowonganState createState() {
    return new TileLowonganState();
  }
}

class TileLowonganState extends State<TileLowongan> {
  var name;
  String _namaUser;
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

  @override
  void initState() {
    super.initState();
    // getDataUser();
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new ListTile(
        leading: new Icon(Icons.check, color: Colors.blue),
        title: new Text(
          widget.vacanciesId == null ? "" : widget.vacanciesId,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: new Text(
            "Diajukan pada : ${widget.registeAt == null ? "" : widget.registeAt}"),
      ),
    );
  }
}