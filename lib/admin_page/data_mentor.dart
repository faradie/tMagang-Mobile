import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class MentorData extends StatefulWidget {
  @override
  _MentorDataState createState() => _MentorDataState();
}

class _MentorDataState extends State<MentorData> {
  var firestore = Firestore.instance;

  Future getMentorAgency(String id) async {
    var _agencyName;
    var firestore = Firestore.instance;
    var userQuery =
        firestore.collection('users').where('uid', isEqualTo: id).limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          var tmp = data.documents[0].data['data'] as Map<dynamic, dynamic>;
          _agencyName = tmp["displayName"];
        });
        return _agencyName;
      }
    });
  }

  Future _getMentor() async {
    QuerySnapshot qn = await firestore
        .collection('users')
        .where('role', isEqualTo: 'mentor')
        .getDocuments();
    return qn.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        backgroundColor: const Color(0xFFe87c55),
        title: new Text("Data Mentor"),
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
          future: _getMentor(),
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
              return Center(child: new Text("Yah.. Belum ada data mentor.."));
            } else if (snapshot.hasError) {
              return Center(child: new Text("Yah.. ada yang salah nih.."));
            } else {
              if (snapshot.data.length == 0) {
                return new Center(
                  child: new Text("Belum ada data mentor..."),
                );
              } else {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (_, index) {
                      var map = snapshot.data[index].data["data"]
                          as Map<dynamic, dynamic>;
                      return new TileMentor(
                        agencyId: map['agencyId'],
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

class TileMentor extends StatefulWidget {
  TileMentor({this.no, this.uid, this.agencyId, this.name});
  final String name, uid, agencyId, no;
  @override
  _TileMentorState createState() => _TileMentorState();
}

class _TileMentorState extends State<TileMentor> {
  String _agencyName;

  Future _getAgencyAsal() async {
    var firestore = Firestore.instance;
    var userQuery2 =
        firestore.collection('users').document(widget.agencyId);
    userQuery2.get().then((doc) {
      if (doc.exists) {
        var map = doc.data["data"] as Map<dynamic, dynamic>;
        setState(() {
          _agencyName = map["displayName"];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    _getAgencyAsal();
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
        subtitle: new Text("${_agencyName == null ? "" : _agencyName}"),
      ),
    );
  }
}
