import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CollegeData extends StatefulWidget {
  @override
  _CollegeDataState createState() => _CollegeDataState();
}

class _CollegeDataState extends State<CollegeData> {
  Future _getCollege() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore
        .collection('users')
        .where('role', isEqualTo: 'college')
        .getDocuments();
    return qn.documents;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        backgroundColor: const Color(0xFFe87c55),
        title: new Text("Data Kampus"),
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
          future: _getCollege(),
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
              return Center(child: new Text("Yah.. Belum ada data kampus.."));
            } else if (snapshot.hasError) {
              return Center(child: new Text("Yah.. ada yang salah nih.."));
            } else {
              if (snapshot.data.length == 0) {
                return new Center(
                  child: new Text("Belum ada data kampus..."),
                );
              } else {
                return ListView.builder(
                    itemCount: snapshot.data.length,
                    itemBuilder: (_, index) {
                      var map = snapshot.data[index].data["data"]
                          as Map<dynamic, dynamic>;
                      return ListTile(
                        title: Text("${map['displayName']}"),
                        leading: new Container(
                          padding: const EdgeInsets.only(left: 10.0),
                          child: map['photoUrl'] == null
                              ? new CircleAvatar(
                                  backgroundColor: const Color(0xFFe87c55),
                                  child: new Text(map['displayName'][0]),
                                )
                              : new CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(map['photoUrl'])),
                        ),
                        onTap: () {},
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
