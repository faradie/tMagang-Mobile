import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class InternProfil extends StatefulWidget {
  InternProfil({this.id});
  final String id;
  @override
  InternProfilState createState() {
    return new InternProfilState();
  }
}

class InternProfilState extends State<InternProfil> {
  var name;
  List<dynamic> dummy = ["Skill belum diatur"];
  String _namaUser,
      _collegeName,
      _collegeId,
      _jurusan,
      _jenisKel,
      _nim,
      _kontak,
      _alamat,
      _userViewId,
      _isActive;
  List<String> _requirementNya;

  Future getDataUser() async {
    var user = await FirebaseAuth.instance.currentUser();
    var firestore = Firestore.instance;
    var userQuery = firestore
        .collection('users')
        .where('uid', isEqualTo: widget.id)
        .limit(1);

    userQuery.getDocuments().then((data) {
      print("banyak data : ${data.documents.length}");
      if (data.documents.length > 0) {
        setState(() {
          _userViewId = user.uid;
          name = data.documents[0].data['data'] as Map<dynamic, dynamic>;
          _namaUser = name["displayName"];

          _jurusan = name["departement"];
          _isActive = name["isActive"] == true ? "Magang" : "Tidak Magang";
          _jenisKel = name["gender"] == "male"
              ? "Laki-laki"
              : name["gender"] == "female" ? "Perempuan" : null;
          _nim = name["studentIDNumber"];
          _kontak = name["phoneNumber"];
          _collegeId = name["collegeId"];
          _alamat = name["address"];
          _requirementNya =
              List.from(name["skills"] == null ? dummy : name["skills"]);
        });
        var getCollegeNameQuery = firestore
            .collection('users')
            .where('uid', isEqualTo: _collegeId)
            .limit(1);

        getCollegeNameQuery.getDocuments().then((data) {
          if (data.documents.length > 0) {
            setState(() {
              name = data.documents[0].data['data'] as Map<dynamic, dynamic>;
              _collegeName = name["displayName"];
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
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          elevation:
              defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
          backgroundColor: const Color(0xFFe87c55),
          title: new Text("Profil Pemagang"),
          leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: new Icon(
              Icons.chevron_left,
              color: Colors.white,
            ),
          ),
          actions: _userViewId == widget.id
              ? <Widget>[
                  new FlatButton(
                    child: new Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) => new EditProfil(
                              idMhs: widget.id,
                              linkPhoto: "iniLink Foto",
                              namaUser:
                                  _namaUser == null ? "Kosong" : _namaUser,
                              nimUser: _nim == null ? "Kosong" : _nim,
                              jenisKelamin:
                                  _jenisKel == null ? "Kosong" : _jenisKel,
                              kontak: _kontak == null ? "Kosong" : _kontak,
                              alamat: _alamat == null ? "Kosong" : _alamat,
                              skills: _requirementNya,
                              jurusan: _jurusan,
                              kampus: _collegeName,
                              status: _isActive,
                            ),
                      ));
                    },
                  )
                ]
              : null,
        ),
        body: new Container(
          child: new ListView(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.all(5.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  new Expanded(
                    child: new Column(
                      children: <Widget>[
                        new CircleAvatar(
                          radius: 40.0,
                          backgroundColor: Colors.amber,
                          child: new Text("A"),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                        ),
                        new Container(
                          padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                          child: new Text(
                            _namaUser == null
                                ? "Mengambil data"
                                : _namaUser.toUpperCase(),
                            style: new TextStyle(
                                fontSize: 15.0,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[850]),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        new Container(
                          padding:
                              const EdgeInsets.only(bottom: 8.0, left: 8.0),
                          child: new Text(
                            _collegeName == null
                                ? "Mengambil data"
                                : _collegeName,
                            style: new TextStyle(
                                color: Colors.grey, fontSize: 13.0),
                            textAlign: TextAlign.center,
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  new Column(
                    children: <Widget>[
                      new Text(
                        "Status",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      new Text(
                          _isActive == null ? "Mengambil data" : _isActive),
                    ],
                  ),
                  new Column(
                    children: <Widget>[
                      new Text(
                        "Jurusan",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      new Text(_jurusan == null ? "Mengambil data" : _jurusan),
                    ],
                  ),
                ],
              ),
              new Divider(
                color: Colors.grey,
              ),
              new Card(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Container(
                      margin: const EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            "NIM",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          new Text(
                              _nim == null ? "Silahkan lengkapi data" : _nim)
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            "Jenis kelamin",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          new Text(_jenisKel == null
                              ? "Silahkan lengkapi data"
                              : _jenisKel)
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            "Kontak",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          new Text(_kontak == null
                              ? "Silahkan lengkapi data"
                              : _kontak)
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            "Alamat",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          new Text(_alamat == null
                              ? "Silahkan lengkapi data"
                              : _alamat)
                        ],
                      ),
                    ),
                    Container(
                      margin: const EdgeInsets.only(
                          top: 10.0, left: 10.0, right: 10.0),
                      child: new Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          new Text(
                            "Skills",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Container(
                                height: 25.0,
                                color: Colors.transparent,
                                child: Requir(
                                  req: _requirementNya == null
                                      ? ["Silahkan lengkapi data"]
                                      : _requirementNya,
                                )),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                    )
                  ],
                ),
              ),
              new Container(
                margin: const EdgeInsets.all(5.0),
                child: new Text(
                  "Riwayat Magang",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.grey),
                ),
              ),
              new Container(
                margin: const EdgeInsets.all(5.0),
                child: Card(
                  child: Container(
                    margin: const EdgeInsets.all(10.0),
                    child: new Text(
                      "Data Riwayat Magang",
                    ),
                  ),
                ),
              )
            ],
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

class EditProfil extends StatefulWidget {
  EditProfil(
      {this.jurusan,
      this.kampus,
      this.status,
      this.linkPhoto,
      this.namaUser,
      this.nimUser,
      this.jenisKelamin,
      this.kontak,
      this.alamat,
      this.idMhs,
      this.skills});
  final String linkPhoto,
      namaUser,
      nimUser,
      jenisKelamin,
      kontak,
      alamat,
      jurusan,
      idMhs,
      kampus,
      status;
  List<String> skills;
  _EditProfilState createState() => _EditProfilState();
}

class _EditProfilState extends State<EditProfil> {
  final TextEditingController _controlName = new TextEditingController();
  final TextEditingController _controlNIM = new TextEditingController();
  final TextEditingController _controlKontak = new TextEditingController();
  final TextEditingController _controlAlamat = new TextEditingController();
  final TextEditingController _controlSkills = new TextEditingController();
  final formKeySave = new GlobalKey<FormState>();
  String _namaUser,
      _nimUser,
      _kontakUser,
      _alamatUser,
      _skillUser,
      _emailUser,
      _collegeID,
      _tmpJenisKelamin;
  var name;
  bool tekan = true;

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
          _emailUser = name["email"];
          _collegeID = name["collegeId"];
        });
      }
    });
  }

  void isPressed() {
    setState(() {
      tekan = false;
    });
    Map<String, dynamic> datadalam = <String, dynamic>{
      "studentIDNumber": _controlNIM.text,
      "skills": _controlSkills.text.toLowerCase().split(","),
      "photoURL": widget.linkPhoto,
      "phoneNumber": _controlKontak.text,
      "isActive": widget.status == "Magang"
          ? true
          : widget.status == "Tidak Magang" ? false : "",
      "gender": _tmpJenisKelamin,
      "email": _emailUser,
      "displayName": _controlName.text,
      "collegeId": _collegeID,
      "departement": widget.jurusan,
      "address": _controlAlamat.text
    };

    Map<String, dynamic> dataAwal = <String, dynamic>{
      "data": datadalam,
    };
    Firestore.instance
        .collection("users")
        .document("${widget.idMhs}")
        .updateData(dataAwal)
        .whenComplete(() {
      Navigator.of(context).pop();
      Navigator.of(context).pop();
      _showToast("Berhasil Update Profil", Colors.blue);
    }).catchError((e) {
      print(e);
    });
  }

  static const menutItem = <String>['male', 'female'];
  final List<DropdownMenuItem<String>> _dropDownJenisKel = menutItem
      .map((String value) => DropdownMenuItem<String>(
            value: value,
            child: new Text(value == 'female' ? "Perempuan" : "Laki-laki"),
          ))
      .toList();

  @override
  void initState() {
    _controlName.text = widget.namaUser;
    _controlNIM.text = widget.nimUser == "Kosong" ? "" : widget.nimUser;
    _controlKontak.text = widget.kontak == "Kosong" ? "" : widget.kontak;
    _controlAlamat.text = widget.alamat == "Kosong" ? "" : widget.alamat;
    String s = widget.skills.join(', ');
    _controlSkills.text = s;
    _tmpJenisKelamin = widget.jenisKelamin == "Laki-laki"
        ? "male"
        : widget.jenisKelamin == "Kosong" ? "male" : "female";
    super.initState();
    getDataUser();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
        appBar: AppBar(
          elevation:
              defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
          backgroundColor: const Color(0xFFe87c55),
          title: new Text("Edit Profil"),
          leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: new Icon(
              Icons.chevron_left,
              color: Colors.white,
            ),
          ),
        ),
        body: new Container(
          child: Form(
            key: formKeySave,
            child: new ListView(
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(5.0),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    new Expanded(
                      child: new Column(
                        children: <Widget>[
                          new CircleAvatar(
                            radius: 40.0,
                            backgroundColor: Colors.amber,
                            child: new Text("A"),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10.0),
                          ),
                          new Container(
                            padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                            child: new TextFormField(
                              controller: _controlName,
                              onSaved: (value) => _namaUser = value,
                              validator: (value) => value.isEmpty
                                  ? 'Isikan nama terlebih dulu'
                                  : null,
                              keyboardType: TextInputType.text,
                              decoration: new InputDecoration(
                                labelText: 'Nama Pemagang',
                              ),
                            ),
                          ),
                          new Container(
                            padding:
                                const EdgeInsets.only(bottom: 8.0, left: 8.0),
                            child: new Text(
                              widget.kampus == null
                                  ? "Silahkan diisi"
                                  : widget.kampus,
                              style: new TextStyle(
                                  color: Colors.grey, fontSize: 13.0),
                              textAlign: TextAlign.center,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    new Column(
                      children: <Widget>[
                        new Text(
                          "Status",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        new Text(widget.status == null
                            ? "Silahkan diisi"
                            : widget.status),
                      ],
                    ),
                    new Column(
                      children: <Widget>[
                        new Text(
                          "Jurusan",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        new Text(widget.jurusan == null
                            ? "Silahkan diisi"
                            : widget.jurusan),
                      ],
                    ),
                  ],
                ),
                new Divider(
                  color: Colors.grey,
                ),
                new Card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.only(
                            top: 10.0, left: 10.0, right: 10.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new TextFormField(
                              controller: _controlNIM,
                              onSaved: (value) => _nimUser = value,
                              validator: (value) => value.isEmpty
                                  ? 'Isikan NIM terlebih dulu'
                                  : null,
                              keyboardType: TextInputType.text,
                              decoration: new InputDecoration(
                                labelText: 'NIM Pemagang',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            top: 10.0, left: 10.0, right: 10.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new DropdownButton<String>(
                              value: _tmpJenisKelamin,
                              onChanged: (String nilaiBaru) {
                                setState(() {
                                  _tmpJenisKelamin = nilaiBaru;
                                });
                              },
                              items: this._dropDownJenisKel,
                            )
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            top: 10.0, left: 10.0, right: 10.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new TextFormField(
                              controller: _controlKontak,
                              onSaved: (value) => _kontakUser = value,
                              validator: (value) => value.isEmpty
                                  ? 'Isikan kontak terlebih dulu'
                                  : null,
                              keyboardType: TextInputType.number,
                              decoration: new InputDecoration(
                                labelText: 'Kontak Aktif Pemagang',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(
                            top: 10.0, left: 10.0, right: 10.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new TextFormField(
                              controller: _controlAlamat,
                              onSaved: (value) => _alamatUser = value,
                              validator: (value) => value.isEmpty
                                  ? 'Isikan alamat terlebih dulu'
                                  : null,
                              keyboardType: TextInputType.text,
                              decoration: new InputDecoration(
                                labelText: 'Alamat Pemagang',
                              ),
                            ),
                          ],
                        ),
                      ),
                      new Container(
                        margin: const EdgeInsets.all(10.0),
                        child: new Text(
                          "Skill dipisahkan dengan tanda koma ( , ) :",
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(left: 10.0, right: 10.0),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            new TextFormField(
                              controller: _controlSkills,
                              onSaved: (value) => _skillUser = value,
                              validator: (value) => value.isEmpty
                                  ? 'Isikan Skill terlebih dulu'
                                  : null,
                              keyboardType: TextInputType.text,
                              decoration: new InputDecoration(
                                labelText: 'Skill Pemagang',
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                      )
                    ],
                  ),
                ),
                Container(
                  margin: const EdgeInsets.all(10.0),
                  child: ButtonTheme(
                    minWidth: 200.0,
                    height: 60.0,
                    child: new RaisedButton(
                      color: const Color(0xFFff9977),
                      elevation: 4.0,
                      splashColor: Colors.blueGrey,
                      onPressed: tekan == true ? isPressed : null,
                      padding: const EdgeInsets.only(),
                      child: new Text(
                        'Simpan'.toUpperCase(),
                        style: TextStyle(fontSize: 20.0, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ));
  }
}
