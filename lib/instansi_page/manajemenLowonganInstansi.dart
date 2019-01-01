import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tempat_magang/user_page/internprofil.dart';

class ManajemenLowonganInstansi extends StatefulWidget {
  ManajemenLowonganInstansi({this.idAgency});
  final String idAgency;
  _ManajemenLowonganInstansiState createState() =>
      _ManajemenLowonganInstansiState();
}

class _ManajemenLowonganInstansiState extends State<ManajemenLowonganInstansi> {
  DateTime dateNow = DateTime.now();
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          elevation:
              defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
          backgroundColor: const Color(0xFFe87c55),
          title: new Text("Data Lowongan"),
          leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: new Icon(
              Icons.chevron_left,
              color: Colors.white,
            ),
          ),
          actions: <Widget>[
            new FlatButton(
              child: StreamBuilder(
                stream: Firestore.instance
                    .collection('vacancies')
                    .where('ownerAgency', isEqualTo: widget.idAgency)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return new Text(
                      "0",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 25.0),
                    );
                  return new Text(
                    snapshot.data.documents.length.toString(),
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 25.0),
                  );
                },
              ),
              onPressed: null,
            )
          ],
        ),
        body: Container(
          margin: const EdgeInsets.only(top: 10.0, left: 10.0),
          child: new Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              StreamBuilder(
                stream: Firestore.instance
                    .collection('vacancies')
                    .where("expiredAt", isGreaterThanOrEqualTo: dateNow)
                    .where('ownerAgency', isEqualTo: widget.idAgency)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return new Text(
                      "Lowongan Aktif Anda: 0",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15.0),
                    );
                  return new Text(
                    "Lowongan Aktif Anda: ${snapshot.data.documents.length.toString()}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 15.0),
                  );
                },
              ),
              StreamBuilder(
                stream: Firestore.instance
                    .collection('vacancies')
                    .where("expiredAt", isLessThan: dateNow)
                    .where('ownerAgency', isEqualTo: widget.idAgency)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return new Text(
                      "Lowongan NonAktif Anda: 0",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15.0),
                    );
                  return new Text(
                    "Lowongan NonAktif Anda: ${snapshot.data.documents.length.toString()}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 15.0),
                  );
                },
              ),
              new Expanded(
                child: ListLowongan(
                  id: widget.idAgency,
                ),
              ),
            ],
          ),
        ));
  }
}

class ListLowongan extends StatefulWidget {
  ListLowongan({this.id});
  final String id;
  @override
  ListLowonganState createState() {
    return new ListLowonganState();
  }
}

