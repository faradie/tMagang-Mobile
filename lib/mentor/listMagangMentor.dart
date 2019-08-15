import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

DateTime dateNow = DateTime.now();
final loadingLoad = CircularProgressIndicator(
  backgroundColor: Colors.deepOrange,
  strokeWidth: 1.5,
);
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

class Mentoring extends StatefulWidget {
  Mentoring({this.idMentor});
  final String idMentor;
  _MentoringState createState() => _MentoringState();
}

class _MentoringState extends State<Mentoring> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
                appBar: AppBar(
          elevation:
              defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
          backgroundColor: const Color(0xFFe87c55),
          title: new Text("Mentoring"),
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
                    .collection('registerIntern')
                    .where('status', isEqualTo: 'accepted')
                    .where('timeEndIntern', isGreaterThanOrEqualTo: dateNow)
                    .where('mentorId', isEqualTo: widget.idMentor)
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
                    .collection('registerIntern')
                    .where('status', isEqualTo: 'accepted')
                    .where('timeEndIntern', isGreaterThanOrEqualTo: dateNow)
                    .where("mentorId", isEqualTo: widget.idMentor)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData)
                    return new Text(
                      "Total mentoring aktif anda: 0",
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                          fontSize: 15.0),
                    );
                  return new Text(
                    "Total mentoring aktif anda: ${snapshot.data.documents.length.toString()}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: 15.0),
                  );
                },
              ),
              new Expanded(
                child: ListMentoring(
                  id: widget.idMentor,
                ),
              ),
            ],
          ),
        ));
  }
}

class ListMentoring extends StatefulWidget {
  ListMentoring({this.id});
  final String id;
  @override
  ListMentoringState createState() {
    return new ListMentoringState();
  }
}

class ListMentoringState extends State<ListMentoring> {
  DateTime dateNow = DateTime.now();
  IconData _icon;
  MaterialColor _colors;
  Future getLowongan() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore
        .collection('registerIntern')
        .where('status', isEqualTo: 'accepted')
        // .where('timeEndIntern', isGreaterThanOrEqualTo: dateNow)
        .where("mentorId", isEqualTo: widget.id)
        .getDocuments();

    return qn.documents;
  }

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
                  Timestamp _timeEndIntern =
                      snapshot.data[index].data["timeEndIntern"];
                  DateTime _valUntil = _timeEndIntern.toDate();
                  final difference = _valUntil.difference(dateNow).inHours;

                  if (difference > 0) {
                    _icon = Icons.check;
                    _colors = Colors.blue;
                  } else {
                    _icon = Icons.warning;
                    _colors = Colors.red;
                  }
                  return new TileLowongan(
                    idLowongan: snapshot.data[index].data["vacanciesId"],
                    no: (index + 1).toString(),
                    iconData: _icon,
                    warna: _colors,
                    timeEndIntern: _valUntil,
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
      {this.idLowongan,
      this.iconData,
      this.no,
      this.warna,
      this.timeEndIntern});
  final String no, idLowongan;
  final DateTime timeEndIntern;
  final IconData iconData;
  final MaterialColor warna;

  @override
  TileLowonganState createState() {
    return new TileLowonganState();
  }
}

class TileLowonganState extends State<TileLowongan> {
  String _namaLowongan, _timeEndIntern, _ownerAgency, _mentorId;

  Future getDataUser() async {
    _timeEndIntern = formatDate(widget.timeEndIntern, [
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
    var firestore = Firestore.instance;
    var userQuery = firestore
        .collection('vacancies')
        .where('id', isEqualTo: widget.idLowongan)
        .limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          _namaLowongan = data.documents[0].data['title'];
          _ownerAgency = data.documents[0].data['ownerAgency'];
          _mentorId = data.documents[0].data['mentorId'];
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
        new Divider(),
        new ListTile(
          onTap: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(
                builder: (BuildContext context) => new DetailMentoring(
                      judul: _namaLowongan,
                      idLowongan: widget.idLowongan,
                      idMentor: _mentorId,
                      owner: _ownerAgency,
                    )));
          },
          leading: new Text(
            widget.no,
            style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
          ),
          title: new Text(
            _namaLowongan == null ? "" : _namaLowongan,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: new Text(
              "Berakhir pada : ${_timeEndIntern == null ? "" : _timeEndIntern}"),
          trailing: new Icon(widget.iconData, color: widget.warna),
        ),
      ],
    ));
  }
}

