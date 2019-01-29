import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as Img;

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
      _linkPhoto,
      _about,
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
          _linkPhoto = name["photoURL"];
          _about = name["about"];
          _jurusan = name["department"];
          _isActive = data.documents[0].data['isActive'] == true
              ? "Magang"
              : "Tidak Magang";
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
                              about: _about == null ? "Kosong" : _about,
                              idMhs: widget.id,
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
                            : _linkPhoto == ""
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
                            "Tentang saya",
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          new Text(_about == null ? "Kosong" : _about)
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
      this.namaUser,
      this.nimUser,
      this.jenisKelamin,
      this.kontak,
      this.alamat,
      this.idMhs,
      this.about,
      this.skills});
  final String namaUser,
      nimUser,
      jenisKelamin,
      kontak,
      alamat,
      jurusan,
      about,
      idMhs,
      kampus,
      status;
  final List<String> skills;
  _EditProfilState createState() => _EditProfilState();
}

class _EditProfilState extends State<EditProfil> {
  final TextEditingController _controlName = new TextEditingController();
  final TextEditingController _controlNIM = new TextEditingController();
  final TextEditingController _controlKontak = new TextEditingController();
  final TextEditingController _controlAlamat = new TextEditingController();
  final TextEditingController _controlSkills = new TextEditingController();
  final TextEditingController _controlAbout = new TextEditingController();
  final formKeySave = new GlobalKey<FormState>();
  String _namaUser, _emailUser, _collegeID, _tmpJenisKelamin, _linkPhoto;
  var name;
  bool tekan = true;
  bool _addSkill = false;

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
          _emailUser = name["email"];
          _linkPhoto = name["photoURL"];
          _collegeID = name["collegeId"];
          _addSkill = name["addSkill"] == null ? false : name["addSkill"];
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
        Firestore.instance.collection('users').document("${widget.idMhs}");
    Firestore.instance.runTransaction((Transaction tx) async {
      DocumentSnapshot postSnapshot = await tx.get(favoritesReference);
      if (postSnapshot.exists) {
        await tx.update(favoritesReference, <String, dynamic>{
          'data': {
            "about": _controlAbout.text,
            "studentIDNumber": _controlNIM.text,
            "skills": _controlSkills.text == "Skill belum diatur"
                ? null
                : _controlSkills.text.toLowerCase().split(","),
            "photoURL": url,
            "phoneNumber": _controlKontak.text,
            "addSkill": true,
            "gender": _tmpJenisKelamin,
            "email": _emailUser,
            "displayName": _controlName.text,
            "collegeId": _collegeID,
            "department": widget.jurusan,
            "address": _controlAlamat.text
          }
        });
      } else {}
    }).then((hasil) {
      Navigator.of(this.context).pop();
      Navigator.of(this.context).pop();
      _showToast("Berhasil Update Profil", Colors.blue);
    });
  }

  void isPressed() {
    setState(() {
      tekan = false;
    });

    if (image == null) {
      DocumentReference favoritesReference =
          Firestore.instance.collection('users').document("${widget.idMhs}");
      Firestore.instance.runTransaction((Transaction tx) async {
        DocumentSnapshot postSnapshot = await tx.get(favoritesReference);
        if (postSnapshot.exists) {
          await tx.update(favoritesReference, <String, dynamic>{
            'data': {
              "about": _controlAbout.text,
              "studentIDNumber": _controlNIM.text,
              "skills": _controlSkills.text == "Skill belum diatur"
                  ? null
                  : _controlSkills.text.toLowerCase().split(","),
              "photoURL": _linkPhoto,
              "phoneNumber": _controlKontak.text,
              "addSkill": true,
              "gender": _tmpJenisKelamin,
              "email": _emailUser,
              "displayName": _controlName.text,
              "collegeId": _collegeID,
              "department": widget.jurusan,
              "address": _controlAlamat.text
            }
          });
        } else {}
      }).then((hasil) {
        //perbaiki lagi
        Navigator.of(this.context).pop();
        Navigator.of(this.context).pop();
        _showToast("Berhasil Update Profil", Colors.blue);
      });
    } else {
      uploadImage();
    }
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
    _controlAbout.text = widget.about == "Kosong" ? "" : widget.about;
    String s = widget.skills.join(',');
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
                                  : _linkPhoto == ""
                                      ? new CircleAvatar(
                                          radius: 40.0,
                                          backgroundColor:
                                              const Color(0xFFe87c55),
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
                                          backgroundImage:
                                              NetworkImage(_linkPhoto),
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
                      SizedBox(height: 16.0),
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
                          children: _addSkill == false
                              ? <Widget>[
                                  new TextFormField(
                                    controller: _controlSkills,
                                    keyboardType: TextInputType.text,
                                    decoration: new InputDecoration(
                                      labelText: 'Skill Pemagang',
                                    ),
                                  )
                                ]
                              : <Widget>[
                                  new Text(
                                    "Skills",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: Container(
                                        height: 25.0,
                                        color: Colors.transparent,
                                        child: Requir(
                                          req: widget.skills == null
                                              ? ["Silahkan lengkapi data"]
                                              : widget.skills,
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
