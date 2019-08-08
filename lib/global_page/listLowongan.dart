import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:date_format/date_format.dart';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:tempat_magang/user_page/detailLowongan.dart';

final loadingLoad = CircularProgressIndicator(
  backgroundColor: Colors.deepOrange,
  strokeWidth: 1.5,
);

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
    childDirected: false,
    nonPersonalizedAds: false,
    );

BannerAd _bannerAd;

BannerAd createBannerAd() {
  return new BannerAd(
      adUnitId: BannerAd.testAdUnitId,
      targetingInfo: targetingInfo,
      size: AdSize.smartBanner,
      listener: (MobileAdEvent event) {
        print("intern banner ad $event");
      });
}

class ListLowonganGlobal extends StatefulWidget {
  @override
  ListLowonganGlobalState createState() {
    return new ListLowonganGlobalState();
  }
}

class ListLowonganGlobalState extends State<ListLowonganGlobal> {
  @override
  void initState() {
    super.initState();
    FirebaseAdMob.instance
        .initialize(appId: FirebaseAdMob.testAppId);
    _bannerAd = createBannerAd()
      ..load()
      ..show();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: Container(
        height: 50.0,
        color: Colors.white,
      ),
      body: DefaultTabController(
          length: 2,
          child: NestedScrollView(
              headerSliverBuilder:
                  (BuildContext context, bool innerBoxIsScrolled) {
                return <Widget>[
                  SliverAppBar(
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
                              "List Magang"
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
                  new Container(
                    margin: const EdgeInsets.all(10.0),
                    child: new Text(
                      "Segera temukan magangmu",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey),
                    ),
                  ),
                  new Expanded(
                    child: ListPage()
                  ),
                ],
              )),
        )
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
        .collection("vacancies")
        .where("expiredAt", isGreaterThanOrEqualTo: dateNow)
        .orderBy('expiredAt',
            descending: true) //ini optional masih salah composite index
        .orderBy('createdAt', descending: true)
        .getDocuments();

    return qn.documents;
  }

  //composite expiredAt and createdAt

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FutureBuilder(
        future: getLowongan(),
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
            if (snapshot.data.length <= 0) {
              return Center(
                child: new Text(
                  "Yah.. Belum ada lowongan..",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data.length,
                itemBuilder: (_, index) {
                  // DocumentSnapshot ds = snapshot.data.documents[index];
                  Timestamp _createdAtStamp =
                      snapshot.data[index].data["createdAt"];
                  Timestamp _startInternStamp =
                      snapshot.data[index].data["timeStartIntern"];
                  Timestamp _endInternStamp =
                      snapshot.data[index].data["timeEndIntern"];
                  String uploadTglBaru = formatDate(
                      _createdAtStamp.toDate(), [dd, ' ', MM, ' ', yyyy]);
                  String mulaiTglBaru = formatDate(
                      _startInternStamp.toDate(), [dd, ' ', MM, ' ', yyyy]);
                  String akhirTglBaru = formatDate(
                      _endInternStamp.toDate(), [dd, ' ', MM, ' ', yyyy]);

                  return new CustomCard(
                    jurusan: List.from(snapshot.data[index].data["department"]),
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
      instansi;

  final int kuota;
  final List<String> requirementNya, jurusan;

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
                  onTap: () {
                    Navigator.of(context).push(new MaterialPageRoute(
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
                    ));
                  },
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
                              // new Container(
                              //   child: new IconButton(
                              //     onPressed: () {},
                              //     icon: Icon(Icons.more_vert),
                              //   ),
                              // ),
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