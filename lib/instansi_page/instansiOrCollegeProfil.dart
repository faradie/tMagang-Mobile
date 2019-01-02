import 'dart:io';
import 'package:date_format/date_format.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image/image.dart' as Img;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class InstansiOrCollegeProfil extends StatefulWidget {
  InstansiOrCollegeProfil({this.id});
  final String id;
  _InstansiOrCollegeProfilState createState() =>
      _InstansiOrCollegeProfilState();
}

class _InstansiOrCollegeProfilState extends State<InstansiOrCollegeProfil> {
  String _userViewId, _namaUser, _linkPhoto, _kontak, _alamat;
  String validUntilStr;
  Timestamp _accountExpiredAt;
  var name;
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
          _linkPhoto = name["photoURL"];
          _kontak = name["phoneNumber"];
          _alamat = name["address"];
          _accountExpiredAt = data.documents[0].data['accountExpiredAt'];
          DateTime _valUntil = _accountExpiredAt.toDate();
          validUntilStr = formatDate(_valUntil, [
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
          title: new Text("Profil"),
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
                              idAccount: widget.id,
                              namaUser:
                                  _namaUser == null ? "Kosong" : _namaUser,
                              kontak: _kontak == null ? "Kosong" : _kontak,
                              alamat: _alamat == null ? "Kosong" : _alamat,
                              accountExpiredAt: _accountExpiredAt == null
                                  ? "Kosong"
                                  : _accountExpiredAt,
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
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
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
                            "Valid sampai",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          new Text(validUntilStr == null
                              ? "Mengambil data"
                              : validUntilStr)
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
                  "Data Penunjang",
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
                      "Comingsoon...",
                    ),
                  ),
                ),
              )
            ],
          ),
        ));
  }
}

class EditProfil extends StatefulWidget {
  EditProfil(
      {this.idAccount,
      this.namaUser,
      this.kontak,
      this.alamat,
      this.accountExpiredAt});
  final String namaUser, kontak, alamat, idAccount;
  final Timestamp accountExpiredAt;

  _EditProfilState createState() => _EditProfilState();
}

class _EditProfilState extends State<EditProfil> {
  final TextEditingController _controlName = new TextEditingController();

  final TextEditingController _controlKontak = new TextEditingController();
  final TextEditingController _controlAlamat = new TextEditingController();

  final formKeySave = new GlobalKey<FormState>();
  String _namaUser, _emailUser, _linkPhoto;
  var name;
  bool tekan = true;

  File image;

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
          _linkPhoto = name["photoURL"];
        });
      }
    });
  }

  Future _ambilGambar() async {
    var selectedImage =
        await ImagePicker.pickImage(source: ImageSource.gallery);

    setState(() {
      image = selectedImage;
      // _imageName = basename(image.path);
    });
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

    var downloadUrl = await (await uploadTask.onComplete)
        .ref
        .getDownloadURL()
        .catchError((e) {
      _showToast(e.toString(), Colors.red);
    });
    var url = downloadUrl.toString();

    Map<String, dynamic> datadalam = <String, dynamic>{
      "photoURL": url,
      "phoneNumber": _controlKontak.text,
      "email": _emailUser,
      "displayName": _controlName.text,
      "address": _controlAlamat.text
    };

    Map<String, dynamic> dataAwal = <String, dynamic>{
      "data": datadalam,
    };

    Firestore.instance
        .collection("users")
        .document("${widget.idAccount}")
        .updateData(dataAwal)
        .whenComplete(() {
      Navigator.of(this.context).pop();
      Navigator.of(this.context).pop();
      _showToast("Berhasil Update Profil", Colors.blue);
    }).catchError((e) {
      print(e);
    });
  }

  void isPressed() {
    setState(() {
      tekan = false;
    });

    if (image == null) {
      Map<String, dynamic> datadalam = <String, dynamic>{
        "photoURL": _linkPhoto,
        "phoneNumber": _controlKontak.text,
        "email": _emailUser,
        "displayName": _controlName.text,
        "address": _controlAlamat.text
      };

      Map<String, dynamic> dataAwal = <String, dynamic>{
        "data": datadalam,
      };
      Firestore.instance
          .collection("users")
          .document("${widget.idAccount}")
          .updateData(dataAwal)
          .whenComplete(() {
        Navigator.of(this.context).pop();
        Navigator.of(this.context).pop();
        _showToast("Berhasil Update Profil", Colors.blue);
      }).catchError((e) {
        print(e);
      });
    } else {
      uploadImage();
    }
  }

  @override
  void initState() {
    _controlName.text = widget.namaUser;
    _controlKontak.text = widget.kontak == "Kosong" ? "" : widget.kontak;
    _controlAlamat.text = widget.alamat == "Kosong" ? "" : widget.alamat;

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
                                labelText: 'Nama Pemagang',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10.0),
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
                              controller: _controlKontak,
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
                              keyboardType: TextInputType.text,
                              decoration: new InputDecoration(
                                labelText: 'Alamat Pemagang',
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
