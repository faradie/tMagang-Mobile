import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tempat_magang/auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:tempat_magang/global_page/bantuan.dart';
import 'package:tempat_magang/instansi_page/instansiOrCollegeProfil.dart';
import 'package:tempat_magang/instansi_page/instansi_buat_lowongan.dart';
import 'package:tempat_magang/instansi_page/manajemenLowonganInstansi.dart';
import 'package:tempat_magang/instansi_page/manajemenMentor.dart';
import 'package:tempat_magang/instansi_page/riwayatMagang.dart';

MobileAdTargetingInfo targetingInfo = new MobileAdTargetingInfo(
    testDevices: <String>[],
    keywords: <String>[
      'magang',
      'kampus',
      'industri',
      'lowongan',
      'kerja',
      'pendidikan',
      'kompetensi'
    ],
    birthday: DateTime.now(),
    gender: MobileAdGender.unknown,
    childDirected: false,
    nonPersonalizedAds: false,
    designedForFamilies: true);

BannerAd _bannerAd;

BannerAd createBannerAd() {
  return new BannerAd(
      adUnitId: "ca-app-pub-9631895364890043/4234048230",
      targetingInfo: targetingInfo,
      size: AdSize.smartBanner,
      listener: (MobileAdEvent event) {
        print("Agency banner ad $event");
      });
}

class InstansiDashboard extends StatefulWidget {
  InstansiDashboard({this.auth, this.onSignedOut, this.wew});
  final BaseAuth auth;
  final VoidCallback onSignedOut;
  final String wew;
  @override
  _InstansiDashboardState createState() => _InstansiDashboardState();
}

class _InstansiDashboardState extends State<InstansiDashboard> {
  _MySearchDelegate _delegate;
  final List<String> lowonganNya;
  String _namaUser, _statusUser, _idUser;
  var name;

  List<String> wew = ['wew', 'wsadas'];
  _InstansiDashboardState()
      : lowonganNya = ['asdasd', 'asdwerwe', 'asdaswww']..sort(
            (w1, w2) => w1.toLowerCase().compareTo(w2.toLowerCase()),
          ),
        super();

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

  setNamanya() {
    if (_namaUser == null) {
      return new Text("Nama belum diatur");
    }
  }

