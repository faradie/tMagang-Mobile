import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:uuid/uuid.dart';

class BuatLowongan extends StatefulWidget {
  @override
  _BuatLowonganState createState() => _BuatLowonganState();
}

class _BuatLowonganState extends State<BuatLowongan> {
  String _judulLowongan, _jurusanLowongan, _require, _deskripsi, _idUser;
  int _kuota;
  DateTime _tglMulai, _tglAkhir;

  final _controlJudul = new TextEditingController();
  final _controlJurusan = new TextEditingController();
  final _controlKuota = new TextEditingController();
  final _controlRequir = new TextEditingController();
  final _controlDeskrip = new TextEditingController();

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
                      "SLA",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    new Text(
                      "Buat Lowongan",
                      textAlign: TextAlign.center,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 16.0),
                    new Text(
                      "1. ini text pertamadasdasdas asdasdasdasd asdasd\n2. Keduaasdasdasda sdasdasd\n3. Dan ini ketigaas dasdas dasd asdasdas\n4. asdas qweqweq dfsdf sdsg dfgdfgdfgdfg dfgdsdf asdasd ",
                      textAlign: TextAlign.justify,
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
                onChanged: (mli) => setState(() => _tglMulai = mli),
                format: DateFormat("EEEE, d MMMM yyyy - h:mm a"),
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(labelText: 'Tanggal Mulai'),
              ),
              DateTimePickerFormField(
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
                  onPressed: () {
                    if (_setuju == false) {
                      _showToast("Gagal buat Lowongan, No SLA", Colors.red);
                    } else {
                      if (dataSaveFire()) {
                        var uuid = new Uuid();
                        bool _isActiveIntern = true;
                        String _idNya = uuid.v4();
                        Map<String, dynamic> data = <String, dynamic>{
                          "judul": _judulLowongan,
                          "jurusan": _jurusanLowongan,
                          "kuota": _kuota,
                          "id": _idNya,
                          "tglUpload": new DateTime.now(),
                          "tglMulai": _tglMulai,
                          "tglBerakhir": _tglAkhir,
                          "isActiveIntern": _isActiveIntern,
                          "instansiPenyelenggara": _idUser,
                          "deskripsi": _deskripsi,
                          "requirement": _require.split(",")
                        };

                        Firestore.instance
                            .collection("vacancies")
                            .document("$_idNya")
                            .setData(data)
                            .whenComplete(() {
                          _showToast(
                              "Berhasil buat Lowongan", Colors.greenAccent);
                          print("ini data lowongan $data");
                          Navigator.of(context).pop();
                        }).catchError((e) {
                          print(e);
                        });
                      }
                    }
                  },
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
