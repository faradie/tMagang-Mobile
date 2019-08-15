import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

final loadingLoad = CircularProgressIndicator(
  backgroundColor: Colors.deepOrange,
  strokeWidth: 1.5,
);

class AgencyCreateVacancies extends StatefulWidget {
  AgencyCreateVacancies({this.id});
  final String id;
  @override
  _AgencyCreateVacanciesState createState() => _AgencyCreateVacanciesState();
}

class _AgencyCreateVacanciesState extends State<AgencyCreateVacancies> {
  String _judulLowongan,
      _jurusanLowongan,
      _require,
      _deskripsi,
      _tmpMentor,
      _tmpJurusan,
      _jurusan;
  int _kuota, _expiredAt;
  bool tekan = true;
  DateTime _tglMulai, _tglAkhir;
  List<String> selectedList = [];

  static const itemJurusan = <String>[
    'informatika',
    'ilmu komputer',
    'sistem informasi',
    'kedokteran',
    'akutansi',
    'keuangan',
    'ekonomi',
    'administrasi',
    'jurnalistik',
    'psikologi',
    'antropologi',
    'hubungan internasional',
    'hubungan masyarakat',
    'statistika',
    'astronomi',
    'biokimia',
    'mikrobiologi',
    'fisika',
    'matematika',
    'geofisika',
    'biologi',
    'sastra',
    'pariwisata',
    'manajemen logistik',
    'peternakan',
    'kehutanan',
    'agroteknologi',
    'pertanian',
    'perikanan',
    'manajemen bisnis',
    'desain interior',
    'tata boga',
    'desain produk',
    'dkv',
    'animasi',
    'pertambangan',
    'kelautan',
    'lingkungan',
    'metalurgi',
    'sipil',
    'arsitektur',
    'geodesi',
    'elektro',
    'mesin',
    'industri',
    'perkapalan',
    'planologi',
    'penerbangan',
    'nuklir',
    'geologi',
    'otomotif',
    'bioproses',
    'grafika',
    'material',
    'kimia',
    'fisika',
    'geomatika',
    'perminyakan',
    'alat berat',
    'sistem perkapalan',
    'perpipaan'
  ];

  final List<DropdownMenuItem<String>> _dropdownJurusan = itemJurusan
      .map((String value) => DropdownMenuItem<String>(
            value: value,
            child: new Text(value.toUpperCase()),
          ))
      .toList();

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

