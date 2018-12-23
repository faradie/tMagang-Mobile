import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tempat_magang/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class InstansiDashboard extends StatefulWidget {
  InstansiDashboard({this.auth, this.onSignedOut, this.wew});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String wew;
  @override
  _InstansiDashboardState createState() => _InstansiDashboardState();
}

class _InstansiDashboardState extends State<InstansiDashboard> {
  String _currentEmail, _namaUser, _statusUser;

  Future getDataUser() async {
    var user = await FirebaseAuth.instance.currentUser();
    var firestore = Firestore.instance;
    var userQuery = firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1);
    userQuery.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          _namaUser = data.documents[0].data['name'];
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
            accountName: new Text('$_namaUser'),
            currentAccountPicture: new CircleAvatar(
              backgroundColor: Colors.amber,
              child: new Text("A"),
            ),
          ),
          new ListTile(
            title: new Text("Buat lowongan"),
            trailing: new Icon(Icons.plus_one),
          ),
          new ListTile(
            title: new Text("Profil"),
            trailing: new Icon(Icons.person),
          ),
          new Divider(),
          new ListTile(
            title: new Text("Pengaturan"),
            trailing: new Icon(Icons.settings),
          )
        ],
      )),
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        backgroundColor: const Color(0xFFe87c55),
        title: new Center(
          child:
              Text("${_statusUser == null ? "" : _statusUser}".toUpperCase()),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Icon(Icons.input, color: Colors.white),
            onPressed: _signOut,
          )
        ],
      ),
      body: Center(child: new Text("Instansi Dashboard")),
    );
  }
}