  @override
  void initState() {
    FirebaseAdMob.instance
        .initialize(appId: "ca-app-pub-9631895364890043~3439447130");
    _bannerAd = createBannerAd()
      ..load()
      ..show();
    super.initState();
    getDataUser();
    _delegate = _MySearchDelegate(lowonganNya);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: Container(
          height: 50.0,
          color: Colors.white,
        ),
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
                    name = snapshot.data['data'] as Map<dynamic, dynamic>;
                    return new UserAccountsDrawerHeader(
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
                      currentAccountPicture: name["photoURL"] == null
                          ? new CircleAvatar(
                              backgroundColor: Colors.white,
                              child: new Text("T",
                                  style: TextStyle(fontSize: 25.0)))
                          : name["photoURL"] == ""
                              ? new CircleAvatar(
                                  backgroundColor: Colors.white,
                                  child: new Text("T",
                                      style: TextStyle(fontSize: 25.0)))
                              : new CircleAvatar(
                                  backgroundImage:
                                      NetworkImage(name["photoURL"])),
                    );
                  }
                }),
            new ListTile(
              title: new Text("Buat lowongan"),
              trailing: new Icon(Icons.plus_one),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(
                    builder: (BuildContext context) => new InstansiBuatLowongan(
                          id: _idUser,
                        )));
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
              title: new Text("Manajemen mentor"),
              trailing: new Icon(Icons.person_outline),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(
                    builder: (BuildContext context) => new ManajemenMentor(
                          id: _idUser,
                        )));
              },
            ),
            new ListTile(
              title: new Text("Riwayat Magang"),
              trailing: new Icon(Icons.timeline),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(
                  context,
                ).push(MaterialPageRoute(
                    builder: (BuildContext context) => new RiwayatMagang(
                          id: _idUser,
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
                    builder: (BuildContext context) =>
                        new InstansiOrCollegeProfil(id: _idUser)));
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
                        // new IconButton(
                        //   tooltip: 'Cari',
                        //   icon: Icon(Icons.search),
                        //   onPressed: () async {
                        //     final String slected = await showSearch<String>(
                        //       context: context,
                        //       delegate: _delegate,
                        //     );
                        //   },
                        // )
                        new FlatButton(
                          child: new Icon(
                            Icons.plus_one,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            Navigator.of(
                              context,
                            ).push(MaterialPageRoute(
                                builder: (BuildContext context) =>
                                    new InstansiBuatLowongan(
                                      id: _idUser,
                                    )));
                          },
                        ),
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

class _MySearchDelegate extends SearchDelegate<String> {
  final List<String> _words;
  final List<String> _history;

  _MySearchDelegate(List<String> words)
      : _words = words,
        _history = <String>['wew', 'wew'],
        super();

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      tooltip: 'Kembali',
      icon: AnimatedIcon(
        icon: AnimatedIcons.menu_arrow,
        progress: transitionAnimation,
      ),
      onPressed: () {
        this.close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text("kau memilih : "),
            GestureDetector(
              onTap: () {
                this.close(context, this.query);
              },
              child: Text(
                this.query,
                style: Theme.of(context)
                    .textTheme
                    .display1
                    .copyWith(fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    final Iterable<String> suggestions = this.query.isEmpty
        ? _history
        : _words.where((word) => word.startsWith(query));

    return _SugestionList(
      query: this.query,
      onSelected: (String suggestion) {
        this.query = suggestion;
        this._history.insert(0, suggestion);
        showResults(context);
      },
      suggestions: suggestions.toList(),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) {
    return <Widget>[
      query.isEmpty
          ? IconButton(
              tooltip: 'Voice Search',
              icon: const Icon(Icons.mic),
              onPressed: () {
                this.query = 'TODO VOICE INPUT';
              },
            )
          : IconButton(
              tooltip: 'Clear',
              icon: const Icon(Icons.clear),
              onPressed: () {
                query = '';
                showSuggestions(context);
              },
            )
    ];
  }
}

class _SugestionList extends StatelessWidget {
  const _SugestionList({this.suggestions, this.query, this.onSelected});
  final List<String> suggestions;
  final String query;
  final ValueChanged<String> onSelected;
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme.subhead;
    return ListView.builder(
      itemCount: suggestions.length,
      itemBuilder: (BuildContext context, int i) {
        final String suggestion = suggestions[i];
        return ListTile(
          leading: query.isEmpty ? Icon(Icons.history) : Icon(null),
          title: RichText(
            text: TextSpan(
                text: suggestion.substring(0, query.length),
                style: textTheme.copyWith(fontWeight: FontWeight.bold),
                children: <TextSpan>[
                  TextSpan(
                      text: suggestion.substring(query.length),
                      style: textTheme)
                ]),
          ),
          onTap: () {
            onSelected(suggestion);
          },
        );
      },
    );
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
  String _judulLowongan, _idMentor, _namaMentor;
  var _name;
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
          _idMentor = data.documents[0].data['mentorId'];
        });
        var mentorQuery = firestore
            .collection('users')
            .where('uid', isEqualTo: _idMentor)
            .limit(1);
        mentorQuery.getDocuments().then((record) {
          if (data.documents.length > 0) {
            setState(() {
              _name = record.documents[0].data['data'];
              _namaMentor = _name['displayName'];
            });
          }
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
  void dispose() {
    super.dispose();
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
          subtitle: new Text(
              "Mentor : ${_namaMentor == null ? "Mengambil Mentor" : _namaMentor}"),
          // trailing: new Icon(widget.iconData, color: widget.warna),
        ),
        new Divider(),
      ],
    ));
  }
}
