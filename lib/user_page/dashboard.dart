import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:fluttertoast/fluttertoast.dart';
import 'package:tempat_magang/auth.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:tempat_magang/user_page/detailLowongan.dart';
import 'package:tempat_magang/user_page/internprofil.dart';
import 'package:tempat_magang/user_page/lamaran_pemagang.dart';

class Dashboard extends StatefulWidget {
  Dashboard({this.auth, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  @override
  _DashboardState createState() => _DashboardState();
}

enum AuthStatus { notSignedIn, signedIn }
// class DashborInst extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return InstansiDashboard();
//   }
// }

class _DashboardState extends State<Dashboard> {
  AuthStatus authStatus = AuthStatus.notSignedIn;
  String _currentEmail, _namaUser, _idUser, _role, _linkPhoto;
  bool _statusUser;
  ScrollController _hideButtonController;
  var name;

  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  void _signedIn() {
    setState(() {
      authStatus = AuthStatus.signedIn;
    });
  }

  void _showToast(String pesan, MaterialColor warna) {
    Fluttertoast.showToast(
      msg: pesan,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: warna,
      textColor: Colors.white,
    );
  }

  void _signedOut() {
    setState(() {
      authStatus = AuthStatus.notSignedIn;
    });
  }

  void getData() async {
    await widget.auth.getUser().then((value) {
      setState(() {
        _currentEmail = value.email;
      });
    });
  }

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
          _linkPhoto = name["photoURL"];
          _idUser = data.documents[0].data['uid'];
          _statusUser = data.documents[0].data['isActive'];
          _role = data.documents[0].data['role'];
        });
      }
    });
  }

  bool _isVisible = true;
  @override
  void initState() {
    super.initState();

    getData();
    getDataUser();

    // _isVisible = true;
    // _hideButtonController = new ScrollController();
    // _hideButtonController.addListener(() {
    //   if (_hideButtonController.position.userScrollDirection ==
    //       ScrollDirection.forward) {
    //     setState(() {
    //       _isVisible = true;
    //       print("**** $_isVisible up");
    //     });
    //   }
    //   if (_hideButtonController.position.userScrollDirection ==
    //       ScrollDirection.reverse) {
    //     setState(() {
    //       _isVisible = false;
    //       print("**** $_isVisible down");
    //     });
    //   }
    // });
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        floatingActionButton: new Opacity(
          opacity: _isVisible ? 1.0 : 0.0,
          child: new FloatingActionButton(
            onPressed: () {},
            tooltip: 'Increment',
            child: new Icon(Icons.chat),
          ),
        ),
        drawer: StreamBuilder(
            stream: Firestore.instance
                .collection('users')
                .document('$_idUser')
                .snapshots(),
            builder: (BuildContext context,
                AsyncSnapshot<DocumentSnapshot> snapshot) {
              if (snapshot.hasError) {
                return Center(child: new Text("Load"));
              } else if (!snapshot.hasData) {
                return Drawer(
                    child: ListView(
                  children: <Widget>[
                    new UserAccountsDrawerHeader(
                      accountName: new Text(""),
                      decoration: BoxDecoration(color: const Color(0xFFe87c55)
                          //     image: DecorationImage(
                          //   image: ExactAssetImage('img/selamatdatang.png'),
                          //   fit: BoxFit.cover,
                          // )
                          ),
                      accountEmail: new Text(
                          '${_currentEmail == null ? "" : _currentEmail}'),
                    ),
                    new ListTile(
                      title: new Text("Profil"),
                      trailing: new Icon(Icons.person),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new InternProfil(id: _idUser)));
                      },
                    ),
                    new Divider(),
                    new ListTile(
                      title: new Text("Lamaran"),
                      trailing: new Icon(Icons.find_in_page),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new LamaranPemagang()));
                      },
                    ),
                    new ListTile(
                      title: new Text("Riwayat Lamaran"),
                      trailing: new Icon(Icons.timeline),
                      onTap: () {},
                    ),
                    new ListTile(
                      title: new Text("Rekomendasi"),
                      trailing: new Icon(Icons.star),
                      onTap: () {
                        Navigator.of(context).pop();
                        _showToast("Comingsoon", Colors.orange);
                      },
                    ),
                    new Divider(),
                    new ListTile(
                      leading: Icon(Icons.input),
                      title: new Text("Keluar"),
                      onTap: _signOut,
                    )
                  ],
                ));
              } else if (snapshot.connectionState == ConnectionState.active ||
                  snapshot.hasData) {
                name = snapshot.data['data'] as Map<dynamic, dynamic>;
                return Drawer(
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
                          new Text(name["email"] == null ? "" : name["email"]),
                      accountName: new Text(name["displayName"] == null
                          ? ""
                          : name["displayName"]),
                      currentAccountPicture: _linkPhoto == null
                          ? new CircleAvatar(
                              backgroundColor: Colors.white,
                              child: new Text("T",
                                  style: TextStyle(fontSize: 25.0)))
                          : new CircleAvatar(
                              backgroundImage: NetworkImage(name["photoURL"])),
                    ),
                    new ListTile(
                      title: new Text("Profil"),
                      trailing: new Icon(Icons.person),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new InternProfil(id: _idUser)));
                      },
                    ),
                    new Divider(),
                    new ListTile(
                      title: new Text("Lamaran"),
                      trailing: new Icon(Icons.find_in_page),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.of(
                          context,
                        ).push(MaterialPageRoute(
                            builder: (BuildContext context) =>
                                new LamaranPemagang()));
                      },
                    ),
                    new ListTile(
                      title: new Text("Rekomendasi"),
                      trailing: new Icon(Icons.star),
                      onTap: () {
                        Navigator.of(context).pop();
                        _showToast("Comingsoon", Colors.orange);
                      },
                    ),
                    new Divider(),
                    new ListTile(
                      leading: Icon(Icons.input),
                      title: new Text("Keluar"),
                      onTap: _signOut,
                    )
                  ],
                ));
              }
            }),
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
                              "${_role == null ? "" : _role == "intern" ? "Pemagang" : _role == "agency" ? "Instansi" : _role == "college" ? "Kampus" : _role == "mentor" ? "mentor" : "admin"}"
                                  .toUpperCase(),
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20.0,
                              )),
                          background: new Stack(
                            fit: StackFit.expand,
                            children: <Widget>[
                              Image.asset(
                                "img/graduate2.png",
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
                  new Expanded(
                    child: _statusUser == null
                        ? new Container()
                        : _statusUser == false
                            ? ListPage()
                            : new Center(
                                child: new Text(
                                    "Anda sedang melaksanakan tugas Magang"),
                              ),
                  ),
                ],
              )),
        ));
  }

  setNamanya() {
    if (_namaUser == null) {
      return new Text("Nama belum diatur");
    }
  }
}

