import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';

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

class ListMagangMentor extends StatefulWidget {
  ListMagangMentor({this.idMentor});
  final String idMentor;
  _ListMagangMentorState createState() => _ListMagangMentorState();
}

class _ListMagangMentorState extends State<ListMagangMentor> {
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
                    .collection('internship')
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
                    .collection('internship')
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
        .collection('internship')
        .where('mentorId', isEqualTo: widget.id)
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
  String _namaLowongan, _timeEndIntern;

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
  DetailMentoring({this.judul, this.idLowongan});
  final String judul, idLowongan;
  _DetailMentoringState createState() => _DetailMentoringState();
}

class _DetailMentoringState extends State<DetailMentoring> {
  var rating = 0.0;
  String _namaUser;
  var name;

  Future _getPemagang() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore
        .collection('internship')
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
                                        "Jurusan : ${snapshot.data['departement']}",
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
                  }
                },
              ),
              //batas tabs 1 dan 2
              Container(
                child: new FutureBuilder(
                  future: _getPemagang(),
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
      this.idMentor,
      this.owner});
  final String idUser, no, idLowongan, idMentor, owner;
  final Timestamp endIntern;
  _TilePemagangState createState() => _TilePemagangState();
}

class _TilePemagangState extends State<TilePemagang> {
  DateTime _endMagang;
  DateTime dateNow = DateTime.now();
  var name, mapKampus;
  bool penerimaan = false;
  bool tekan = true;
  bool tekanList = true;
  String _namaUser, _kampus;
  var _ratDisiplin = 0.0;
  var _ratTanggungJawab = 0.0;
  var _ratTeamWork = 0.0;
  var _ratPlanningSkill = 0.0;
  var _ratLeadership = 0.0;
  var _ratProbandDecis = 0.0;
  var _ratKepatuhan = 0.0;
  var _ratKejujuran = 0.0;
  var _ratinisiatif = 0.0;
  var _ratselfMotivation = 0.0;
  var _ratAnaliticalThink = 0.0;
  var _ratAchivement = 0.0;
  var _ratInovatif = 0.0;

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
      "disiplin": _ratDisiplin,
      "tanggungJawab": _ratTanggungJawab,
      "teamWork": _ratTeamWork,
      "planningSkills": _ratPlanningSkill,
      "leadership": _ratLeadership,
      "problemSolvingDecision": _ratProbandDecis,
      "kepatuhan": _ratKepatuhan,
      "kejujuran": _ratKejujuran,
      "inisiatif": _ratinisiatif,
      "selfMotifation": _ratselfMotivation,
      "analithicalThinking": _ratAnaliticalThink,
      "achievementOrientation": _ratAchivement,
      "inofatif": _ratInovatif
    };

    Firestore.instance
        .collection("reportIntern")
        .document("$_idPenilaianIntern")
        .setData(data)
        .whenComplete(() {
      _showToast("Berhasil Menilai", Color(0xFFe87c55));

      setState(() {
        tekan = true;
        tekanList = true;
        this._ratDisiplin = 0.0;
        this._ratTanggungJawab = 0.0;
        this._ratTeamWork = 0.0;
        this._ratPlanningSkill = 0.0;
        this._ratLeadership = 0.0;
        this._ratProbandDecis = 0.0;
        this._ratKepatuhan = 0.0;
        this._ratKejujuran = 0.0;
        this._ratinisiatif = 0.0;
        this._ratselfMotivation = 0.0;
        this._ratAnaliticalThink = 0.0;
        this._ratAchivement = 0.0;
        this._ratInovatif = 0.0;
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

  void showAlert(BuildContext context, String nama) async {
    DocumentReference favoritesReference = Firestore.instance
        .collection('reportIntern')
        .document("${widget.idLowongan}_${widget.idUser}");
    Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(favoritesReference);
      if (postSnapshot.exists) {
        await tx.get(favoritesReference).then((doc) {
          this._ratDisiplin = doc.data["disiplin"];
          this._ratTanggungJawab = doc.data["tanggungJawab"];
          this._ratTeamWork = doc.data["teamWork"];
          this._ratPlanningSkill = doc.data["planningSkills"];
          this._ratLeadership = doc.data["leadership"];
          this._ratProbandDecis = doc.data["problemSolvingDecision"];
          this._ratKepatuhan = doc.data["kepatuhan"];
          this._ratKejujuran = doc.data["kejujuran"];
          this._ratinisiatif = doc.data["inisiatif"];
          this._ratselfMotivation = doc.data["selfMotifation"];
          this._ratAnaliticalThink = doc.data["analithicalThinking"];
          this._ratAchivement = doc.data["achievementOrientation"];
          this._ratInovatif = doc.data["inofatif"];
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
                                        "1. Bagaimana dengan kedisiplinannya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratDisiplin,
                                      starCount: 5,
                                      onRatingChanged: (v) {
                                        this._ratDisiplin = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "2. Bagaimana dengan tanggung jawabnya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratTanggungJawab,
                                      starCount: 5,
                                      onRatingChanged: (v) {
                                        this._ratTanggungJawab = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "3. Bagaimana dengan teamwork nya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratTeamWork,
                                      starCount: 5,
                                      onRatingChanged: (v) {
                                        this._ratTeamWork = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "4. Bagaimana dengan planning skill nya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratPlanningSkill,
                                      starCount: 5,
                                      onRatingChanged: (v) {
                                        this._ratPlanningSkill = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "5. Bagaimana dengan leadership nya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratLeadership,
                                      starCount: 5,
                                      onRatingChanged: (v) {
                                        this._ratLeadership = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "6. Bagaimana dengan problem solving dan decision taking skills nya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratProbandDecis,
                                      starCount: 5,
                                      onRatingChanged: (v) {
                                        this._ratProbandDecis = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "7. Bagaimana dengan kepatuhan nya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratKepatuhan,
                                      starCount: 5,
                                      onRatingChanged: (v) {
                                        this._ratKepatuhan = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "8. Bagaimana dengan kejujuran nya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratKejujuran,
                                      starCount: 5,
                                      onRatingChanged: (v) {
                                        this._ratKejujuran = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "9. Bagaimana dengan rasa inisiatif nya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratinisiatif,
                                      starCount: 5,
                                      onRatingChanged: (v) {
                                        this._ratinisiatif = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "10. Bagaimana dengan self motivation nya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratselfMotivation,
                                      starCount: 5,
                                      onRatingChanged: (v) {
                                        this._ratselfMotivation = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "11. Bagaimana dengan analithical thinking nya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratAnaliticalThink,
                                      starCount: 5,
                                      onRatingChanged: (v) {
                                        this._ratAnaliticalThink = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "12. Bagaimana dengan achievement orientation nya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratAchivement,
                                      starCount: 5,
                                      onRatingChanged: (v) {
                                        this._ratAchivement = v;
                                      },
                                    )),
                                    new Divider(),
                                    new Text(
                                        "13. Bagaimana dengan inovasi nya?"),
                                    new Container(
                                        child: RatingStarFull(
                                      color: Colors.red,
                                      rating: _ratInovatif,
                                      starCount: 5,
                                      onRatingChanged: (v) {
                                        this._ratInovatif = v;
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
                                  this._ratDisiplin = 0.0;
                                  this._ratTanggungJawab = 0.0;
                                  this._ratTeamWork = 0.0;
                                  this._ratPlanningSkill = 0.0;
                                  this._ratLeadership = 0.0;
                                  this._ratProbandDecis = 0.0;
                                  this._ratKepatuhan = 0.0;
                                  this._ratKejujuran = 0.0;
                                  this._ratinisiatif = 0.0;
                                  this._ratselfMotivation = 0.0;
                                  this._ratAnaliticalThink = 0.0;
                                  this._ratAchivement = 0.0;
                                  this._ratInovatif = 0.0;
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

                    showAlert(context, _namaUser);
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
              // trailing: penerimaan == false
              //     ? new Text("")
              //     : new PopupMenuButton<String>(
              //         onSelected: (String newValue) {
              //           _selectVal = newValue;
              //           if (_selectVal == "Terima") {
              //             if (penerimaan == false) {
              //               _showToast("Belum saatnya", Colors.red);
              //             } else {
              //               _isPressed();
              //             }
              //           } else {
              //             _hasilTolak();
              //           }
              //         },
              //         itemBuilder: (BuildContext context) => _popUpTerimaItem,
              //       )
            ),
            new Divider(),
          ],
        ));
  }
}
