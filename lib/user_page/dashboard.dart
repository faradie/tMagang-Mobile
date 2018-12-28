import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tempat_magang/auth.dart';
import 'package:tempat_magang/global_page/profil.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:tempat_magang/user_page/detailLowongan.dart';
import 'package:tempat_magang/user_page/lamaran_pemagang.dart';
import 'package:uuid/uuid.dart';

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
  String _currentEmail, _namaUser, _statusUser;
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
          _statusUser = data.documents[0].data['role'];
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
              title: new Text("Profil"),
              trailing: new Icon(Icons.person),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(
                    builder: (BuildContext context) => new Profil()));
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
                    builder: (BuildContext context) => new LamaranPemagang()));
              },
            ),
            new ListTile(
              title: new Text("Rekomendasi"),
              trailing: new Icon(Icons.star),
              onTap: () {
                Navigator.of(context).pop();
                _showToast("Comingsoon", Colors.orange);
              },
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
                          child: new Icon(Icons.input, color: Colors.white),
                          onPressed: _signOut,
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
                          background: Image.asset(
                            "img/selamatdatang.png",
                            fit: BoxFit.cover,
                          ))),
                  SliverPersistentHeader(
                    delegate: _SliverAppBarDelegate(
                      Container(
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Card(
                              child: new ListTile(
                                  trailing: new IconButton(
                                    icon: new Icon(Icons.cancel),
                                    onPressed: () {},
                                  ),
                                  leading: new Icon(Icons.search),
                                  title: new TextField(
                                    decoration: new InputDecoration(
                                        hintText: 'Cari Magangmu',
                                        border: InputBorder.none),
                                  ))),
                        ),
                      ),
                    ),
                    pinned: true,
                  )
                ];
              },
              body: new Column(
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  new Expanded(
                    child: ListPage(),
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
      instansi;

  final int kuota;
  final List<String> requirementNya;
  @override
  Widget build(BuildContext context) {
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
                        child: new CircleAvatar(
                          backgroundColor: const Color(0xFFe87c55),
                          child: new Text("W"),
                        ),
                      ),
                      new Expanded(
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new Container(
                              padding:
                                  const EdgeInsets.only(top: 8.0, left: 8.0),
                              child: new Text(
                                judulNya.toUpperCase(),
                                style: new TextStyle(
                                    fontSize: 15.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey[850]),
                              ),
                            ),
                            new Container(
                              padding:
                                  const EdgeInsets.only(bottom: 8.0, left: 8.0),
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
                  padding:
                      const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
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

  Future getLowongan() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore
        .collection('vacancies')
        .where("expiredAt", isGreaterThanOrEqualTo: dateNow)
        .orderBy("expiredAt", descending: false)
        .getDocuments();

    return qn.documents;
  }

  final loadingLoad = CircularProgressIndicator(
    backgroundColor: Colors.deepOrange,
    strokeWidth: 1.5,
  );
  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: getLowongan(),
        builder: (_, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.max,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[loadingLoad, Text("Loading Data..")],
              ),
            );
          } else {
            if (snapshot.data.length == 0) {
              return Center(child: new Text("Yah.. Belum ada lowongan"));
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, index) {
                  String uploadTglBaru = formatDate(
                      snapshot.data[index].data["createdAt"],
                      [dd, ' ', MM, ' ', yyyy]);
                  String mulaiTglBaru = formatDate(
                      snapshot.data[index].data["timeStartIntern"],
                      [dd, ' ', MM, ' ', yyyy]);
                  String akhirTglBaru = formatDate(
                      snapshot.data[index].data["timeEndIntern"],
                      [dd, ' ', MM, ' ', yyyy]);

                  return new CustomCard(
                    instansi: snapshot.data[index].data["ownerAgency"],
                    kuota: snapshot.data[index].data["quota"],
                    idNya: snapshot.data[index].data["id"],
                    judulNya: snapshot.data[index].data["title"],
                    tglUpload: uploadTglBaru,
                    tglAkhir: akhirTglBaru,
                    tglMulai: mulaiTglBaru,
                    deskripsiNya: snapshot.data[index].data["description"],
                    requirementNya:
                        List.from(snapshot.data[index].data["requirement"]),
                  );
                },
              );
            }
          }
        },
      ),
    );
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final Container _tabBar;

  @override
  double get minExtent => 0.0;
  @override
  double get maxExtent => 80.0;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return new Container(
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
