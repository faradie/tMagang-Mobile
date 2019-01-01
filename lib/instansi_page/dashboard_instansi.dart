import 'package:date_format/date_format.dart';
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
  String _currentEmail, _namaUser, _statusUser, _idUser, _linkPhoto;
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
          _linkPhoto = name["photoURL"];
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
              currentAccountPicture: _linkPhoto == null
                  ? new CircleAvatar(
                      backgroundColor: Colors.white,
                      child: new Text("T", style: TextStyle(fontSize: 25.0)))
                  : new CircleAvatar(backgroundImage: NetworkImage(_linkPhoto)),
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
              leading: Icon(Icons.input),
              title: new Text("Keluar"),
              onTap: _signOut,
            )
          ],
        )),
        body: DefaultTabController(
          length: 2,
          child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
                      actions: <Widget>[
                        new FlatButton(
                          child: new Icon(Icons.search, color: Colors.white),
                          onPressed: () {},
                        )
                      ],
                      expandedHeight: 200.0,
                      elevation: defaultTargetPlatform == TargetPlatform.android
                          ? 5.0
                          : 0.0,
                      backgroundColor: const Color(0xFFe87c55),
                      floating: false,
                      pinned: true,
                      flexibleSpace: FlexibleSpaceBar(
                          centerTitle: true,
                          title: Text(
                              "${_statusUser == null ? "" : _statusUser == "intern" ? "Pemagang" : _statusUser == "agency" ? "Instansi" : _statusUser == "college" ? "Kampus" : _statusUser == "mentor" ? "mentor" : "admin"}"
                                  .toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                              )),
                          background: new Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Image.asset(
                                "img/instansiBack.jpg",
                                fit: BoxFit.cover,
                              ),
                              new Container(
                                color: Color.fromRGBO(232, 124, 85, 0.5),
                              )
                              // new BackdropFilter(
                              //   child: new Container(
                              //     decoration: BoxDecoration(
                              //       color: const Color(0xFFf78842)
                              //           .withOpacity(0.3),
                              //     ),
                              //   ),
                              //   filter: new ui.ImageFilter.blur(
                              //     sigmaX: 2.0,
                              //     sigmaY: 2.0,
                              //   ),
                              // )
                            ],
                          ))),
                  // SliverPersistentHeader(
                  //   delegate: _SliverAppBarDelegate(
                  //     Container(
                  //       child: Padding(
                  //         padding: const EdgeInsets.all(8.0),
                  //         child: Card(
                  //             child: new ListTile(
                  //                 trailing: new IconButton(
                  //                   icon: new Icon(Icons.cancel),
                  //                   onPressed: () {},
                  //                 ),
                  //                 leading: new Icon(Icons.search),
                  //                 title: new TextField(
                  //                   decoration: new InputDecoration(
                  //                       hintText: 'Cari Magangmu',
                  //                       border: InputBorder.none),
                  //                 ))),
                  //       ),
                  //     ),
                  //   ),
                  //   pinned: true,
                  // )
                ];
              },
              body: new Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  // new Container(
                  //   margin: const EdgeInsets.all(10.0),
                  //   child: new Text(
                  //     "Segera temukan magangmu",
                  //     style: TextStyle(
                  //         fontWeight: FontWeight.bold, color: Colors.grey),
                  //   ),
                  // ),
                  Container(
                      margin: const EdgeInsets.only(top: 20.0, left: 10.0),
                      child: new Text(
                        "List Magang Aktif",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey),
                      )),
                  new Expanded(
                      child: ListPage(
                    idUser: _idUser,
                  )),
                ],
              )),
        ));
  }
}

class ListPage extends StatefulWidget {
  ListPage({this.idUser});
  final String idUser;
  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  DateTime dateNow = DateTime.now();

  //composite expiredAt and createdAt
  final loadingLoad = CircularProgressIndicator(
    backgroundColor: Colors.deepOrange,
    strokeWidth: 1.5,
  );
  @override
  Widget build(BuildContext context) {
    DateTime dateNow = DateTime.now();
    return Container(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('internship')
            .where('ownerAgency', isEqualTo: widget.idUser)
            .where('timeEndIntern', isGreaterThanOrEqualTo: dateNow)
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
            return Center(child: new Text("Yah.. Belum ada lowongan.."));
          } else if (snapshot.hasError) {
            return Center(child: new Text("Yah.. ada yang salah nih.."));
          } else {
            if (snapshot.data.documents.length > 0) {
              return ListView.builder(
                itemCount: snapshot.data.documents.length,
                itemBuilder: (_, index) {
                  DocumentSnapshot ds = snapshot.data.documents[index];
                  return TileLowongan(
                    idLowongan: ds["vacanciesId"],
                    no: (index + 1).toString(),
                  );
                },
              );
            } else {
              return Center(
                child: new Text(
                  "Belum ada magang yang AKTIF",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              );
            }
          }
        },
      ),
    );
  }
}

class TileLowongan extends StatefulWidget {
  TileLowongan({this.idLowongan, this.no});
  final String idLowongan, no;

  @override
  TileLowonganState createState() {
    return new TileLowonganState();
  }
}

class TileLowonganState extends State<TileLowongan> {
  String _judulLowongan;
  Future getDataUser() async {
    var firestore = Firestore.instance;
    var userQuery = firestore
        .collection('vacancies')
        .where('id', isEqualTo: widget.idLowongan)
        .limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          _judulLowongan = data.documents[0].data['title'];
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getDataUser();
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
            _judulLowongan == null ? "" : _judulLowongan,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: new Text("Dibuat pada : "),
          // trailing: new Icon(widget.iconData, color: widget.warna),
        ),
        new Divider(),
      ],
    ));
  }
}
