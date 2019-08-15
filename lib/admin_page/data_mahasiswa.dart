import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MahasiswaData extends StatefulWidget {
  @override
  _MahasiswaDataState createState() => _MahasiswaDataState();
}

class _MahasiswaDataState extends State<MahasiswaData> {
  var firestore = Firestore.instance;

  Future getMhsCollege(String id) async {
    var _collegeName;
    var firestore = Firestore.instance;
    var userQuery =
        firestore.collection('users').where('uid', isEqualTo: id).limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          var tmp = data.documents[0].data['data'] as Map<dynamic, dynamic>;
          _collegeName = tmp["displayName"];
        });
        return _collegeName;
      }
    });
  }

  Future _getMhs() async {
    QuerySnapshot qn = await firestore
        .collection('users')
        .where('role', isEqualTo: 'intern')
        .getDocuments();
    return qn.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        backgroundColor: const Color(0xFFe87c55),
        title: new Text("Data Mahasiswa"),
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
            child: new Icon(Icons.add, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: new Container(
        margin: const EdgeInsets.all(10.0),
        child: new FutureBuilder(
          future: _getMhs(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[Text("Loading Data..")],
                ),
              );
            } else if (!snapshot.hasData) {
              return Center(
                  child: new Text("Yah.. Belum ada data mahasiswa.."));
            } else if (snapshot.hasError) {
              return Center(child: new Text("Yah.. ada yang salah nih.."));
            } else {
              if (snapshot.data.length == 0) {
                return new Center(
                  child: new Text("Belum ada data mahasiswa..."),
                );
              } else {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (_, index) {
                      var map = snapshot.data[index].data["data"]
                          as Map<dynamic, dynamic>;
                      return new TileMahasiswa(
                        collegeId: map['collegeId'],
                        name: map['displayName'],
                        uid: snapshot.data[index].data["uid"],
                        no: (index + 1).toString(),
                      );
                    });
              }
            }
          },
        ),
      ),
    );
  }
}

class TileMahasiswa extends StatefulWidget {
  TileMahasiswa({this.no, this.uid, this.collegeId, this.name});
  final String name, uid, collegeId, no;
  @override
  _TileMahasiswaState createState() => _TileMahasiswaState();
}

class _TileMahasiswaState extends State<TileMahasiswa> {
  String _collegeName;
  Future _getCollegeAsal() async {
    var firestore = Firestore.instance;
    var userQuery2 = firestore.collection('users').document(widget.collegeId);
    userQuery2.get().then((doc) {
      if (doc.exists) {
        var map = doc.data["data"] as Map<dynamic, dynamic>;
        setState(() {
          _collegeName = map["displayName"];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getCollegeAsal();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: new ListTile(
        title: new Text("${widget.name}"),
        leading: new Container(
          padding: const EdgeInsets.only(left: 10.0),
          child: widget.name == null
              ? new CircleAvatar(
                  backgroundColor: const Color(0xFFe87c55),
                  child: new Text(widget.name[0]),
                )
              : new CircleAvatar(backgroundImage: NetworkImage(widget.name)),
        ),
        subtitle: new Text("${_collegeName == null ? "" : _collegeName}"),
      ),
    );
  }
}
