import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

DateTime dateNow = DateTime.now();

final loadingLoad = CircularProgressIndicator(
  backgroundColor: Colors.deepOrange,
  strokeWidth: 1.5,
);

class ManajemenMentor extends StatefulWidget {
  ManajemenMentor({this.id});
  final String id;
  _ManajemenMentorState createState() => _ManajemenMentorState();
}

class _ManajemenMentorState extends State<ManajemenMentor> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 50.0,
        color: Colors.white,
      ),
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        backgroundColor: const Color(0xFFe87c55),
        title: new Text("Mentor"),
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
              .collection("users")
              .where('data.agencyId', isEqualTo: widget.id)
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
              return Center(child: new Text("Yah.. Belum ada mentor.."));
            } else if (snapshot.hasError) {
              return Center(child: new Text("Yah.. ada yang salah nih.."));
            } else {
              if (snapshot.data.documents.length > 0) {
                return ListView.builder(
                  itemCount: snapshot.data.documents.length,
                  itemBuilder: (_, index) {
                    DocumentSnapshot ds = snapshot.data.documents[index];

                    return TileMentor(
                      idMentor: ds["uid"],
                      no: (index + 1).toString(),
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

class TileMentor extends StatefulWidget {
  TileMentor({this.idMentor, this.no});
  final String idMentor, no;

  @override
  TileMentorState createState() {
    return new TileMentorState();
  }
}

class TileMentorState extends State<TileMentor> {
  String _namaMentor;
  var dataNya;
  int totPemagang = 0;
  Future _getMentor() async {
    var firestore = Firestore.instance;
    var userQuery = firestore
        .collection('users')
        .where('uid', isEqualTo: widget.idMentor)
        .limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          dataNya = data.documents[0].data['data'];
          _namaMentor = dataNya["displayName"];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getMentor();
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
            _namaMentor == null ? "" : _namaMentor,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          // subtitle: new Text("Total pemagang : $totPemagang"),
          // trailing: new Icon(widget.iconData, color: widget.warna),
        ),
        new Divider(),
      ],
    ));
  }
}