  void _createVacancies() {
    if (_setuju == false) {
      _showToast("Gagal buat Lowongan, No SLA", Colors.red);
    } else {
      if (dataSaveFire()) {
        if (_tmpMentor == null || _tmpMentor == "kosong") {
          _showToast("Tetapkan mentor terlebih dahulu", Colors.red);
        } else {
          if (selectedList.length == 0) {
            _showToast("Pilih jurusan terlebih dahulu", Colors.red);
          } else {
            final difference = _tglAkhir.difference(_tglMulai).inHours;
            if (difference > 0) {
              setState(() {
                tekan = false;
              });

              var uuid = new Uuid();
              bool _isActiveIntern = true;
              String _idNya = uuid.v4();
              var today = new DateTime.now();

              var col = _controlRequir.text.toLowerCase().split(",");
              col.removeWhere((item) => item.length == 0);

              // var jur = _controlJurusan.text.toLowerCase().split(",");
              // jur.removeWhere((item) => item.length == 0);

              var _validUntil = today.add(new Duration(days: _expiredAt - 1));
              Map<String, dynamic> data = <String, dynamic>{
                "title": _controlJudul.text,
                "department": selectedList,
                "SLA": _setuju,
                "quota": int.parse(_controlKuota.text),
                "id": _idNya,
                "createdAt": new DateTime.now(),
                "timeStartIntern": _tglMulai,
                "timeEndIntern": _tglAkhir,
                "isActiveIntern": _isActiveIntern,
                "ownerAgency": widget.id,
                "description": _controlDeskrip.text,
                "requirement": col,
                "expiredAt": _validUntil,
                "mentorId": _tmpMentor
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
            } else {
              _showToast("Periode magang tidak sesuai", Colors.red);
            }
          }
        }
      }
    }
  }

  @override
  void initState() {
    super.initState();
    print("ini widgetID ${widget.id}");
    Future.delayed(Duration.zero, () => showAlert(context));
  }

  static const menutItem = <String>['kosong'];
  final List<DropdownMenuItem<String>> _dropDownJenisKel = menutItem
      .map((String value) => DropdownMenuItem<String>(
            value: value,
            child: new Text("Belum ada Mentor"),
          ))
      .toList();

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

  // Show some different formats.
  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    InputType.date: DateFormat('yyyy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };

  // Changeable in demo
  InputType inputType = InputType.date;
  bool editable = true;

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
              SizedBox(height: 16.0),
              new Divider(),
              SizedBox(height: 16.0),
              new Text(
                _jurusan == null ? "Silahkan pilih jurusan" : _jurusan.toUpperCase(),
                style: TextStyle(color: Colors.grey),
              ),
              _jurusan == null
                  ? Container()
                  : new RaisedButton(
                      color: const Color(0xFFff9977),
                      child: new Text("Ulangi"),
                      onPressed: () {
                        setState(() {
                          _jurusan = null;
                          selectedList.clear();
                        });
                      },
                    ),
              Container(
                margin:
                    const EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                    new Text("Jurusan : "),
                    new DropdownButton<String>(
                      value: _tmpJurusan,
                      onChanged: (String nilaiBaru) {
                        setState(() {
                          _tmpJurusan = nilaiBaru;
                          selectedList.add(nilaiBaru);
                          _jurusan = selectedList.toString();
                        });
                      },
                      items: this._dropdownJurusan,
                    ),
                  ],
                ),
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
              new StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('users')
                      .where('data.agencyId', isEqualTo: widget.id)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            loadingLoad,
                            Text("Loading Data..")
                          ],
                        ),
                      );
                    } else {
                      return new Container(
                        child: new Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            new Text(
                                "Total ${snapshot.data.documents.length} Mentor tersedia: "),
                            new DropdownButton<String>(
                              value: _tmpMentor,
                              isDense: true,
                              onChanged: (String newValue) {
                                setState(() {
                                  _tmpMentor = newValue;
                                });
                              },
                              items: snapshot.data.documents.length > 0
                                  ? snapshot.data.documents
                                      .map((DocumentSnapshot document) {
                                      var wew = document.data['data'];
                                      return new DropdownMenuItem<String>(
                                          value: document.data['uid'] == null
                                              ? ""
                                              : document.data['uid'],
                                          child: new Container(
                                            child: new Text(
                                              wew['displayName'] == null
                                                  ? ""
                                                  : wew['displayName'],
                                            ),
                                          ));
                                    }).toList()
                                  : this._dropDownJenisKel,
                            ),
                          ],
                        ),
                      );
                    }
                  }),
              new Divider(),
              SizedBox(height: 16.0),
              new Text("Periode :"),

              DateTimePickerFormField(
                controller: _controlTglMulai,
                inputType: inputType,
                format: formats[inputType],
                editable: editable,
                decoration: InputDecoration(
                    labelText: 'Tanggal Mulai', hasFloatingPlaceholder: false),
                onChanged: (mli) => setState(() => _tglMulai = mli),
              ),
              DateTimePickerFormField(
                controller: _controlTglAkhir,
                inputType: inputType,
                format: formats[inputType],
                editable: editable,
                decoration: InputDecoration(
                    labelText: 'Tanggal Berakhir',
                    hasFloatingPlaceholder: false),
                onChanged: (akhr) => setState(() => _tglAkhir = akhr),
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
                  onPressed: tekan == true ? _createVacancies : null,
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
