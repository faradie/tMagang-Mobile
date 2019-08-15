import 'dart:async';
import 'dart:io';
import 'package:firebase_admob/firebase_admob.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as Img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

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

InterstitialAd _interstitialAd;

InterstitialAd createInterstitialAd() {
  return new InterstitialAd(
      adUnitId: InterstitialAd.testAdUnitId,
      targetingInfo: targetingInfo,
      listener: (MobileAdEvent event) {
        print("intertiat ad $event");
      });
}

class ProfilMentor extends StatefulWidget {
  ProfilMentor({this.iduser});
  final String iduser;
  _ProfilMentorState createState() => _ProfilMentorState();
}

class _ProfilMentorState extends State<ProfilMentor> {
  var name;
  List<dynamic> dummy = ["Skill belum diatur"];
  String _namaUser,
      _collegeName,
      _collegeId,
      _jenisKel,
      _kontak,
      _linkPhoto,
      _alamat,
      _userViewId,
      _isActive,
      _abouts;

  Future getDataUser() async {
    var user = await FirebaseAuth.instance.currentUser();
    var firestore = Firestore.instance;
    var userQuery = firestore
        .collection('users')
        .where('uid', isEqualTo: widget.iduser)
        .limit(1);

    userQuery.getDocuments().then((data) {
      print("banyak data : ${data.documents.length}");
      if (data.documents.length > 0) {
        setState(() {
          _userViewId = user.uid;
          name = data.documents[0].data['data'] as Map<dynamic, dynamic>;
          _namaUser = name["displayName"];
          _linkPhoto = name["photoURL"];
          _isActive = data.documents[0].data['role'];
          _jenisKel = name["gender"] == "male"
              ? "Laki-laki"
              : name["gender"] == "female" ? "Perempuan" : null;
          _abouts =
              name["about"] == null ? "Belum ada tentang saya" : name["about"];
          _kontak = name["phoneNumber"];
          _collegeId = name["agencyId"];
          _alamat = name["address"];
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
          title: new Text("Profil Mentor"),
          leading: InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: new Icon(
              Icons.chevron_left,
              color: Colors.white,
            ),
          ),
          actions: _userViewId == widget.iduser
              ? <Widget>[
                  new FlatButton(
                    child: new Icon(Icons.settings, color: Colors.white),
                    onPressed: () {
                      Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) => new EditProfilMentor(
                              agencyId: _collegeId,
                              agencyName: _collegeName,
                              stats: _isActive,
                              namaUser: _namaUser,
                              idMentor: _userViewId,
                              jenisKelamin: _jenisKel,
                              kontak: _kontak == null ? "Kosong" : _kontak,
                              alamat: _alamat,
                              about: _abouts,
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
                        _linkPhoto == null
                            ? new CircleAvatar(
                                radius: 40.0,
                                backgroundColor: const Color(0xFFe87c55),
                                child: new Text(
                                  "T",
                                  style: TextStyle(
                                      fontSize: 20.0,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white),
                                ),
                              )
                            : new CircleAvatar(
                                radius: 40.0,
                                backgroundImage: NetworkImage(_linkPhoto),
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
                                color: Colors.grey,
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold),
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
                        style:
                            new TextStyle(color: Colors.grey, fontSize: 13.0),
                      ),
                      new Text(
                        _isActive == null
                            ? "Mengambil data"
                            : _isActive.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                            "Tentang saya",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          new Text(_abouts == null
                              ? "Silahkan lengkapi data"
                              : _abouts)
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                    )
                  ],
                ),
              ),
            ],
          ),
        ));
  }
}

class EditProfilMentor extends StatefulWidget {
  EditProfilMentor(
      {this.agencyName,
      this.agencyId,
      this.stats,
      this.about,
      this.alamat,
      this.idMentor,
      this.namaUser,
      this.kontak,
      this.jenisKelamin});
  final String agencyName,
      idMentor,
      agencyId,
      stats,
      namaUser,
      jenisKelamin,
      kontak,
      alamat,
      about;
  _EditProfilMentorState createState() => _EditProfilMentorState();
}

