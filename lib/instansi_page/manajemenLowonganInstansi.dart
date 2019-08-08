import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:tempat_magang/instansi_page/editLowongan.dart';
import 'package:tempat_magang/user_page/internprofil.dart';

final loadingLoad = CircularProgressIndicator(
  backgroundColor: Colors.deepOrange,
  strokeWidth: 1.5,
);

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
        bottomNavigationBar: Container(
          height: 50.0,
          color: Colors.white,
        ),
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
                  Timestamp _validUntil =
                      snapshot.data[index].data["expiredAt"];
                  DateTime _valUntil = _validUntil.toDate();
                  final difference = _valUntil.difference(dateNow).inHours;

                  if (difference > 0) {
                    _icon = Icons.check;
                    _colors = Colors.blue;
                  } else {
                    _icon = Icons.warning;
                    _colors = Colors.red;
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
  final Timestamp created;
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
              "Dibuat pada : ${widget.created.toDate() == null ? "" : widget.created.toDate()}"),
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
  String _namaUser;
  var name;

  Future _getLowonganSaya() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore
        .collection('registerIntern')
        .where('vacanciesId', isEqualTo: widget.idLowongan)
        .where('status', isEqualTo: 'review')
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
          bottomNavigationBar: Container(
            height: 50.0,
            color: Colors.white,
          ),
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
            actions: <Widget>[
              new FlatButton(
                child: new Icon(Icons.settings, color: Colors.white),
                onPressed: () {
                  Navigator.of(context).push(new MaterialPageRoute(
                    builder: (BuildContext context) => new EditLowongan(
                      idLowongan: widget.idLowongan,
                    ),
                  ));
                },
              )
            ],
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
                    "Pendaftar",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Tab(
                  child: new Text(
                    "Rekomendasi",
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
                    print('ini cratedAt ${_createtAt.toDate()}');
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
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[loadingLoad, Text("Loading Data..")],
                      ),
                    );
                  }
                },
              ),
              //batas tabs 1 dan 2
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
              ),
              //akhir dari tab2
              Container(
                child: new Center(
                  child: new Text("Konten Rekomendasi. Comingsoon..."),
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
  String _namaUser, _kampus, _collegeId, _mentorID;
  Timestamp _timeEndInternStamp, _timeStartInternStamp, _expiredAtStamp;
  DateTime _timeEndIntern, _timeStartIntern, _expiredAt;

  var name, mapKampus;
  bool tekan = true;
  bool penerimaan = false;
  int _kuotaMax, _maxInternship;
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

  void _hasilTolak() {
    DateTime dateNow = DateTime.now();
    String _idRegist = "${widget.idUser}_${widget.idLowongan}";
    Map<String, dynamic> statsTolak = <String, dynamic>{
      "status": 'rejected',
      "rejectedAt": dateNow
    };
    Firestore.instance
        .collection("registerIntern")
        .document("$_idRegist")
        .updateData(statsTolak)
        .whenComplete(() {
      print("doneRejectChange");
    }).catchError((e) {
      print(e.toString());
    });
  }

  void _isPressed() {
    setState(() {
      tekan = false;
    });

    var firestore = Firestore.instance;
    var getMaxQuot = firestore
        .collection('vacancies')
        .where('id', isEqualTo: widget.idLowongan)
        .limit(1);

    getMaxQuot.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          _kuotaMax = data.documents[0].data['quota'];
        });

        var getMaxIntern = firestore
            .collection('registerIntern')
            .where('vacanciesId', isEqualTo: widget.idLowongan)
            .where('status', isEqualTo: 'accepted');

        getMaxIntern.getDocuments().then((data) {
          if (data.documents.length > 0) {
            setState(() {
              _maxInternship = data.documents.length;
            });
          }
        });
        print("Sebelum : $_maxInternship dan ini $_kuotaMax");
        if (_maxInternship == null) {
          _maxInternship = 0;
        }
        if (_maxInternship <= _kuotaMax) {
          if (_maxInternship == _kuotaMax) {
            print("Sama dengan : $_maxInternship dan ini $_kuotaMax");
            String _idInternship = "${widget.idUser}_${widget.idLowongan}";

            DateTime dateNow = DateTime.now();
            Map<String, dynamic> data = <String, dynamic>{
              // "userId": widget.idUser,
              // "vacanciesId": widget.idLowongan,
              "status": 'accepted',
              "acceptedAt": dateNow,
              "timeStartIntern": _timeStartIntern,
              "timeEndIntern": _timeEndIntern,
              // "ownerAgency": _owner,
              "mentorId": _mentorID,
              "collegeId": _collegeId
            };

            Map<String, dynamic> user = <String, dynamic>{"inIntern": true};

            Firestore.instance
                .collection("users")
                .document("${widget.idUser}")
                .updateData(user)
                .whenComplete(() {
              Firestore.instance
                  .collection("registerIntern")
                  .document("$_idInternship")
                  .updateData(data)
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
                .where('status', isEqualTo: 'review')
                .getDocuments()
                .then((data) {
              data.documents.forEach((doc) {
                //update masing-masing status rejected di register dari for each doc
                Map<String, dynamic> statFalse = <String, dynamic>{
                  "status": 'rejected',
                  "rejectedAt": dateNow
                };
                String docID =
                    "${doc.data["userId"]}_${doc.data["vacanciesId"]}";

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

//proses menggagalkan semua vacancies ketika sudah full kuota /  menolak semua
            Firestore.instance
                .collection("registerIntern")
                .where("vacanciesId", isEqualTo: widget.idLowongan)
                .getDocuments()
                .then((data) {
              data.documents.forEach((doc) {
                //update masing-masing status false di register dari for each doc
                Map<String, dynamic> statusFalse = <String, dynamic>{
                  "status": 'rejected',
                  "rejectedAt": dateNow
                };
                String docsID =
                    "${doc.data["userId"]}_${doc.data["vacanciesId"]}";

                Firestore.instance
                    .collection("registerIntern")
                    .document("$docsID")
                    .updateData(statusFalse)
                    .whenComplete(() {
                  print("done gagalin semua");
                }).catchError((e) {
                  print(e.toString());
                });
              });
            });
          } else {
            String _idInternship = "${widget.idUser}_${widget.idLowongan}";

            DateTime dateNow = DateTime.now();
            Map<String, dynamic> data = <String, dynamic>{
              // "userId": widget.idUser,
              // "vacanciesId": widget.idLowongan,
              "acceptedAt": dateNow,
              "status": 'accepted',
              "timeStartIntern": _timeStartIntern,
              "timeEndIntern": _timeEndIntern,
              // "ownerAgency": _owner,
              "mentorId": _mentorID,
              "collegeId": _collegeId
            };

            Map<String, dynamic> user = <String, dynamic>{"inIntern": true};

            Firestore.instance
                .collection("users")
                .document("${widget.idUser}")
                .updateData(user)
                .whenComplete(() {
              Firestore.instance
                  .collection("registerIntern")
                  .document("$_idInternship")
                  .updateData(data)
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
                .where('status', isEqualTo: 'review')
                .getDocuments()
                .then((data) {
              data.documents.forEach((doc) {
                //update masing-masing status false di register dari for each doc
                Map<String, dynamic> statFalse = <String, dynamic>{
                  "status": 'rejected',
                  "rejectedAt": dateNow
                };
                String docID =
                    "${doc.data["userId"]}_${doc.data["vacanciesId"]}";

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
        } else {
          _showToast("Kuota Lowongan telah penuh", Colors.red);
        }
      }
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
          _timeEndInternStamp = data.documents[0].data['timeEndIntern'];
          _timeEndIntern = _timeEndInternStamp.toDate();
          _timeStartInternStamp = data.documents[0].data['timeStartIntern'];
          _timeStartIntern = _timeStartInternStamp.toDate();
          _mentorID = data.documents[0].data['mentorId'];
          _expiredAtStamp = data.documents[0].data['expiredAt'];
          _expiredAt = _expiredAtStamp.toDate();
          var selisih = dateNow.difference(_expiredAt).inMinutes;
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
          _collegeId = name["collegeId"];
          // _statusUser = data.documents[0].data['inIntern'];
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
                              _showToast(
                                  "Belum saatnya penerimaan", Colors.red);
                            } else {
                              _isPressed();
                            }
                          } else {
                            _hasilTolak();
                          }
                        },
                        itemBuilder: (BuildContext context) => _popUpTerimaItem,
                      )),
            new Divider(),
          ],
        ));
  }
}
