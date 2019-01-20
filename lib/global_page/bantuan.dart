import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

final loadingLoad = CircularProgressIndicator(
  backgroundColor: Colors.deepOrange,
  strokeWidth: 1.5,
);

class Bantuan extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return DefaultTabController(
      length: 5,
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
            title: new Text("Bantuan"),
            backgroundColor: const Color(0xFFe87c55),
            bottom: TabBar(
              isScrollable: true,
              unselectedLabelColor: Color(0xFFff9f7f),
              tabs: <Widget>[
                Tab(
                  child: new Text(
                    "FAQ",
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
                    "Kampus",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Tab(
                  child: new Text(
                    "Mentor",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                Tab(
                  child: new Text(
                    "Instansi",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
          body: new TabBarView(
            children: <Widget>[
              Container(
                child: new Center(
                  child: new Text("Tab 1 FAQ"),
                ),
              ),
              //batas tabs 1 dan 2
              Container(
                  child: new ListView(
                children: <Widget>[
                  new Card(
                    child: new Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        ExpansionTile(
                          leading: new Icon(Icons.warning),
                          title: new Text("Aturan"),
                          children: <Widget>[
                            StreamBuilder<DocumentSnapshot>(
                              stream: Firestore.instance
                                  .collection('bantuan')
                                  .document('pemagang_aturan')
                                  .snapshots(),
                              builder: (BuildContext context,
                                  AsyncSnapshot<DocumentSnapshot> snapshot) {
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
                                } else if (!snapshot.hasData) {
                                  return Center(
                                      child:
                                          new Text("Yah.. Belum ada Aturan.."));
                                } else if (snapshot.hasError) {
                                  return Center(
                                      child: new Text(
                                          "Yah.. ada yang salah nih.."));
                                } else {
                                  List<dynamic> name =
                                      snapshot.data['aturan'] == null
                                          ? ""
                                          : snapshot.data['aturan'];

                                  print("ini jumlah aturan ${name.length}");
                                  List<Container> listAturan() {
                                    List<Container> list = new List();
                                    for (var i = 0; i < name.length; i++) {
                                      list.add(Container(
                                          padding: const EdgeInsets.only(
                                              bottom: 8.0,
                                              left: 8.0,
                                              right: 8.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: <Widget>[
                                              new Text(
                                                "${i + 1}",
                                                style: TextStyle(
                                                    fontSize: 17.0,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                              new Text(
                                                ".  ",
                                                style:
                                                    TextStyle(fontSize: 17.0),
                                              ),
                                              new Expanded(
                                                child: new Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  children: <Widget>[
                                                    new Text("${name[i]}",
                                                        textAlign:
                                                            TextAlign.justify,
                                                        style: TextStyle(
                                                            fontSize: 15.0))
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )));
                                    }
                                    return list;
                                  }

                                  return new Column(
                                    children: listAturan(),
                                  );
                                }
                              },
                            )
                          ],
                        )
                      ],
                    ),
                  )
                ],
              )),
              //akhir dari tab2
              Container(
                child: new Center(
                  child: new Text("Tab 3 Kampus"),
                ),
              ),
              //akhir dari tab3
              Container(
                child: new Center(
                  child: new Text("Tab 4 Mentor"),
                ),
              ),
              //akhir dari tab4
              Container(
                child: new Center(
                  child: new Text("Tab 5 Instansi"),
                ),
              )
            ],
          )),
    );
  }
}
