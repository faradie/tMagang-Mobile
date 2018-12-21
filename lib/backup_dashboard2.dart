import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'auth.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class Dashboard extends StatefulWidget {
  Dashboard({this.auth, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  String _currentEmail, _namaUser;
  ScrollController _hideButtonController;
  void _signOut() async {
    try {
      await widget.auth.signOut();
      widget.onSignedOut();
    } catch (e) {
      print(e);
    }
  }

  void getData() async {
    await widget.auth.getUser().then((value) {
      setState(() {
        _currentEmail = value.email;
      });
    });
  }

  Future getDataUser() async {
    // Firestore.instance.collection('fields').where('grower', isEqualTo: 1)
    // .snapshots.listen(
    //       (data) => print('grower ${data.documents[0]['name']}')
    // );

    // CollectionReference user = firestore.collection("users");

    // Query qn = await firestore.collection("users").where("email"==_currentEmail);
    // return qn;
    var user = await FirebaseAuth.instance.currentUser();
    var firestore = Firestore.instance;
    var userQuery = firestore
        .collection('users')
        .where('email', isEqualTo: user.email)
        .limit(1);
    userQuery.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          _namaUser = data.documents[0].data['name'];
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
    _isVisible = true;
    _hideButtonController = new ScrollController();
    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.forward) {
        setState(() {
          _isVisible = true;
          print("**** $_isVisible up");
        });
      }
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          _isVisible = false;
          print("**** $_isVisible down");
        });
      }
    });
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
          title: new Center(
            child: Text("Status"),
          ),
          actions: <Widget>[
            new FlatButton(
              child: new Icon(Icons.input, color: Colors.white),
              onPressed: _signOut,
            )
          ],
        ),
        drawer: Drawer(
          child: new ListView(
            children: <Widget>[
              new UserAccountsDrawerHeader(
                accountEmail: new Text('$_currentEmail'),
                accountName: new Text('$_namaUser'),
                currentAccountPicture: new CircleAvatar(
                  backgroundColor: Colors.amber,
                  child: new Text("A"),
                ),
              ),
              new ListTile(
                title: new Text("Menu 1"),
                trailing: new Icon(Icons.menu),
              ),
              new ListTile(
                title: new Text("Menu 2"),
                trailing: new Icon(Icons.memory),
              ),
              new ListTile(
                title: new Text("Menu 3"),
                trailing: new Icon(Icons.map),
              ),
              new Divider(),
              new ListTile(
                title: new Text("Apa aja boleh"),
              ),
            ],
          ),
        ),
        body: new Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            new Column(
              children: <Widget>[
                new Container(
                  color: Theme.of(context).primaryColor,
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

class CustomCard extends StatelessWidget {
  CustomCard(
      {this.judulNya, this.tglUpload, this.deskripsiNya, this.requirementNya});
  final String judulNya, deskripsiNya;
  final DateTime tglUpload;
  final List<String> requirementNya;
  @override
  Widget build(BuildContext context) {
    return new Card(
      elevation: 2.0,
      color: Color(0xFF3cbce0),
      child: Column(
        children: <Widget>[
          Container(
            child: Row(
              children: <Widget>[
                new Container(
                  padding: const EdgeInsets.only(left: 10.0),
                  child: new CircleAvatar(
                    backgroundColor: Colors.blue,
                    child: new Text("W"),
                  ),
                ),
                new Expanded(
                  child: new Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      new Container(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                        child: new Text(
                          judulNya,
                          style: new TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[850]),
                        ),
                      ),
                      new Container(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                        child: new Text(
                          tglUpload.toString(),
                          style: new TextStyle(
                              color: Colors.white, fontSize: 13.0),
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
          Container(
              padding:
                  const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
              child: Row(
                children: <Widget>[
                  new Expanded(
                    child: new Column(
                      children: <Widget>[new Text(deskripsiNya)],
                    ),
                  )
                ],
              )),
          Container(
            padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            child: Container(
                height: 25.0,
                color: Colors.transparent,
                child: Requir(
                  req: requirementNya,
                )),
          ),
        ],
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
            color: Color(0xFF006885),
            borderRadius: new BorderRadius.all(Radius.circular(20.0))),
        child: new Center(
          child: new Text(
            judulKompetensi,
            style: TextStyle(
                fontSize: 15.0,
                color: Colors.white,
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
  Future getLowongan() async {
    var firestore = Firestore.instance;
    QuerySnapshot qn = await firestore.collection("lowongan").getDocuments();
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
              child: Text("Loading Data.."),
            );
          } else {
            return ListView.builder(
              itemCount: snapshot.data.length,
              itemBuilder: (_, index) {
                return CustomCard(
                  judulNya: snapshot.data[index].data["judul"],
                  tglUpload: snapshot.data[index].data["tglUpload"],
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

class SearchLow extends StatefulWidget {
  @override
  _SearchLowState createState() => _SearchLowState();
}

class _SearchLowState extends State<SearchLow> {
  @override
  Widget build(BuildContext context) {
    return new Container(
      color: Theme.of(context).primaryColor,
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
    );
  }
}
