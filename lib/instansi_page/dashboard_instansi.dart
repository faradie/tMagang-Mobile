import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tempat_magang/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tempat_magang/instansi_page/instansi_buat_lowongan.dart';
import 'package:tempat_magang/instansi_page/manajemenLowonganInstansi.dart';

class InstansiDashboard extends StatefulWidget {
  InstansiDashboard({this.auth, this.onSignedOut, this.wew});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String wew;
  @override
  _InstansiDashboardState createState() => _InstansiDashboardState();
}

class _InstansiDashboardState extends State<InstansiDashboard> {
  String _currentEmail, _namaUser, _statusUser, _idUser;
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
          _idUser = user.uid;
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
            decoration: BoxDecoration(color: const Color(0xFFe87c55)
                //     image: DecorationImage(
                //   image: ExactAssetImage('img/selamatdatang.png'),
                //   fit: BoxFit.cover,
                // )
                ),
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
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      new InstansiBuatLowongan()));
            },
          ),
          new ListTile(
            title: new Text("Manajemen lowongan"),
            trailing: new Icon(Icons.assignment),
            onTap: () {
              Navigator.of(context).pop();
              Navigator.of(
                context,
              ).push(MaterialPageRoute(
                  builder: (BuildContext context) =>
                      new ManajemenLowonganInstansi(
                        idAgency: _idUser,
                      )));
            },
          ),
          new ListTile(
            title: new Text("Tambah mentor"),
            trailing: new Icon(Icons.people_outline),
          ),
          new ListTile(
            title: new Text("Manajemen mentor"),
            trailing: new Icon(Icons.person_outline),
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
      body: Center(child: new Text("Instansi Dashboard")),
    );
  }
}
