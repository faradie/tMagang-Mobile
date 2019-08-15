import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tempat_magang/auth.dart';
import 'package:tempat_magang/global_page/bantuan.dart';
import 'package:tempat_magang/mentor/listMagangMentor.dart';
import 'package:tempat_magang/mentor/profilMentor.dart';

final loadingLoad = CircularProgressIndicator(
  backgroundColor: Colors.deepOrange,
  strokeWidth: 1.5,
);

class MentorDashboard extends StatefulWidget {
  MentorDashboard({this.auth, this.onSignedOut, this.stats});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String stats;
  _MentorDashboardState createState() => _MentorDashboardState();
}

class _MentorDashboardState extends State<MentorDashboard> {
  String _statusUser, _idUser, _agencyId;
  var tmp;

  Future _getDataUser() async {
    var user = await FirebaseAuth.instance.currentUser();
    var firestore = Firestore.instance;
    var userQuery = firestore
        .collection('users')
        .where('uid', isEqualTo: user.uid)
        .limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          tmp = data.documents[0].data['data'] as Map<dynamic, dynamic>;

          _agencyId = tmp["agencyId"];
          _idUser = user.uid;
          _statusUser = data.documents[0].data['role'];
        });
      }
    });
  }

  showAlertLogout() {
    Navigator.of(context).pop();
    showDialog(
        barrierDismissible: true,
        context: context,
        builder: (context) => AlertDialog(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(32.0))),
              contentPadding: EdgeInsets.only(top: 10.0),
              content: Container(
                  width: 300.0,
                  padding: const EdgeInsets.only(
                    top: 20.0,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      Column(
                        // mainAxisAlignment: MainAxisAlignment.start,
                        // // crossAxisAlignment: CrossAxisAlignment.stretch,
                        // mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          new Text(
                            "Perhatian".toUpperCase(),
                            textAlign: TextAlign.center,
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 16.0),
                          new Text(
                            "Yakin ingin keluar akun?",
                          ),
                          SizedBox(height: 16.0),
                        ],
                      ),
                      ButtonTheme(
                        minWidth: 200.0,
                        height: 60.0,
                        child: new RaisedButton(
                          color: const Color(0xFFff9977),
                          elevation: 4.0,
                          splashColor: Colors.blueGrey,
                          onPressed: _signOut,
                          shape: new RoundedRectangleBorder(
                            borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(32.0),
                                bottomRight: Radius.circular(32.0)),
                          ),
                          padding: const EdgeInsets.only(),
                          child: Text(
                            "Yakin",
                            style: TextStyle(color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  )),
            ));
  }

  void _signOut() async {
    try {
      await widget.auth.signOut();
      Navigator.of(context).pop();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _getDataUser();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: new Drawer(
            child: ListView(
          children: <Widget>[
            new StreamBuilder(
                stream: Firestore.instance
                    .collection('users')
                    .document('$_idUser')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: new Text("Load"));
                  } else if (!snapshot.hasData) {
                    return new UserAccountsDrawerHeader(
                        decoration: BoxDecoration(color: const Color(0xFFe87c55)
                            //     image: DecorationImage(
                            //   image: ExactAssetImage('img/selamatdatang.png'),
                            //   fit: BoxFit.cover,
                            // )
                            ),
                        accountEmail: new Text("Mengambil data"),
                        accountName: new Text("Mengambil data"),
                        currentAccountPicture: new CircleAvatar(
                            backgroundColor: Colors.white,
                            child: new Text("T",
                                style: TextStyle(fontSize: 25.0))));
                  } else if (snapshot.connectionState ==
                          ConnectionState.active ||
                      snapshot.hasData) {
                    tmp = snapshot.data['data'] as Map<dynamic, dynamic>;
                    return new UserAccountsDrawerHeader(
                      decoration: BoxDecoration(color: const Color(0xFFe87c55)
                          //     image: DecorationImage(
                          //   image: ExactAssetImage('img/selamatdatang.png'),
                          //   fit: BoxFit.cover,
                          // )
                          ),
                      accountEmail:
                          new Text(tmp["email"] == null ? "" : tmp["email"]),
                      accountName: new Text(tmp["displayName"] == null
                          ? ""
                          : tmp["displayName"]),
                      currentAccountPicture: tmp["photoURL"] == null
                          ? new CircleAvatar(
                              backgroundColor: Colors.white,
                              child: new Text("T",
                                  style: TextStyle(fontSize: 25.0)))
                          : tmp["photoURL"] == ""
                              ? new CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: new Text("T",
                                      style: TextStyle(fontSize: 25.0)))
                              : new CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(tmp["photoURL"])),
                    );
                  } else {
                    return new UserAccountsDrawerHeader(
                      decoration: BoxDecoration(color: const Color(0xFFe87c55)
                          //     image: DecorationImage(
                          //   image: ExactAssetImage('img/selamatdatang.png'),
                          //   fit: BoxFit.cover,
                          // )
                          ),
                      accountEmail: new Text("Mengambil data..."),
                      accountName: new Text("Mengambil data..."),
                      currentAccountPicture: new Text("Mengambil data..."),
                    );
                  }
                }),
            new ListTile(
              title: new Text("Mentoring"),
              trailing: new Icon(Icons.list),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(
                    builder: (BuildContext context) => new Mentoring(
                          idMentor: _idUser,
                        )));
              },
            ),
            new ListTile(
              title: new Text("Profil"),
              trailing: new Icon(Icons.person),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(
                    builder: (BuildContext context) => new ProfilMentor(
                          iduser: _idUser,
                        )));
              },
            ),
            new Divider(),
            new ListTile(
              leading: Icon(Icons.help),
              title: new Text("Bantuan"),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(
                    builder: (BuildContext context) => new Bantuan()));
              },
            ),
            new ListTile(
              leading: Icon(Icons.input),
              title: new Text("Keluar"),
              onTap: showAlertLogout,
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
                        // new FlatButton(
                        //   child: new Icon(Icons.add, color: Colors.white),
                        //   onPressed: () {},
                        // )
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
                                "img/lecturer.jpg",
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
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                      margin: const EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0),
                      child: Card(
                        child: Container(
                          margin: const EdgeInsets.all(5.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              new Text(
                                "Informasi",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 20.0,
                                    color: Colors.grey),
                              ),
                            ],
                          ),
                        ),
                      )),
                  new Expanded(
                    child: Container(
                      margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                      child: ListView(
                        children: <Widget>[
                          new Card(
                            child: Container(
                              margin: const EdgeInsets.all(10.0),
                              child: Column(
                                children: <Widget>[
                                  new Text(
                                    "Perusahaan",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Colors.grey),
                                  ),
                                  StreamBuilder<DocumentSnapshot>(
                                    stream: Firestore.instance
                                        .collection('users')
                                        .document('$_agencyId')
                                        .snapshots(),
                                    builder: (BuildContext context,
                                        AsyncSnapshot<DocumentSnapshot>
                                            snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              loadingLoad,
                                              Text("Loading Data..")
                                            ],
                                          ),
                                        );
                                      } else if (snapshot.hasError) {
                                        return Center(
                                            child: new Text(
                                                "Yah.. ada yang salah nih.."));
                                      } else if (!snapshot.hasData) {
                                        return Text(
                                          'No Data...',
                                        );
                                      } else if (snapshot.connectionState ==
                                          ConnectionState.active) {
                                        var wew = snapshot.data["data"] == null
                                            ? ""
                                            : snapshot.data["data"];
                                        return new Text(
                                            "${wew['displayName'] == null ? "Mengambil data" : wew['displayName'].toUpperCase()}");
                                      } else {
                                        return Center(
                                          child: Column(
                                            mainAxisSize: MainAxisSize.max,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: <Widget>[
                                              loadingLoad,
                                              Text("Loading Data..")
                                            ],
                                          ),
                                        );
                                      }
                                    },
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              )),
        ));
  }
}