class _EditProfilMentorState extends State<EditProfilMentor> {
  final TextEditingController _controlName = new TextEditingController();
  final TextEditingController _controlAbout = new TextEditingController();
  final TextEditingController _controlKontak = new TextEditingController();
  final TextEditingController _controlAlamat = new TextEditingController();
  String _linkPhoto, _namaUser, _tmpJenisKelamin, _agencyId, _emailUser;
  var _setting, _shortcut;
  File image;
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

  uploadImage() async {
    var user = await FirebaseAuth.instance.currentUser();

    String title = user.uid;

    Img.Image resizeImage = Img.decodeImage(image.readAsBytesSync());
    Img.Image smallerImage = Img.copyResize(resizeImage, 200);
    var compressImg = new File(image.path)
      ..writeAsBytesSync(Img.encodeJpg(smallerImage, quality: 85));

    StorageReference ref = FirebaseStorage.instance.ref().child("$title.jpg");
    StorageUploadTask uploadTask = ref.putFile(compressImg);

    var downloadUrl = await (await uploadTask.onComplete).ref.getDownloadURL();
    var url = downloadUrl.toString();

    // Map<String, dynamic> datadalam = <String, dynamic>{
    //   "studentIDNumber": _controlNIM.text,
    //   "skills": _controlSkills.text == "Skill belum diatur"
    //       ? null
    //       : _controlSkills.text.toLowerCase().split(","),
    //   "photoURL": url,
    //   "phoneNumber": _controlKontak.text,
    //   "addSkill": true,
    //   "gender": _tmpJenisKelamin,
    //   "email": _emailUser,
    //   "displayName": _controlName.text,
    //   "collegeId": _collegeID,
    //   "department": widget.jurusan,
    //   "address": _controlAlamat.text
    // };

    // Map<String, dynamic> dataAwal = <String, dynamic>{
    //   "data": datadalam,
    // };
    DocumentReference favoritesReference =
        Firestore.instance.collection('users').document("${widget.idMentor}");
    Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(favoritesReference);
      if (postSnapshot.exists) {
        await tx.update(favoritesReference, <String, dynamic>{
          'data': {
            "photoURL": url,
            "phoneNumber": _controlKontak.text,
            "gender": _tmpJenisKelamin,
            "email": _emailUser,
            "displayName": _controlName.text,
            "agencyId": _agencyId,
            "address": _controlAlamat.text,
            "settings": _setting,
            "shortcuts": _shortcut,
            "about": _controlAbout.text
          }
        });
      } else {}
    }).then((hasil) {
      Navigator.of(this.context).pop();
      Navigator.of(this.context).pop();
      _showToast("Berhasil Update Profil", Colors.blue);
      createInterstitialAd()
        ..load()
        ..show();
    });
  }

  @override
  void dispose() {
    _interstitialAd.dispose();
    super.dispose();
  }

  void isPressed() {
    setState(() {
      tekan = false;
    });

    if (image == null) {
      DocumentReference favoritesReference =
          Firestore.instance.collection('users').document("${widget.idMentor}");
      Firestore.instance.runTransaction((Transaction tx) async {
        DocumentSnapshot postSnapshot = await tx.get(favoritesReference);
        if (postSnapshot.exists) {
          await tx.update(favoritesReference, <String, dynamic>{
            'data': {
              "photoURL": _linkPhoto,
              "phoneNumber": _controlKontak.text,
              "gender": _tmpJenisKelamin,
              "email": _emailUser,
              "displayName": _controlName.text,
              "agencyId": _agencyId,
              "address": _controlAlamat.text,
              "settings": _setting,
              "shortcuts": _shortcut,
              "about": _controlAbout.text
            }
          });
        } else {}
      }).then((hasil) {
        //perbaiki lagi
        Navigator.of(this.context).pop();
        Navigator.of(this.context).pop();
        _showToast("Berhasil Update Profil", Colors.blue);
        createInterstitialAd()
          ..load()
          ..show();
      });
    } else {
      uploadImage();
    }
  }

  Future _ambilGambar() async {
    var selectedImage =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      image = selectedImage;
      // _imageName = basename(image.path);
    });
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
          _linkPhoto = name["photoURL"];
          _agencyId = name["agencyId"];
          _emailUser = name["email"];
          _setting = name["settings"] as Map<dynamic, dynamic>;
          _shortcut = name["shortcut"] as List<dynamic>;
        });
      }
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
    super.initState();
    getDataUser();
    _controlName.text = widget.namaUser;
    _tmpJenisKelamin = widget.jenisKelamin == "Laki-laki"
        ? "male"
        : widget.jenisKelamin == "Kosong" ? "male" : "female";
    _controlKontak.text = widget.kontak == "Kosong" ? "" : widget.kontak;
    _controlAlamat.text = widget.alamat == "Kosong" ? "" : widget.alamat;
    _controlAbout.text = widget.about == "Kosong" ? "" : widget.about;
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
                        image == null
                            ? _linkPhoto == null
                                ? new CircleAvatar(
                                    radius: 40.0,
                                    backgroundColor: const Color(0xFFe87c55),
                                    child: new Text(
                                      "T",
                                      style: TextStyle(
                                          fontSize: 20.0,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white),
                                    ),
                                  )
                                : new CircleAvatar(
                                    radius: 40.0,
                                    backgroundImage: NetworkImage(_linkPhoto),
                                  )
                            : new CircleAvatar(
                                radius: 40.0,
                                backgroundImage: FileImage(image),
                              ),
                        Padding(
                          padding: const EdgeInsets.only(left: 10.0),
                        ),
                        new Container(
                          padding:
                              const EdgeInsets.only(bottom: 8.0, left: 8.0),
                          child: InkWell(
                            onTap: _ambilGambar,
                            child: new Text(
                              "Ubah Foto",
                              style: new TextStyle(
                                  color: Colors.grey, fontSize: 13.0),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        new Container(
                          padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                          child: new TextFormField(
                            controller: _controlName,
                            keyboardType: TextInputType.text,
                            decoration: new InputDecoration(
                              labelText: 'Nama Mentor',
                            ),
                          ),
                        ),
                        new Container(
                          padding:
                              const EdgeInsets.only(bottom: 8.0, left: 8.0),
                          child: new Text(
                            widget.agencyName == null
                                ? "Mengambil data"
                                : widget.agencyName,
                            style: new TextStyle(
                                color: Colors.grey,
                                fontSize: 13.0,
                                fontWeight: FontWeight.bold),
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
                        style:
                            new TextStyle(color: Colors.grey, fontSize: 13.0),
                      ),
                      new Text(
                        widget.stats == null
                            ? "Mengambil data"
                            : widget.stats.toUpperCase(),
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
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
                      child: new Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          new Text("Jenis Kelamin : "),
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
                            keyboardType: TextInputType.number,
                            decoration: new InputDecoration(
                              labelText: 'Kontak Aktif Mentor',
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                    ),
                    Container(
                      child: new ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 300.0),
                        child: new Scrollbar(
                          child: new SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            reverse: true,
                            child: new TextFormField(
                              controller: _controlAlamat,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: new InputDecoration(
                                border: new OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                  const Radius.circular(10.0),
                                )),
                                labelText: 'Alamat Mentor',
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                    ),
                    Container(
                      child: new ConstrainedBox(
                        constraints: BoxConstraints(maxHeight: 300.0),
                        child: new Scrollbar(
                          child: new SingleChildScrollView(
                            scrollDirection: Axis.vertical,
                            reverse: true,
                            child: new TextFormField(
                              controller: _controlAbout,
                              keyboardType: TextInputType.multiline,
                              maxLines: null,
                              decoration: new InputDecoration(
                                border: new OutlineInputBorder(
                                    borderRadius: const BorderRadius.all(
                                  const Radius.circular(10.0),
                                )),
                                labelText: 'Tentang saya',
                              ),
                            ),
                          ),
                        ),
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
        ));
  }
}