class ListLowonganState extends State<ListLowongan> {
  DateTime dateNow = DateTime.now();
  IconData _icon;
  MaterialColor _colors;
  Future getLowongan() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore
        .collection('vacancies')
        .where('ownerAgency', isEqualTo: widget.id)
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
              return new Center(
                child: new Text("Belum ada lowongan"),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, index) {
                  DateTime _validUntil = snapshot.data[index].data["expiredAt"];
                  final difference = dateNow.difference(_validUntil).inDays;
                  if (difference >= 0) {
                    _icon = Icons.warning;
                    _colors = Colors.red;
                  } else {
                    _icon = Icons.check;
                    _colors = Colors.blue;
                  }
                  return new TileLowongan(
                    idLowongan: snapshot.data[index].data["id"],
                    no: (index + 1).toString(),
                    judul: snapshot.data[index].data["title"],
                    created: snapshot.data[index].data["createdAt"],
                    iconData: _icon,
                    warna: _colors,
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

class TileLowongan extends StatefulWidget {
  TileLowongan(
      {this.judul,
      this.created,
      this.idLowongan,
      this.iconData,
      this.no,
      this.warna});
  final String judul, no, idLowongan;
  final DateTime created;
  final IconData iconData;
  final MaterialColor warna;

  @override
  TileLowonganState createState() {
    return new TileLowonganState();
  }
}

class TileLowonganState extends State<TileLowongan> {
  var name;
  @override
  Widget build(BuildContext context) {
    return new Container(
        child: new Column(
      children: <Widget>[
        new Divider(),
        new ListTile(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(
                builder: (BuildContext context) => new DetailLowonganInstansi(
                      judul: widget.judul,
                      idLowongan: widget.idLowongan,
                    )));
          },
          leading: new Text(
            widget.no,
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
          title: new Text(
            widget.judul == null ? "" : widget.judul,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: new Text(
              "Dibuat pada : ${widget.created == null ? "" : widget.created}"),
          trailing: new Icon(widget.iconData, color: widget.warna),
        ),
      ],
    ));
  }
}

class DetailLowonganInstansi extends StatefulWidget {
  DetailLowonganInstansi({this.judul, this.idLowongan});

  final String judul, idLowongan;
  _DetailLowonganInstansiState createState() => _DetailLowonganInstansiState();
}

class _DetailLowonganInstansiState extends State<DetailLowonganInstansi> {
  String _userId, _namaUser;
  var name;
  final loadingLoad = CircularProgressIndicator(
    backgroundColor: Colors.deepOrange,
    strokeWidth: 1.5,
  );
  Future _getLowonganSaya() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore
        .collection('registerIntern')
        .where('vacanciesId', isEqualTo: widget.idLowongan)
        .where('status', isEqualTo: true)
        .getDocuments();

    return qn.documents;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return DefaultTabController(
      length: 2,
      child: new Scaffold(
          appBar: AppBar(
            elevation:
                defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
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
            bottom: TabBar(
              tabs: <Widget>[
                Tab(
                  text: "Lowongan",
                ),
                Tab(
                  text: "Pendaftar",
                ),
              ],
            ),
          ),
          body: new TabBarView(
            children: <Widget>[
              new StreamBuilder<DocumentSnapshot>(
                stream: Firestore.instance
                    .collection('vacancies')
                    .document('${widget.idLowongan}')
                    .snapshots(),
                builder: (BuildContext context,
                    AsyncSnapshot<DocumentSnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[loadingLoad, Text("Loading Data..")],
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return Center(
                        child: new Text("Yah.. ada yang salah nih.."));
                  } else if (!snapshot.hasData) {
                    return Text(
                      'No Data...',
                    );
                  } else if (snapshot.connectionState ==
                      ConnectionState.active) {
                    FirebaseAuth.instance.currentUser().then((user) {
                      _userId = user.uid;
                    });

                    DateTime dateNow = DateTime.now();
                    DateTime _validUntil = snapshot.data['expiredAt'];
                    final selisih = dateNow.difference(_validUntil).inDays;
                    String expiredAt = formatDate(_validUntil, [
                      dd,
                      ' ',
                      MM,
                      ' ',
                      yyyy,
                      ' - ',
                      HH,
                      ':',
                      nn,
                    ]);
                    return new ListView(
                      children: <Widget>[
                        new Card(
                          color: Colors.white,
                          child: new Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Expanded(
                                child: new Container(
                                  child: Padding(
                                    padding: const EdgeInsets.all(5.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: <Widget>[
                                        new Text("${widget.judul}",
                                            style: new TextStyle(
                                                fontSize: 15.0,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.grey[800])),
                                        new Text(
                                            "Kuota ${snapshot.data['quota']}"),
                                        Padding(
                                          padding: const EdgeInsets.all(5.0),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Expanded(
                                              child: ButtonTheme(
                                                minWidth: 200.0,
                                                height: 40.0,
                                                child: new RaisedButton(
                                                  onPressed: null,
                                                  color:
                                                      const Color(0xFFff9977),
                                                  elevation: 4.0,
                                                  splashColor: Colors.blueGrey,
                                                  child: new Text(
                                                    selisih < 0
                                                        ? "Status Lowongan Aktif"
                                                        : "Status Lowongan Expired",
                                                    style: TextStyle(
                                                        color: Colors.white),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.max,
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceEvenly,
                                          children: <Widget>[
                                            Expanded(
                                              child: ButtonTheme(
                                                minWidth: 200.0,
                                                height: 40.0,
                                                child: new RaisedButton(
                                                  onPressed: null,
                                                  color:
                                                      const Color(0xFFff9977),
                                                  elevation: 4.0,
                                                  splashColor: Colors.blueGrey,
                                                  child: new Text(
                                                    selisih <= 0
                                                        ? "Sampai $expiredAt"
                                                        : "Pada $expiredAt",
                                                    style: TextStyle(
                                                        color: Colors.white),
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
                              border: new Border.all(
                                  color: const Color(0xFFe87c55), width: 1.0),
                              borderRadius:
                                  new BorderRadius.all(Radius.circular(20.0))),
                          margin: const EdgeInsets.only(left: 5.0, right: 5.0),
                          padding:
                              const EdgeInsets.only(top: 10.0, bottom: 10.0),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  new Text(
                                    "Periode".toUpperCase(),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  )
                                ],
                              ),
                              SizedBox(height: 16.0),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: <Widget>[
                                  Container(
                                      child: Column(
                                    children: <Widget>[
                                      new Text("Mulai",
                                          style: new TextStyle(
                                              fontSize: 15.0,
                                              fontWeight: FontWeight.bold,
                                              color: Colors.grey[800])),
                                      new Text(formatDate(
                                          snapshot.data['timeStartIntern'],
                                          [dd, ' ', MM, ' ', yyyy])),
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
                                      new Text(formatDate(
                                          snapshot.data['timeEndIntern'],
                                          [dd, ' ', MM, ' ', yyyy])),
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      new Text(
                                        "Diupload pada ${snapshot.data['createdAt']}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      new Text(
                                        "${snapshot.data['description']}",
                                        textAlign: TextAlign.justify,
                                      ),
                                      new Padding(
                                        padding: const EdgeInsets.all(8.0),
                                      ),
                                      new Text(
                                        "Jurusan : ${snapshot.data['departement']}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(height: 10.0),
                                      new Text(
                                        "Requirement :",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      Container(
                                        padding:
                                            const EdgeInsets.only(top: 8.0),
                                        child: Container(
                                            height: 25.0,
                                            color: Colors.transparent,
                                            child: Requir(
                                              req: List.from(
                                                  snapshot.data['requirement']),
                                            )),
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  }
                },
              ),
              //batas tabs
              Container(
                child: new FutureBuilder(
                  future: _getLowonganSaya(),
                  builder: (_, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(
                        child: Text("Mengambil Data.."),
                      );
                    } else {
                      if (snapshot.data.length > 0) {
                        return ListView.builder(
                            itemCount: snapshot.data.length,
                            itemBuilder: (_, index) {
                              return new TilePendaftar(
                                idLowongan: widget.idLowongan,
                                no: (index + 1).toString(),
                                idUser: snapshot.data[index].data["userId"],
                              );
                            });
                      } else {
                        return new Center(
                          child: new Text("Belum ada pendaftar"),
                        );
                      }
                    }
                  },
                ),
              )
            ],
          )),
    );
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

class TilePendaftar extends StatefulWidget {
  TilePendaftar({this.idUser, this.no, this.idLowongan});
  final String idUser, no, idLowongan;
  _TilePendaftarState createState() => _TilePendaftarState();
}

class _TilePendaftarState extends State<TilePendaftar> {
  String _namaUser, _kampus, _owner;
  DateTime _timeEndIntern, _timeStartIntern, _expiredAt;
  bool _statusUser;
  var name, mapKampus;
  bool tekan = true;
  bool penerimaan = false;

  void _showToast(String pesan, Color warna) {
    Fluttertoast.showToast(
      msg: pesan,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: warna,
      textColor: Colors.white,
    );
  }

  void cobaTolak() {}

  void _isPressed() {
    setState(() {
      tekan = false;
    });
    String _idInternship = "${widget.idLowongan}_${widget.idUser}";

    DateTime dateNow = DateTime.now();
    Map<String, dynamic> data = <String, dynamic>{
      "userId": widget.idUser,
      "vacanciesId": widget.idLowongan,
      "acceptedAt": dateNow,
      "timeStartIntern": _timeStartIntern,
      "timeEndIntern": _timeEndIntern,
      "ownerAgency": _owner,
      "mentorId": ""
    };

    Map<String, dynamic> user = <String, dynamic>{"isActive": true};

    Firestore.instance
        .collection("users")
        .document("${widget.idUser}")
        .updateData(user)
        .whenComplete(() {
      Firestore.instance
          .collection("internship")
          .document("$_idInternship")
          .setData(data)
          .whenComplete(() {
        _showToast("Berhasil Menerima", Color(0xFFe87c55));
      }).catchError((e) {
        print(e);
      });
    }).catchError((e) {
      print(e);
    });

//proses mencari registerId
    Firestore.instance
        .collection("registerIntern")
        .where("userId", isEqualTo: widget.idUser)
        .getDocuments()
        .then((data) {
      data.documents.forEach((doc) {
        //update masing-masing status false di register dari for each doc
        Map<String, dynamic> statFalse = <String, dynamic>{"status": false};
        String docID = "${doc.data["userId"]}_${doc.data["vacanciesId"]}";
        print("wew $docID");
        Firestore.instance
            .collection("registerIntern")
            .document("$docID")
            .updateData(statFalse)
            .whenComplete(() {
          print("donechange");
        }).catchError((e) {
          print(e.toString());
        });
      });
    });
  }

  Future getStatus() async {
    DateTime dateNow = DateTime.now();

    var firestore = Firestore.instance;
    var userQuery = firestore
        .collection('vacancies')
        .where('id', isEqualTo: widget.idLowongan)
        .limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          _timeEndIntern = data.documents[0].data['timeEndIntern'];
          _timeStartIntern = data.documents[0].data['timeStartIntern'];
          _owner = data.documents[0].data['ownerAgency'];
          _expiredAt = data.documents[0].data['expiredAt'];
          var selisih = dateNow.difference(_expiredAt).inDays;
          if (selisih <= 0) {
            penerimaan = false;
          } else {
            penerimaan = true;
          }
        });

        var collegeQuery = firestore
            .collection('users')
            .where('uid', isEqualTo: name["collegeId"])
            .limit(1);

        collegeQuery.getDocuments().then((collegeData) {
          if (collegeData.documents.length > 0) {
            setState(() {
              mapKampus = collegeData.documents[0].data['data']
                  as Map<dynamic, dynamic>;
              _kampus = mapKampus["displayName"];
            });
          }
        });
      }
    });
  }

  Future getDataUser() async {
    var firestore = Firestore.instance;
    var userQuery = firestore
        .collection('users')
        .where('uid', isEqualTo: widget.idUser)
        .limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          name = data.documents[0].data['data'] as Map<dynamic, dynamic>;
          _namaUser = name["displayName"];
          _statusUser = data.documents[0].data['isActive'];
        });

        var collegeQuery = firestore
            .collection('users')
            .where('uid', isEqualTo: name["collegeId"])
            .limit(1);

        collegeQuery.getDocuments().then((collegeData) {
          if (collegeData.documents.length > 0) {
            setState(() {
              mapKampus = collegeData.documents[0].data['data']
                  as Map<dynamic, dynamic>;
              _kampus = mapKampus["displayName"];
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
    getStatus();
  }

  static const menuItems = <String>[
    'Terima',
    'Tolak',
  ];

  String _selectVal;

  final List<PopupMenuItem<String>> _popUpTerimaItem = menuItems
      .map((String value) => PopupMenuItem<String>(
            child: Text(value),
            value: value,
          ))
      .toList();

  @override
  Widget build(BuildContext context) {
    return new Container(
        margin: const EdgeInsets.only(top: 10.0),
        child: new Column(
          children: <Widget>[
            new ListTile(
                onTap: () {
                  Navigator.of(
                    context,
                  ).push(MaterialPageRoute(
                      builder: (BuildContext context) => new InternProfil(
                            id: widget.idUser,
                          )));
                },
                leading: new Text(
                  widget.no,
                  style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
                ),
                title: new Text(
                  _namaUser == null ? "" : _namaUser,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle:
                    new Text("Kampus : ${_kampus == null ? "" : _kampus}"),
                trailing: penerimaan == false
                    ? new Text("")
                    : new PopupMenuButton<String>(
                        onSelected: (String newValue) {
                          _selectVal = newValue;
                          if (_selectVal == "Terima") {
                            if (penerimaan == false) {
                              _showToast("Belum saatnya", Colors.red);
                            } else {
                              _isPressed();
                            }
                          } else {
                            cobaTolak();
                          }
                        },
                        itemBuilder: (BuildContext context) => _popUpTerimaItem,
                      )),
            new Divider(),
          ],
        ));
  }
}