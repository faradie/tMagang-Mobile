import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class InstansiBuatLowongan extends StatefulWidget {
  @override
  _InstansiBuatLowonganState createState() => _InstansiBuatLowonganState();
}

class _InstansiBuatLowonganState extends State<InstansiBuatLowongan> {
  String _judulLowongan, _jurusanLowongan, _require, _deskripsi, _idUser;
  int _kuota, _expiredAt;
  bool tekan = true;
  DateTime _tglMulai, _tglAkhir;

  final _controlJudul = new TextEditingController();
  final _controlJurusan = new TextEditingController();
  final _controlKuota = new TextEditingController();
  final _controlRequir = new TextEditingController();
  final _controlDeskrip = new TextEditingController();
  final _controlTglMulai = new TextEditingController();
  final _controlTglAkhir = new TextEditingController();
  final _controlExpiredAt = new TextEditingController();

  bool _setuju = false;
  final formKeySave = new GlobalKey<FormState>();

  bool dataSaveFire() {
    final form = formKeySave.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _inPressed() {
    if (_setuju == false) {
      _showToast("Gagal buat Lowongan, No SLA", Colors.red);
    } else {
      if (dataSaveFire()) {
        setState(() {
          tekan = false;
        });
        var uuid = new Uuid();
        bool _isActiveIntern = true;
        String _idNya = uuid.v4();
        var today = new DateTime.now();

        var _validUntil = today.add(new Duration(days: _expiredAt - 1));
        Map<String, dynamic> data = <String, dynamic>{
          "SLA": _setuju,
          "title": _controlJudul.text,
          "departement": _controlJurusan.text,
          "quota": int.parse(_controlKuota.text),
          "id": _idNya,
          "createdAt": new DateTime.now(),
          "timeStartIntern": _tglMulai,
          "timeEndIntern": _tglAkhir,
          "isActiveIntern": _isActiveIntern,
          "ownerAgency": _idUser,
          "description": _controlDeskrip.text,
          "requirement": _controlRequir.text.toLowerCase().split(","),
          "expiredAt": _validUntil
        };

        Firestore.instance
            .collection("vacancies")
            .document("$_idNya")
            .setData(data)
            .whenComplete(() {
          _showToast("Berhasil buat Lowongan", Colors.greenAccent);
          print("ini data lowongan $data");
          setState(() {
            tekan = true;
          });
          Navigator.of(context).pop();
        }).catchError((e) {
          print(e);
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    getDataUser();
    Future.delayed(Duration.zero, () => showAlert(context));
  }

  Future getDataUser() async {
    var user = await FirebaseAuth.instance.currentUser();
    _idUser = user.uid;
  }

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

  void showAlert(BuildContext context) {
    showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) => AlertDialog(
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
                      "PERHATIAN",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    new Text(
                      "Aturan Pembuatan Lowongan",
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
                                  new Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, left: 8.0, right: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          new Text(
                                            "1. ",
                                            style: TextStyle(fontSize: 17.0),
                                          ),
                                          SizedBox(height: 10.0),
                                          new Expanded(
                                            child: new Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                new Text(
                                                  "Urutan pada requirement menentukan bobot prioritas.",
                                                  textAlign: TextAlign.justify,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  new Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, left: 8.0, right: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          new Text("2. "),
                                          SizedBox(height: 10.0),
                                          new Expanded(
                                            child: new Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                new Text(
                                                  "Lama terlihat lowongan adalah dihitung sejak lowongan itu diterbitkan. Minimal 1 hari dan maksimal 60 hari.",
                                                  textAlign: TextAlign.justify,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  new Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, left: 8.0, right: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          new Text("3. "),
                                          SizedBox(height: 10.0),
                                          new Expanded(
                                            child: new Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                new Text(
                                                  "Lowongan yang telah expired tidak dapat diperpanjang.",
                                                  textAlign: TextAlign.justify,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  new Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, left: 8.0, right: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          new Text("4. "),
                                          SizedBox(height: 10.0),
                                          new Expanded(
                                            child: new Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                new Text(
                                                  "Lowongan yang telah dibuka akan dapat diakses oleh keseluruhan pemagang.",
                                                  textAlign: TextAlign.justify,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  new Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, left: 8.0, right: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          new Text("5. "),
                                          SizedBox(height: 10.0),
                                          new Expanded(
                                            child: new Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                new Text(
                                                  "Pengajuan pemagang terhadap lowongan akan direview terlebih dahulu oleh penyedia.",
                                                  textAlign: TextAlign.justify,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  new Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, left: 8.0, right: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          new Text("6. "),
                                          SizedBox(height: 10.0),
                                          new Expanded(
                                            child: new Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                new Text(
                                                  "Lowongan yang telah terbit tidak dapat dibatalkan.",
                                                  textAlign: TextAlign.justify,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  new Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, left: 8.0, right: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          new Text("7. "),
                                          SizedBox(height: 10.0),
                                          new Expanded(
                                            child: new Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                new Text(
                                                  "Penyedia lowongan akan dapat menerima calon peserta magang ketika masa lowongan telah berakhir.",
                                                  textAlign: TextAlign.justify,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
                                  new Container(
                                      padding: const EdgeInsets.only(
                                          bottom: 8.0, left: 8.0, right: 8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: <Widget>[
                                          new Text("8. "),
                                          SizedBox(height: 10.0),
                                          new Expanded(
                                            child: new Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: <Widget>[
                                                new Text(
                                                  "Penyedia berkewajiban menindak lanjuti pengajuan yang diajukan oleh pemagang.",
                                                  textAlign: TextAlign.justify,
                                                )
                                              ],
                                            ),
                                          ),
                                        ],
                                      )),
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
                              Navigator.of(context).pop();
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
                            onPressed: () {
                              Navigator.of(context).pop();
                              _setuju = true;
                            },
                            padding: const EdgeInsets.only(),
                            child: new Text(
                              'Setuju'.toUpperCase(),
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          elevation:
              defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
          backgroundColor: const Color(0xFFe87c55),
          title: new Text("Buat lowongan baru"),
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
          margin: const EdgeInsets.all(10.0),
          child: Form(
            key: formKeySave,
            child: ListView(children: <Widget>[
              new TextFormField(
                controller: _controlJudul,
                onSaved: (value) => _judulLowongan = value,
                validator: (value) =>
                    value.isEmpty ? 'Isikan Judul dahulu' : null,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                    labelText: 'Judul Lowongan',
                    icon: new Icon(Icons.card_travel)),
              ),
              new TextFormField(
                controller: _controlJurusan,
                onSaved: (value) => _jurusanLowongan = value,
                validator: (value) =>
                    value.isEmpty ? 'Isikan Jurusan dahulu' : null,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                    labelText: 'Jurusan Lowongan yang dibutuhkan',
                    icon: new Icon(Icons.account_balance_wallet)),
              ),
              new TextFormField(
                controller: _controlKuota,
                onSaved: (value) => _kuota = int.parse(value),
                validator: (value) =>
                    value.isEmpty ? 'Isikan Kuota dahulu' : null,
                keyboardType: TextInputType.number,
                decoration: new InputDecoration(
                    labelText: 'Kuota Lowongan',
                    icon: new Icon(Icons.looks_one)),
              ),
              new TextFormField(
                controller: _controlExpiredAt,
                onSaved: (value) => _expiredAt = int.parse(value),
                validator: (value) => value.isEmpty
                    ? 'Isikan Masa Lowongan dahulu'
                    : int.parse(value) < 1
                        ? 'Batasan 1-60'
                        : int.parse(value) > 60 ? 'Batasan 1-60' : null,
                keyboardType: TextInputType.number,
                decoration: new InputDecoration(
                    labelText: 'Berapa hari Lowongan dapat diakses?',
                    icon: new Icon(Icons.date_range)),
              ),
              // Container(
              //   child: Row(
              //     children: <Widget>[tglMulai, tglAkhir],
              //   ),
              // )

              SizedBox(height: 16.0),
              new Divider(),
              SizedBox(height: 16.0),
              new Text("Periode :"),
              DateTimePickerFormField(
                controller: _controlTglMulai,
                onChanged: (mli) => setState(() => _tglMulai = mli),
                format: DateFormat("EEEE, d MMMM yyyy - h:mm a"),
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(labelText: 'Tanggal Mulai'),
              ),
              DateTimePickerFormField(
                controller: _controlTglAkhir,
                onChanged: (akhr) => setState(() => _tglAkhir = akhr),
                format: DateFormat("EEEE, d MMMM yyyy - h:mm a"),
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(labelText: 'Tanggal Berakhir'),
              ),
              SizedBox(height: 16.0),
              new Divider(),
              SizedBox(height: 16.0),
              new Text(
                "Dipisahkan dengan tanda koma ( , ) :",
                style: TextStyle(color: Colors.grey),
              ),
              new TextFormField(
                controller: _controlRequir,
                onSaved: (value) => _require = value,
                validator: (value) =>
                    value.isEmpty ? 'Isikan requirement' : null,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                  labelText: 'Requirement',
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
                        controller: _controlDeskrip,
                        onSaved: (value) => _deskripsi = value,
                        validator: (value) =>
                            value.isEmpty ? 'Isikan Deskripsi' : null,
                        keyboardType: TextInputType.multiline,
                        maxLines: null,
                        decoration: new InputDecoration(
                          border: new OutlineInputBorder(
                              borderRadius: const BorderRadius.all(
                            const Radius.circular(10.0),
                          )),
                          labelText: 'Deskripsi Lowongan',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16.0),
              ButtonTheme(
                minWidth: 200.0,
                height: 60.0,
                child: new RaisedButton(
                  color: const Color(0xFFff9977),
                  elevation: 4.0,
                  splashColor: Colors.blueGrey,
                  onPressed: tekan == true ? _inPressed : null,
                  padding: const EdgeInsets.only(),
                  child: new Text(
                    'Terbitkan'.toUpperCase(),
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                ),
              ),

              SizedBox(height: 16.0),
            ]),
          ),
        ));
  }
}
