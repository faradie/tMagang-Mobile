import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'auth.dart';

class Dashboard extends StatefulWidget {
  Dashboard({this.auth, this.onSignedOut});
  final BaseAuth auth;
  final VoidCallback onSignedOut;

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var dbLowonganSementara = [
    {
      "judul": "Informasi Lowongan di PT ICON+",
      "tgl": "25 Desember 2018",
      "deskripsi":
          "Ini adalah isi dari lowongan magang dari icon+ yang mulai bekerja pada tgl 30 desember 2018 bertepatan dengan tahun baru misalnya",
      "requirement": [
        "Flutter",
        "Angular",
        "Firebase",
      ],
      "jurusan": "Informatika",
      "kuota": 5,
    },
    {
      "judul": "Lowongan PT.OT Group",
      "tgl": "31 Mei 2019",
      "deskripsi":
          "Ini adalah isi dari lowongan magang dari PT.OT Group yang mulai bekerja pada tgl 30 desember 2018 bertepatan dengan tahun baru misalnya",
      "requirement": [
        "Manajemen",
        "Pajak",
        "Akuntansi",
        "Psikolog",
      ],
      "jurusan": "Sipil",
      "kuota": 5,
    },
    {
      "judul": "Magang diKampus Jurusan Teknik SIPIL",
      "tgl": "22 Januari 2018",
      "deskripsi":
          "Ini adalah isi dari lowongan magang dari kampus jurusan sipil yang mulai bekerja pada tgl 30 desember 2018 bertepatan dengan tahun baru misalnya",
      "requirement": [
        "Codegniter",
      ],
      "jurusan": "Informatika",
      "kuota": 5,
    },
    {
      "judul": "Informasi",
      "tgl": "25 Desember 2018",
      "deskripsi":
          "Ini adalah isi dari lowongan magang dari icon+ yang mulai bekerja pada tgl 30 desember 2018 bertepatan dengan tahun baru misalnya",
      "requirement": [
        "Flutter",
        "Angular",
        "Firebase",
        "C++",
      ],
      "jurusan": "Informatika",
      "kuota": 5,
    },
  ];

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

  void getDataUser() async {
    await widget.auth.getUser().then((value) {
      setState(() {
        _currentEmail = value.email;
      });
    });
  }

  bool _isVisible = true;
  @override
  void initState() {
    super.initState();
    getDataUser();
    _isVisible = true;
    _hideButtonController = new ScrollController();
    _hideButtonController.addListener(() {
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.forward) {
        setState(() {
          _isVisible = true;
        });
      }
      if (_hideButtonController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          _isVisible = false;
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
                accountName: setNamanya(),
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
        body: new ListView(
          controller: _hideButtonController,
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
            CustomCard(),
            CustomCard(),
            CustomCard(),
            CustomCard(),
            CustomCard(),
            CustomCard(),
            CustomCard(),
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
                          'Judul Lowongan Pekerjaan 2018',
                          style: new TextStyle(
                              fontSize: 15.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[850]),
                        ),
                      ),
                      new Container(
                        padding: const EdgeInsets.only(bottom: 8.0, left: 8.0),
                        child: new Text(
                          'Tanggal Upload',
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
                      children: <Widget>[
                        new Text(
                            "Ini adalah data-data dari penyedia lowongan untuk pemagang asdasdasd asdasdas asa  gsdgsdg sdgsdgs")
                      ],
                    ),
                  )
                ],
              )),
          Container(
            padding: const EdgeInsets.only(bottom: 8.0, left: 8.0, right: 8.0),
            child: Container(
              height: 25.0,
              color: Colors.transparent,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: KompetensiUser(
                          judulKompetensi: "Manajemen",
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: KompetensiUser(
                          judulKompetensi: "Akuntansi",
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: KompetensiUser(
                          judulKompetensi: "Pajak",
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: KompetensiUser(
                          judulKompetensi: "Flutter",
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: KompetensiUser(
                          judulKompetensi: "Arsitek",
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: KompetensiUser(
                          judulKompetensi: "Sopir",
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: KompetensiUser(
                          judulKompetensi: "Input",
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: KompetensiUser(
                          judulKompetensi: "Manajemen",
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.only(right: 5.0),
                        child: KompetensiUser(
                          judulKompetensi: "Manajemen",
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
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