// class ListMenu extends StatelessWidget {
//   Future getMenu() async {
//     var firestore = Firestore.instance;
//     QuerySnapshot qn = await firestore
//         .collection("autority/pemagang/menuPemagang")
//         .getDocuments();
//     return qn.documents;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       child: FutureBuilder(
//           future: getMenu(),
//           builder: (_, snapshot) {
//             if (snapshot.connectionState == ConnectionState.waiting) {
//               return Center(
//                 child: Text("Loading Menu.."),
//               );
//             } else {
//               return ListView.builder(
//                 itemCount: snapshot.data.length,
//                 itemBuilder: (_, index) {
//                   return new ListTile(
//                     title: new Text(snapshot.data[index].data["name"]),
//                     trailing: new Icon(Icons.library_books),
//                   );
//                 },
//               );
//             }
//           }),
//     );
//   }
// }

class Deskrips extends StatelessWidget {
  Deskrips({this.des});
  final String des;
  @override
  Widget build(BuildContext context) {
    if (des.length >= 100) {
      return new Container(
          padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
          child: Row(
            children: <Widget>[
              new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new RichText(
                      text: new TextSpan(
                          style: new TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            new TextSpan(text: "${des.substring(0, 100)}..."),
                            new TextSpan(
                                text: " Baca selengkapnya",
                                style:
                                    new TextStyle(fontWeight: FontWeight.bold))
                          ]),
                    )
                  ],
                ),
              )
            ],
          ));
    } else {
      return new Container(
          padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
          child: Row(
            children: <Widget>[
              new Expanded(
                child: new Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    new RichText(
                      text: new TextSpan(
                          style: new TextStyle(
                            fontSize: 14.0,
                            color: Colors.black,
                          ),
                          children: <TextSpan>[
                            new TextSpan(text: "$des"),
                          ]),
                    )
                  ],
                ),
              )
            ],
          ));
    }
  }
}

class CustomCard extends StatelessWidget {
  CustomCard(
      {this.judulNya,
      this.tglUpload,
      this.kuota,
      this.instansi,
      this.tglAkhir,
      this.jurusan,
      this.tglMulai,
      this.deskripsiNya,
      this.requirementNya,
      this.idNya});
  final String judulNya,
      deskripsiNya,
      idNya,
      tglUpload,
      tglMulai,
      tglAkhir,
      instansi,
      jurusan;

  final int kuota;
  final List<String> requirementNya;

