import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tempat_magang/auth.dart';
import 'package:tempat_magang/global_page/profil.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';

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
        appBar: AppBar(
          elevation:
              defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
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
            ),
            new ListTile(
              title: new Text("Rekomendasi"),
              trailing: new Icon(Icons.star),
            )
          ],
        )),
        body: new Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Column(
              children: <Widget>[
                new Container(
                  color: const Color(0xFFff9977),
                  child: new Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: new Card(
                      child: new ListTile(
                        leading: new Icon(Icons.search),
                        title: new TextField(
                          // controller: controllerSearch,
                          decoration: new InputDecoration(
                              hintText: 'Search', border: InputBorder.none),
                          // onChanged: ,
                        ),
                        trailing: new IconButton(
                          icon: new Icon(Icons.cancel),
                          onPressed: () {},
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            new Expanded(
              child: ListPage(),
            )
          ],
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
  String des;
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
  String _instansiNya;
  Future getLowongan() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore
        .collection('vacancies')
        .orderBy("tglUpload", descending: true)
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
              child: Text("Loading Data.."),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (_, index) {
                String uploadTglBaru = formatDate(
                    snapshot.data[index].data["tglUpload"],
                    [dd, ' ', MM, ' ', yyyy]);
                String mulaiTglBaru = formatDate(
                    snapshot.data[index].data["tglMulai"],
                    [dd, ' ', MM, ' ', yyyy]);
                String akhirTglBaru = formatDate(
                    snapshot.data[index].data["tglBerakhir"],
                    [dd, ' ', MM, ' ', yyyy]);
                return new CustomCard(
                  instansi: snapshot.data[index].data["instansiPenyelenggara"],
                  kuota: snapshot.data[index].data["kuota"],
                  idNya: snapshot.data[index].data["id"],
                  judulNya: snapshot.data[index].data["judul"],
                  tglUpload: uploadTglBaru,
                  tglAkhir: akhirTglBaru,
                  tglMulai: mulaiTglBaru,
                  deskripsiNya: snapshot.data[index].data["deskripsi"],
                  requirementNya:
                      List.from(snapshot.data[index].data["requirement"]),
                );
              },
            );
          }
        },
      ),
    );
  }
}

class DetailLowongan extends StatelessWidget {
  DetailLowongan(
      {this.judulNya,
      this.kuota,
      this.tglUpload,
      this.instansi,
      this.tglAkhir,
      this.tglAwal,
      this.deskripsiNya,
      this.requirementNya,
      this.idNya});
  final String judulNya,
      deskripsiNya,
      idNya,
      tglUpload,
      tglAwal,
      tglAkhir,
      instansi;

  final int kuota;

  final List<String> requirementNya;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: new Icon(
            Icons.chevron_left,
            color: Colors.white,
          ),
        ),
        title: new Text("Detail"),
        backgroundColor: const Color(0xFFe87c55),
        actions: <Widget>[
          new FlatButton(
            child: new Icon(Icons.share, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: new ListView(
        children: <Widget>[
          new Card(
            color: Colors.white,
            child: new Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                new Container(
                  child: new Center(
                    child: new Text("Foto"),
                  ),
                  height: 110.0,
                  width: 110.0,
                  // color: Colors.red,
                  decoration: new BoxDecoration(
                      color: Color(0xFFe87c55),
                      borderRadius: new BorderRadius.only(
                          bottomLeft: Radius.circular(5.0),
                          topLeft: Radius.circular(5.0))),
                ),
                Expanded(
                  child: new Container(
                    child: Padding(
                      padding: const EdgeInsets.all(5.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text("$judulNya",
                              style: new TextStyle(
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800])),
                          new Text("Kuota $kuota"),
                          Padding(
                            padding: const EdgeInsets.all(5.0),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Expanded(
                                child: ButtonTheme(
                                  minWidth: 200.0,
                                  height: 40.0,
                                  child: new RaisedButton(
                                    color: const Color(0xFFff9977),
                                    elevation: 4.0,
                                    splashColor: Colors.blueGrey,
                                    onPressed: () {},
                                    child: new Text(
                                      'Gabung'.toUpperCase(),
                                      style: TextStyle(
                                          fontSize: 20.0, color: Colors.white),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 5.0),
          Container(
            decoration: new BoxDecoration(
                border:
                    new Border.all(color: const Color(0xFFe87c55), width: 1.0),
                borderRadius: new BorderRadius.all(Radius.circular(20.0))),
            margin: const EdgeInsets.only(left: 5.0, right: 5.0),
            padding: const EdgeInsets.only(top: 10.0, bottom: 10.0),
            child: Column(
              children: <Widget>[
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new Text(
                      "Periode".toUpperCase(),
                      style: TextStyle(fontWeight: FontWeight.bold),
                    )
                  ],
                ),
                SizedBox(height: 16.0),
                Row(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Container(
                        child: Column(
                      children: <Widget>[
                        new Text("Mulai",
                            style: new TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800])),
                        new Text("$tglAwal"),
                      ],
                    )),
                    new Divider(),
                    Container(
                        child: Column(
                      children: <Widget>[
                        new Text("Akhir",
                            style: new TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[800])),
                        new Text("$tglAkhir"),
                      ],
                    ))
                  ],
                ),
              ],
            ),
          ),
          SizedBox(height: 5.0),
          new Card(
            child: new Container(
              margin: const EdgeInsets.all(10.0),
              child: new Row(
                children: <Widget>[
                  new Expanded(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        new Text(
                          "Diupload pada $tglUpload",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        new Text(
                          deskripsiNya,
                          textAlign: TextAlign.justify,
                        ),
                        new Padding(
                          padding: const EdgeInsets.all(8.0),
                        ),
                        new Text(
                          "Requirement :",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Container(
                              height: 25.0,
                              color: Colors.transparent,
                              child: Requir(
                                req: requirementNya,
                              )),
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}
