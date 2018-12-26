import 'dart:async';
import 'package:cloud_functions/cloud_functions.dart';
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
          // ListTile(
          //   title: new Text("Tambah Pemagang"),
          //   trailing: new Icon(Icons.person_add),
          //   onTap: () {
          //     Navigator.of(context).pop();
          //     Navigator.of(
          //       context,
          //     ).push(MaterialPageRoute(
          //         builder: (BuildContext context) => new CreateIntern()));
          //   },
          // ),
          ListTile(
              onTap: () {},
              title: new Text("Pengelolaan Pemagang"),
              trailing: new Icon(Icons.card_travel)),
          new Divider(),
          ListTile(
            title: new Text("Profil"),
            trailing: new Icon(Icons.person_outline),
          ),
        ],
      )),
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        backgroundColor: const Color(0xFFe87c55),
        title: new Center(
          child: Text(
              "${_statusUser == null ? "" : _statusUser == "intern" ? "Pemagang" : _statusUser == "agency" ? "Instansi" : _statusUser == "college" ? "Kampus" : _statusUser == "mentor" ? "mentor" : "admin"}"
                  .toUpperCase()),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Icon(Icons.input, color: Colors.white),
            onPressed: _signOut,
          )
        ],
      ),
      body: new ListView(
        children: <Widget>[
          new Container(
            child: new Card(
              child: Container(
                  margin: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Text(
                        "Informasi kontrak",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                      ),
                    ],
                  )),
            ),
          )
        ],
      ),
    );
  }
}