  @override
  Widget build(BuildContext context) {
    return new StreamBuilder<DocumentSnapshot>(
        stream: Firestore.instance
            .collection('users')
            .document('$instansi')
            .snapshots(),
        builder:
            (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center();
          } else if (!snapshot.hasData) {
            return Center(child: new Text("Yah.. Belum ada lowongan.."));
          } else if (snapshot.hasError) {
            return Center(child: new Text("Yah.. ada yang salah nih.."));
          } else {
            var dataMap = snapshot.data['data'] as Map<dynamic, dynamic>;
            String _linkPhoto = dataMap["photoURL"];
            return Hero(
              tag: idNya,
              child: Material(
                child: InkWell(
                  onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) => new DetailLowongan(
                              tglUpload: tglUpload,
                              kuota: kuota,
                              instansi: instansi,
                              tglAwal: tglMulai,
                              tglAkhir: tglAkhir,
                              requirementNya: requirementNya,
                              deskripsiNya: deskripsiNya,
                              idNya: idNya,
                              judulNya: judulNya,
                              jurusan: jurusan,
                              linkPhoto: _linkPhoto,
                            ),
                      )),
                  child: new Card(
                    elevation: 2.0,
                    color: Colors.white,
                    child: Column(
                      children: <Widget>[
                        Container(
                          child: Row(
                            children: <Widget>[
                              new Container(
                                padding: const EdgeInsets.only(left: 10.0),
                                child: _linkPhoto == null
                                    ? new CircleAvatar(
                                        backgroundColor:
                                            const Color(0xFFe87c55),
                                        child: new Text("T"),
                                      )
                                    : new CircleAvatar(
                                        backgroundImage:
                                            NetworkImage(_linkPhoto)),
                              ),
                              new Expanded(
                                child: new Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: <Widget>[
                                    new Container(
                                      padding: const EdgeInsets.only(
                                          top: 8.0, left: 8.0),
                                      child: new Text(
                                        judulNya.toUpperCase(),
                                        style: new TextStyle(
                                            fontSize: 15.0,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.grey[850]),
                                      ),
                                    ),
                                    new Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, left: 8.0),
                                      child: new Text(
                                        tglUpload.toString(),
                                        style: new TextStyle(
                                            color: Colors.grey, fontSize: 13.0),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              // new Text("Judul"),
                              // new Container(
                              //   child: new IconButton(
                              //     icon: Icon(Icons.bookmark_border),
                              //   ),
                              // ),
                              new Container(
                                child: new IconButton(
                                  onPressed: () {},
                                  icon: Icon(Icons.more_vert),
                                ),
                              ),
                            ],
                          ),
                        ),
                        new Deskrips(
                          des: deskripsiNya,
                        ),
                        Container(
                          padding: const EdgeInsets.only(
                              bottom: 8.0, left: 8.0, right: 8.0),
                          child: Container(
                              height: 25.0,
                              color: Colors.transparent,
                              child: Requir(
                                req: requirementNya,
                              )),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }
        });
  }
}

class KompetensiUser extends StatelessWidget {
  KompetensiUser({this.judulKompetensi});
  final String judulKompetensi;
  @override
  Widget build(BuildContext context) {
    return new Container(
        padding: const EdgeInsets.only(left: 10.0, right: 10.0),
        decoration: new BoxDecoration(
            color: Colors.transparent,
            border: new Border.all(color: const Color(0xFFe87c55), width: 1.0),
            borderRadius: new BorderRadius.all(Radius.circular(20.0))),
        child: new Center(
          child: new Text(
            judulKompetensi,
            style: TextStyle(
                fontSize: 15.0,
                color: const Color(0xFFe87c55),
                fontWeight: FontWeight.bold),
          ),
        ));
  }
}

class Requir extends StatelessWidget {
  Requir({this.req});
  final List<String> req;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      scrollDirection: Axis.horizontal,
      itemCount: req.length,
      itemBuilder: (_, index) {
        return Container(
          padding: const EdgeInsets.only(right: 5.0),
          child: KompetensiUser(
            judulKompetensi: req[index].toString(),
          ),
        );
      },
    );
  }
}

class ListPage extends StatefulWidget {
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
    return Container(
      child: StreamBuilder(
        stream: Firestore.instance
            .collection('vacancies')
            .where("expiredAt", isGreaterThanOrEqualTo: dateNow)
            .orderBy('expiredAt', descending: true)
            .orderBy('createdAt', descending: true)
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
            // print("ini jumlahnyaaaaaaaaa ${snapshot.data.documents.length}");
            return ListView.builder(
              itemCount: snapshot.data.documents.length,
              itemBuilder: (_, index) {
                DocumentSnapshot ds = snapshot.data.documents[index];
                String uploadTglBaru =
                    formatDate(ds["createdAt"], [dd, ' ', MM, ' ', yyyy]);
                String mulaiTglBaru =
                    formatDate(ds["timeStartIntern"], [dd, ' ', MM, ' ', yyyy]);
                String akhirTglBaru =
                    formatDate(ds["timeEndIntern"], [dd, ' ', MM, ' ', yyyy]);

                return new CustomCard(
                  jurusan: ds["departement"],
                  instansi: ds["ownerAgency"],
                  kuota: ds["quota"],
                  idNya: ds["id"],
                  judulNya: ds["title"],
                  tglUpload: uploadTglBaru,
                  tglAkhir: akhirTglBaru,
                  tglMulai: mulaiTglBaru,
                  deskripsiNya: ds["description"],
                  requirementNya: List.from(ds["requirement"]),
                );
              },
            );
          }
        },
      ),
    );
  }
}