class DetailMentoring extends StatefulWidget {
  DetailMentoring({this.judul, this.idLowongan, this.idMentor, this.owner});
  final String judul, idLowongan, owner, idMentor;
  _DetailMentoringState createState() => _DetailMentoringState();
}

class _DetailMentoringState extends State<DetailMentoring> {
  var _ratIntegritas = 0.0;
  var _ratKeahlian = 0.0;
  var _ratKomunikasi = 0.0;
  var _ratKerjasama = 0.0;
  var _ratPengembanganDiri = 0.0;
  var _ratPenggunaanTeknologi = 0.0;
  var _ratBahasaInggris = 0.0;

  //for needed
  List department,require;

  bool neededDone = true;

  bool tekanList = true;

  bool tekan = true;
  void _prosesKebutuhan() {
    setState(() {
      tekan = false;
    });
    DateTime dateNow = DateTime.now();
    Map<String, dynamic> data = <String, dynamic>{
      "vacanciesId": widget.idLowongan,
      "ratedAt": dateNow,
      "ownerAgency": widget.owner,
      "mentorId": widget.idMentor,
      "K1": _ratIntegritas,
      "K2": _ratKeahlian,
      "K3": _ratKomunikasi,
      "K4": _ratKerjasama,
      "K5": _ratPengembanganDiri,
      "K6": _ratPenggunaanTeknologi,
      "K7": _ratBahasaInggris,
      "department" : department,
      "requirement" : require
    };

    Firestore.instance
        .collection("internNeeded")
        .document("${widget.idLowongan}")
        .setData(data)
        .whenComplete(() {
      _showToast("Berhasil menentukan kebutuhan", Color(0xFFe87c55));

      setState(() {
        tekan = true;
        tekanList = true;
        this._ratIntegritas = 0.0;
        this._ratKeahlian = 0.0;
        this._ratKomunikasi = 0.0;
        this._ratKerjasama = 0.0;
        this._ratPengembanganDiri = 0.0;
        this._ratPenggunaanTeknologi = 0.0;
        this._ratBahasaInggris = 0.0;
      });
      Navigator.of(context).pop();
    }).catchError((e) {
      print(e.toString());
    });
  }

