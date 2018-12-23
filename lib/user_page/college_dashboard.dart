import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tempat_magang/auth.dart';

class CollegeDashboard extends StatefulWidget {
  CollegeDashboard({this.auth, this.onSignedOut, this.wew});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String wew;
  _CollegeDashboardState createState() => _CollegeDashboardState();
}

class _CollegeDashboardState extends State<CollegeDashboard> {
  String _currentEmail, _statusUser, _namaUser;
  var name;

  StreamController streamController;

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
          _namaUser = name["displayName"];
          _statusUser = data.documents[0].data['role'];
        });
      }
    });
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  setNamanya() {
    if (_namaUser == null) {
      return new Text("Nama belum diatur");
    }
  }

  void getData() async {
    await widget.auth.getUser().then((value) {
      setState(() {
        _currentEmail = value.email;
      });
    });
  }

  @override
  void initState() {
    super.initState();
    getDataUser();
    getData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
          child: ListView(
        children: <Widget>[
          new UserAccountsDrawerHeader(
            accountEmail:
                new Text('${_currentEmail == null ? "" : _currentEmail}'),
            accountName: new Text('${_namaUser == null ? "" : _namaUser}'),
            currentAccountPicture: new CircleAvatar(
              backgroundColor: Colors.amber,
              child: new Text("A"),
            ),
          ),
          ListTile(
            title: new Text("Buat lowongan"),
            trailing: new Icon(Icons.plus_one),
            onTap: () {},
          ),
          ListTile(
            onTap: () {},
            title: new Text("Manajemen Kontrak"),
            trailing: new Icon(Icons.card_membership),
          ),
          ListTile(
            title: new Text("Backup"),
            trailing: new Icon(Icons.backup),
          ),
          new Divider(),
          ExpansionTile(
            title: new Text("Manajemen Data"),
            trailing: new Icon(Icons.book),
            children: <Widget>[
              ListTile(
                title: Text("Data Lowongan"),
                leading: new Icon(Icons.local_activity),
              ),
              ListTile(
                title: Text("Data Instansi"),
                leading: new Icon(Icons.star),
              ),
              ListTile(
                title: Text("Data Pemagang"),
                leading: new Icon(Icons.code),
              ),
            ],
          ),
        ],
      )),
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        backgroundColor: const Color(0xFFe87c55),
        title: new Center(
          child: Text(
              "${widget.wew == null ? "" : widget.wew == "intern" ? "Pemagang" : widget.wew == "agency" ? "Instansi" : widget.wew == "college" ? "Kampus" : widget.wew == "mentor" ? "mentor" : "admin"}"
                  .toUpperCase()),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Icon(Icons.input, color: Colors.white),
            onPressed: _signOut,
          )
        ],
      ),
    );
  }
}
