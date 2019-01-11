import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:tempat_magang/admin_page/data_instansi.dart';
import 'package:tempat_magang/admin_page/manajemen_lowongan.dart';

import 'package:tempat_magang/auth.dart';
import 'package:tempat_magang/instansi_page/instansi_buat_lowongan.dart';

class AdminDashboard extends StatefulWidget {
  AdminDashboard({this.auth, this.onSignedOut, this.wew});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String wew;
  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  String _currentEmail, _statusUser, _namaUser, _uid;
  var name;
  DateTime dateNow = DateTime.now();

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
          _uid = user.uid;
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
    var listMenuAdmin = [
      "Lowongan Aktif",
      "Lowongan NonAktif",
      "Jumlah Instansi",
      "Jumlah Pemagang",
      "Jumlah Admin",
      "Jumlah Kampus",
    ];
    var iconMenuAdmin = [
      Firestore.instance
          .collection('vacancies')
          .where("expiredAt", isGreaterThanOrEqualTo: dateNow)
          .snapshots(),
      Firestore.instance
          .collection('vacancies')
          .where("expiredAt", isLessThan: dateNow)
          .snapshots(),
      Firestore.instance
          .collection('users')
          .where('role', isEqualTo: 'agency')
          .snapshots(),
      Firestore.instance
          .collection('users')
          .where('role', isEqualTo: 'intern')
          .snapshots(),
      Firestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin')
          .snapshots(),
      Firestore.instance
          .collection('users')
          .where('role', isEqualTo: 'college')
          .snapshots()
    ];
    var adminGridView = new GridView.builder(
      itemCount: listMenuAdmin.length,
      gridDelegate:
          new SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (BuildContext context, int index) {
        return new GestureDetector(
          child: new Card(
            // color: Colors.pinkAccent,
            elevation: 5.0,
            child: new Container(
              alignment: Alignment.center,
              margin: const EdgeInsets.all(5.0),
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  StreamBuilder(
                    stream: iconMenuAdmin[index],
                    builder: (context, snapshot) {
                      if (!snapshot.hasData)
                        return new Text(
                          "0",
                          style: TextStyle(
                              color: Colors.orange,
                              fontWeight: FontWeight.bold,
                              fontSize: 30.0),
                        );
                      return new Text(
                        snapshot.data.documents.length.toString(),
                        style: TextStyle(
                            color: Colors.orange,
                            fontWeight: FontWeight.bold,
                            fontSize: 30.0),
                      );
                    },
                  ),
                  new Text(
                    listMenuAdmin[index],
                    style: TextStyle(
                        color: Colors.orange[200],
                        fontWeight: FontWeight.bold,
                        fontSize: 13.0),
                    textAlign: TextAlign.center,
                  )
                ],
              ),
            ),
          ),
          onTap: () {},
        );
      },
    );

    //just Potrait
    // SystemChrome.setPreferredOrientations([
    //   DeviceOrientation.portraitUp,
    //   DeviceOrientation.portraitDown,
    // ]);
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
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(
                    builder: (BuildContext context) => new InstansiBuatLowongan(
                          id: _uid,
                        )));
              },
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
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(
                        builder: (BuildContext context) => new InternManage()));
                  },
                ),
                ListTile(
                  title: Text("Data Instansi"),
                  leading: new Icon(Icons.star),
                  onTap: () {
                    Navigator.of(context).pop();
                    Navigator.of(
                      context,
                    ).push(MaterialPageRoute(
                        builder: (BuildContext context) => new InstansiData()));
                  },
                ),
                ListTile(
                  title: Text("Data Kampus"),
                  leading: new Icon(Icons.star_border),
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
          elevation:
              defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
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
        body: adminGridView);
  }
}