  void check() async {
    DocumentReference favoritesReference = Firestore.instance
        .collection('internNeeded')
        .document("${widget.idLowongan}");
    Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(favoritesReference);
      if (postSnapshot.exists) {
        await tx.get(favoritesReference).then((doc) {
          setState(() {
           this.neededDone =  true; 
          });
        });
      }else{
        setState(() {
         this.neededDone = false; 
        });
      }
    });
  }

  @override
  void initState() {
    super.initState();
    check();
  }

  var rating = 0.0;
  String _namaUser;
  var name;

  Future _getIntern() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore
        .collection('registerIntern')
        .where('status', isEqualTo: 'accepted')
        .where('vacanciesId', isEqualTo: widget.idLowongan)
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
      length: 3,
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
            title: new Text("Mentoring"),
            // actions: <Widget>[
            //   new FlatButton(
            //     child: new Icon(Icons.settings, color: Colors.white),
            //     onPressed: () {
            //       // Navigator.of(context).push(new MaterialPageRoute(
            //       //   builder: (BuildContext context) => new EditLowongan(
            //       //         idLowongan: widget.idLowongan,
            //       //       ),
            //       // ));
            //     },
            //   )
            // ],
            backgroundColor: const Color(0xFFe87c55),
            bottom: TabBar(
              unselectedLabelColor: Color(0xFFff9f7f),
              tabs: <Widget>[
                Tab(
                  child: new Text(
                    "Lowongan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Tab(
                  child: new Text(
                    "Pemagang",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Tab(
                  child: new Text(
                    "Kebutuhan",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
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
                    DateTime dateNow = DateTime.now();
                    Timestamp _validUntil = snapshot.data['expiredAt'];
                    DateTime _valUntil = _validUntil.toDate();
                    final selisih = _valUntil.difference(dateNow).inMinutes;
                    String expiredAt = formatDate(_valUntil, [
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
                    Timestamp _startIntern = snapshot.data['timeStartIntern'];
                    Timestamp _endIntern = snapshot.data['timeEndIntern'];
                    Timestamp _createtAt = snapshot.data['createdAt'];
                    String uploadPada = formatDate(_createtAt.toDate(), [
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

                    setState(() {
                     department =  snapshot.data['department'];
                     require = snapshot.data['requirement'];
                    });

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
                                                    selisih > 0
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
                                                    selisih > 0
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
                                      new Text(formatDate(_startIntern.toDate(),
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
                                      new Text(formatDate(_endIntern.toDate(),
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
                                        "Diupload pada $uploadPada",
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
                                        "Jurusan : ${snapshot.data['department']}",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      new StreamBuilder<DocumentSnapshot>(
                                          stream: Firestore.instance
                                              .collection('users')
                                              .document(
                                                  '${snapshot.data['mentorId']}')
                                              .snapshots(),
                                          builder: (BuildContext context,
                                              AsyncSnapshot<DocumentSnapshot>
                                                  snapshot) {
                                            if (snapshot.connectionState ==
                                                ConnectionState.waiting) {
                                              return Center(
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.max,
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
                                                'No Data Mentor...',
                                              );
                                            } else if (snapshot
                                                    .connectionState ==
                                                ConnectionState.active) {
                                              var name =
                                                  snapshot.data['data'] == null
                                                      ? ""
                                                      : snapshot.data['data'];
                                              return new Text(
                                                "Mentor : ${name['displayName'] == null ? "" : name['displayName']}",
                                                style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              );
                                            } else {
                                              return Text(
                                                'Mengambil data...',
                                              );
                                            }
                                          }),
                                      SizedBox(height: 10.0),
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
                  } else {
                    return Center(
                      child: new Text(
                        'Mengambil data...',
                      ),
                    );
                  }
                },
              ),
              //batas tabs 1 dan 2
              Container(
                child: new FutureBuilder(
                  future: _getIntern(),
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
                              return new TilePemagang(
                                owner: snapshot.data[index].data["ownerAgency"],
                                idMentor: snapshot.data[index].data["mentorId"],
                                idLowongan: widget.idLowongan,
                                collegeId:
                                    snapshot.data[index].data["collegeId"],
                                no: (index + 1).toString(),
                                idUser: snapshot.data[index].data["userId"],
                                endIntern:
                                    snapshot.data[index].data["timeEndIntern"],
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
              ),
              //tabs 3
              neededDone == false ?
              Container(
                width: 300.0,
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    new Text(
                      "Penentuan".toUpperCase(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    new Text(
                      "Kebutuhan",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    Container(
                      child: new ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 300.0),
                        child: new Scrollbar(
                          child: new SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              reverse: false,
                              child: new Column(
                                children: <Widget>[
                                  new Text("1. Kebutuhan Integritas "),
                                  new Container(
                                      child: RatingStarFull(
                                    color: Colors.red,
                                    rating: _ratIntegritas,
                                    starCount: 5,
                                    onRatingChanged: (v) {
                                      this._ratIntegritas = v;
                                    },
                                  )),
                                  new Divider(),
                                  new Text("2. Kebutuhan Keahlian"),
                                  new Container(
                                      child: RatingStarFull(
                                    color: Colors.red,
                                    rating: _ratKeahlian,
                                    starCount: 5,
                                    onRatingChanged: (v) {
                                      this._ratKeahlian = v;
                                    },
                                  )),
                                  new Divider(),
                                  new Text("3. Kebutuhan Komunikasi"),
                                  new Container(
                                      child: RatingStarFull(
                                    color: Colors.red,
                                    rating: _ratKomunikasi,
                                    starCount: 5,
                                    onRatingChanged: (v) {
                                      this._ratKomunikasi = v;
                                    },
                                  )),
                                  new Divider(),
                                  new Text("4. Kebutuhan Kerjasama"),
                                  new Container(
                                      child: RatingStarFull(
                                    color: Colors.red,
                                    rating: _ratKerjasama,
                                    starCount: 5,
                                    onRatingChanged: (v) {
                                      this._ratKerjasama = v;
                                    },
                                  )),
                                  new Divider(),
                                  new Text(
                                      "5. Kebutuhan dalam Pengembangan Diri"),
                                  new Container(
                                      child: RatingStarFull(
                                    color: Colors.red,
                                    rating: _ratPengembanganDiri,
                                    starCount: 5,
                                    onRatingChanged: (v) {
                                      this._ratPengembanganDiri = v;
                                    },
                                  )),
                                  new Divider(),
                                  new Text("6. Kebutuhan Penggunaan Teknologi"),
                                  new Container(
                                      child: RatingStarFull(
                                    color: Colors.red,
                                    rating: _ratPenggunaanTeknologi,
                                    starCount: 5,
                                    onRatingChanged: (v) {
                                      this._ratPenggunaanTeknologi = v;
                                    },
                                  )),
                                  new Divider(),
                                  new Text(
                                      "7. Kebutuhan Penguasaan Bahasa Inggris"),
                                  new Container(
                                      child: RatingStarFull(
                                    color: Colors.red,
                                    rating: _ratBahasaInggris,
                                    starCount: 5,
                                    onRatingChanged: (v) {
                                      this._ratBahasaInggris = v;
                                    },
                                  )),
                                  new Divider(),
                                ],
                              )),
                        ),
                      ),
                    ),
                    SizedBox(height: 16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        ButtonTheme(
                          height: 50.0,
                          child: new RaisedButton(
                            color: const Color(0xFFff9977),
                            elevation: 4.0,
                            splashColor: Colors.blueGrey,
                            onPressed: () {
                              setState(() {
                                this._ratIntegritas = 0.0;
                                this._ratKeahlian = 0.0;
                                this._ratKomunikasi = 0.0;
                                this._ratKerjasama = 0.0;
                                this._ratPengembanganDiri = 0.0;
                                this._ratPenggunaanTeknologi = 0.0;
                                this._ratBahasaInggris = 0.0;
                                tekanList = true;
                              });

                              Navigator.of(context).pop();
                            },
                            padding: const EdgeInsets.only(),
                            child: new Text(
                              'Batal'.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                            ),
                          ),
                        ),
                        ButtonTheme(
                          height: 50.0,
                          child: new RaisedButton(
                            color: const Color(0xFFff9977),
                            elevation: 4.0,
                            splashColor: Colors.blueGrey,
                            onPressed: tekan == true ? _prosesKebutuhan : null,
                            padding: const EdgeInsets.only(),
                            child: new Text(
                              'Nilai'.toUpperCase(),
                              style: TextStyle(
                                  fontSize: 15.0, color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ):
              Center(
                child: new Text("Penentuan telah usai"),
              ),
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

class RatingStarFull extends StatefulWidget {
  final int starCount;
  final double rating;
  final RatingChangeCallback onRatingChanged;
  final Color color;

  RatingStarFull(
      {this.starCount, this.rating, this.onRatingChanged, this.color});

  @override
  State<StatefulWidget> createState() {
    return _RatingStarState(starCount, rating, onRatingChanged, color);
  }
}

class _RatingStarState extends State<RatingStarFull> {
  final int starCount;
  double rating;
  final RatingChangeCallback onRatingChanged;
  final Color color;

  _RatingStarState(
      this.starCount, this.rating, this.onRatingChanged, this.color);

  Widget buildStar(BuildContext context, int index) {
    Icon icon;
    if (index >= rating) {
      icon = new Icon(
        Icons.star_border,
        color: Colors.orange,
        size: 40.0,
      );
    } else if (index > rating - 1 && index < rating) {
      icon = new Icon(
        Icons.star_half,
        color: color ?? Theme.of(context).primaryColor,
        size: 30.0,
      );
    } else {
      icon = new Icon(
        Icons.star,
        color: color ?? Theme.of(context).primaryColor,
        size: 30.0,
      );
    }
    return new GestureDetector(
      onTap: onRatingChanged == null
          ? null
          : () {
              onRatingChanged(index + 1.0);
              setState(() {
                this.rating = index + 1.0;
              });
            },
      child: icon,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children:
            new List.generate(starCount, (index) => buildStar(context, index)));
  }
}

class TilePemagang extends StatefulWidget {
  TilePemagang(
      {this.idUser,
      this.no,
      this.idLowongan,
      this.endIntern,
      this.collegeId,
      this.idMentor,
      this.owner});
  final String idUser, no, idLowongan, idMentor, owner, collegeId;
  final Timestamp endIntern;
  _TilePemagangState createState() => _TilePemagangState();
}

class _TilePemagangState extends State<TilePemagang> {
  DateTime _endMagang;
  DateTime dateNow = DateTime.now();
  var name, mapKampus;
  bool penerimaan = false;

  bool tekanList = true;
  String _namaUser, _kampus;
  var _ratIntegritas = 0.0;
  var _ratKeahlian = 0.0;
  var _ratKomunikasi = 0.0;
  var _ratKerjasama = 0.0;
  var _ratPengembanganDiri = 0.0;
  var _ratPenggunaanTeknologi = 0.0;
  var _ratBahasaInggris = 0.0;

  bool tekan = true;
  void _prosesNilai() {
    setState(() {
      tekan = false;
    });
    String _idPenilaianIntern = "${widget.idLowongan}_${widget.idUser}";

    DateTime dateNow = DateTime.now();
    Map<String, dynamic> data = <String, dynamic>{
      "userId": widget.idUser,
      "vacanciesId": widget.idLowongan,
      "ratedAt": dateNow,
      "ownerAgency": widget.owner,
      "mentorId": widget.idMentor,
      "collegeId": widget.collegeId,
      "KP1": _ratIntegritas,
      "KP2": _ratKeahlian,
      "KP3": _ratKomunikasi,
      "KP4": _ratKerjasama,
      "KP5": _ratPengembanganDiri,
      "KP6": _ratPenggunaanTeknologi,
      "KP7": _ratBahasaInggris
    };

    Firestore.instance
        .collection("reportIntern")
        .document("$_idPenilaianIntern")
        .setData(data)
        .whenComplete(() {
      Map<String, dynamic> data2 = <String, dynamic>{"inIntern": false};
      Firestore.instance
          .collection("users")
          .document("${widget.idUser}")
          .updateData(data2)
          .whenComplete(() {})
          .catchError((e) {
        print(e);
      });
      _showToast("Berhasil Menilai", Color(0xFFe87c55));

      setState(() {
        tekan = true;
        tekanList = true;
        this._ratIntegritas = 0.0;
        this._ratKeahlian = 0.0;
        this._ratKomunikasi = 0.0;
        this._ratKerjasama = 0.0;
        this._ratPengembanganDiri = 0.0;
        this._ratPenggunaanTeknologi = 0.0;
        this._ratBahasaInggris = 0.0;
      });
      Navigator.of(context).pop();
    }).catchError((e) {
      print(e.toString());
    });
  }

  Future getDataUser() async {
    _endMagang = widget.endIntern.toDate();
    var selisih = dateNow.difference(_endMagang).inMinutes;
    if (selisih <= 0) {
      penerimaan = false;
    } else {
      penerimaan = true;
    }
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

          // _statusUser = data.documents[0].data['isActive'];
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

  void showDialogPenilaian(BuildContext context, String nama) async {
    DocumentReference favoritesReference = Firestore.instance
        .collection('reportIntern')
        .document("${widget.idLowongan}_${widget.idUser}");
    Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(favoritesReference);
      if (postSnapshot.exists) {
        await tx.get(favoritesReference).then((doc) {
          this._ratIntegritas = doc.data["KP1"];
          this._ratKeahlian = doc.data["KP2"];
          this._ratKomunikasi = doc.data["KP3"];
          this._ratKerjasama = doc.data["KP4"];
          this._ratPengembanganDiri = doc.data["KP5"];
          this._ratPenggunaanTeknologi = doc.data["KP6"];
          this._ratBahasaInggris = doc.data["KP7"];
        });
      }
    }).whenComplete(() {
      showDialog(
          barrierDismissible: false,
          context: context,
          builder: (context) => new AlertDialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(32.0))),
                contentPadding: EdgeInsets.only(top: 10.0),
                content: Container(
                  width: 300.0,
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      new Text(
                        "Penilaian".toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      new Text(
                        nama == null ? "Mengambil data" : nama.toUpperCase(),
                        textAlign: TextAlign.center,
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 16.0),
                      Container(
                        child: new ConstrainedBox(
                          constraints: BoxConstraints(maxHeight: 300.0),
                          child: new Scrollbar(
                            child: new SingleChildScrollView(
                                scrollDirection: Axis.vertical,
                                reverse: false,
                                child: new Column(
                                  children: <Widget>[
                                    new Text(
                                        "1. Bagaimana dengan Integritasnya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratIntegritas,
                                      starCount: 4,
                                      onRatingChanged: (v) {
                                        this._ratIntegritas = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "2. Bagaimana dengan keahlian berdasarkan bidang ilmu?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratKeahlian,
                                      starCount: 4,
                                      onRatingChanged: (v) {
                                        this._ratKeahlian = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "3. Bagaimana dengan Komunikasinya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratKomunikasi,
                                      starCount: 4,
                                      onRatingChanged: (v) {
                                        this._ratKomunikasi = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "4. Bagaimana dengan Kerjasamanya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratKerjasama,
                                      starCount: 4,
                                      onRatingChanged: (v) {
                                        this._ratKerjasama = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "5. Bagaimana dengan pengembangan dirinya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratPengembanganDiri,
                                      starCount: 4,
                                      onRatingChanged: (v) {
                                        this._ratPengembanganDiri = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "6. Bagaimana dengan penggunaan teknologinya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratPenggunaanTeknologi,
                                      starCount: 4,
                                      onRatingChanged: (v) {
                                        this._ratPenggunaanTeknologi = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "7. Bagaimana dengan Bahasa Inggrisnya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratBahasaInggris,
                                      starCount: 4,
                                      onRatingChanged: (v) {
                                        this._ratBahasaInggris = v;
                                      },
                                    )),
                                    new Divider(),
                                  ],
                                )),
                          ),
                        ),
                      ),
                      SizedBox(height: 16.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          ButtonTheme(
                            height: 50.0,
                            child: new RaisedButton(
                              color: const Color(0xFFff9977),
                              elevation: 4.0,
                              splashColor: Colors.blueGrey,
                              onPressed: () {
                                setState(() {
                                  this._ratIntegritas = 0.0;
                                  this._ratKeahlian = 0.0;
                                  this._ratKomunikasi = 0.0;
                                  this._ratKerjasama = 0.0;
                                  this._ratPengembanganDiri = 0.0;
                                  this._ratPenggunaanTeknologi = 0.0;
                                  this._ratBahasaInggris = 0.0;
                                  tekanList = true;
                                });

                                Navigator.of(context).pop();
                              },
                              padding: const EdgeInsets.only(),
                              child: new Text(
                                'Batal'.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.white),
                              ),
                            ),
                          ),
                          ButtonTheme(
                            height: 50.0,
                            child: new RaisedButton(
                              color: const Color(0xFFff9977),
                              elevation: 4.0,
                              splashColor: Colors.blueGrey,
                              onPressed: tekan == true ? _prosesNilai : null,
                              padding: const EdgeInsets.only(),
                              child: new Text(
                                'Nilai'.toUpperCase(),
                                style: TextStyle(
                                    fontSize: 15.0, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ));
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
        margin: const EdgeInsets.only(top: 10.0),
        child: new Column(
          children: <Widget>[
            new ListTile(
              onTap: () {
                if (tekanList == true) {
                  if (penerimaan == false) {
                    _showToast("Belum saatnya penilaian", Colors.red);
                  } else {
                    setState(() {
                      tekanList = false;
                    });

                    showDialogPenilaian(context, _namaUser);
                  }
                } else {}
              },
              leading: new Text(
                widget.no,
                style: TextStyle(fontSize: 15.0, fontWeight: FontWeight.bold),
              ),
              title: new Text(
                _namaUser == null ? "" : _namaUser,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: new Text("Kampus : ${_kampus == null ? "" : _kampus}"),
            ),
            new Divider(),
          ],
        ));
  }
}
