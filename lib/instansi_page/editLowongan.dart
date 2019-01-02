import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

class EditLowongan extends StatefulWidget {
  EditLowongan({this.idLowongan});
  final String idLowongan;
  _EditLowonganState createState() => _EditLowonganState();
}

class _EditLowonganState extends State<EditLowongan> {
  String _judulLowongan, _jurusanLowongan, _deskripsi, _idUser;
  List<dynamic> _require;
  int _kuota;
  bool tekan = true;
  Timestamp _tglMulai, _tglAkhir;
  final formKeySave = new GlobalKey<FormState>();
  final _controlJudul = new TextEditingController();
  final _controlJurusan = new TextEditingController();
  final _controlKuota = new TextEditingController();
  final _controlRequir = new TextEditingController();
  final _controlDeskrip = new TextEditingController();
  final _controlTglMulai = new TextEditingController();
  final _controlTglAkhir = new TextEditingController();
  final _controlExpiredAt = new TextEditingController();
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

  bool dataSaveFire() {
    final form = formKeySave.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  void _inPressed() {
    setState(() {
      tekan = false;
    });
    if (dataSaveFire()) {
      Map<String, dynamic> data = <String, dynamic>{
        "title": _controlJudul.text,
        "departement": _controlJurusan.text,
        "quota": int.parse(_controlKuota.text),
        "timeStartIntern": _tglMulai,
        "timeEndIntern": _tglAkhir,
        "requirement": _controlRequir.text.split(","),
        "description": _controlDeskrip.text
      };

      Firestore.instance
          .collection("vacancies")
          .document("${widget.idLowongan}")
          .updateData(data)
          .whenComplete(() {
        Navigator.of(this.context).pop();
        Navigator.of(this.context).pop();
        _showToast("Berhasil Update Lowongan", Colors.blue);
      }).catchError((e) {
        print(e);
      });
    }
  }

  Future getDataLowongan() async {
    var firestore = Firestore.instance;
    var userQuery = firestore
        .collection('vacancies')
        .where('id', isEqualTo: widget.idLowongan)
        .limit(1);

    userQuery.getDocuments().then((data) {
      if (data.documents.length > 0) {
        setState(() {
          _judulLowongan = data.documents[0].data['title'];
          _jurusanLowongan = data.documents[0].data['departement'];
          _deskripsi = data.documents[0].data['description'];
          _kuota = data.documents[0].data['quota'];
          _tglMulai = data.documents[0].data['timeStartIntern'];
          _tglAkhir = data.documents[0].data['timeEndIntern'];
          _require = data.documents[0].data['requirement'];
        });
        print("kuota $_kuota");
        _controlJudul.text = _judulLowongan == null ? "" : _judulLowongan;
        _controlJurusan.text = _jurusanLowongan == null ? "" : _jurusanLowongan;
        _controlKuota.text = _kuota.toString() == null ? "" : _kuota.toString();
        _controlTglMulai.text = _tglMulai.toDate().toString() == null
            ? ""
            : _tglMulai.toDate().toString();
        _controlTglAkhir.text = _tglAkhir.toDate().toString() == null
            ? ""
            : _tglAkhir.toDate().toString();
        String s = _require.join(',');
        _controlRequir.text = s;
        _controlDeskrip.text = _deskripsi == null ? "" : _deskripsi;
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getDataLowongan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // resizeToAvoidBottomPadding: false,
        appBar: AppBar(
          elevation:
              defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
          backgroundColor: const Color(0xFFe87c55),
          title: new Text("Edit Lowongan"),
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
              SizedBox(height: 16.0),
              new Divider(),
              SizedBox(height: 16.0),
              new Text("Periode :"),
              DateTimePickerFormField(
                controller: _controlTglMulai,
                onChanged: (mli) =>
                    setState(() => _tglMulai = Timestamp.fromDate(mli)),
                format: DateFormat("EEEE, d MMMM yyyy - h:mm a"),
                keyboardType: TextInputType.datetime,
                decoration: InputDecoration(labelText: 'Tanggal Mulai'),
              ),
              DateTimePickerFormField(
                controller: _controlTglAkhir,
                onChanged: (akhr) =>
                    setState(() => _tglAkhir = Timestamp.fromDate(akhr)),
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
                onSaved: (value) => _require = List.from(value.split(",")),
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
                    'Perbarui'.toUpperCase(),
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
