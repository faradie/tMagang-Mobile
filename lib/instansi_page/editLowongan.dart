import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

final loadingLoad = CircularProgressIndicator(
  backgroundColor: Colors.deepOrange,
  strokeWidth: 1.5,
);

class EditLowongan extends StatefulWidget {
  EditLowongan(
      {this.idLowongan,
      this.requireNya,
      this.deskripNya,
      this.idOwner,
      this.jurusanNya,
      this.kuotaNya,
      this.startNya,
      this.akhirNya,
      this.judulLowonganNya});
  final String idLowongan, judulLowonganNya, kuotaNya, deskripNya, idOwner;
  final Timestamp startNya, akhirNya;
  final List jurusanNya, requireNya;
  _EditLowonganState createState() => _EditLowonganState();
}

class _EditLowonganState extends State<EditLowongan> {
  String _tmpMentor;
  Timestamp _tglMulai, _tglAkhir;
  bool tekan = true;
  InputType inputType = InputType.date;
  // Show some different formats.
  final formats = {
    InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
    InputType.date: DateFormat('yyyy-MM-dd'),
    InputType.time: DateFormat("HH:mm"),
  };
  final formKeySave = new GlobalKey<FormState>();
  final _controlJudul = new TextEditingController();
  final _controlJurusan = new TextEditingController();
  final _controlKuota = new TextEditingController();
  final _controlRequir = new TextEditingController();
  final _controlDeskrip = new TextEditingController();
  final _controlTglMulai = new TextEditingController();
  final _controlTglAkhir = new TextEditingController();
  List<dynamic> dummy = ["Posisi Jurusan belum diatur"];
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
    if (dataSaveFire()) {
      if (_tmpMentor == null || _tmpMentor == "kosong") {
        _showToast("Tetapkan mentor terlebih dahulu", Colors.red);
      } else {
        final difference = widget.akhirNya
            .toDate()
            .difference(widget.startNya.toDate())
            .inHours;
        if (difference > 0) {
          setState(() {
            tekan = false;
          });
          var col = _controlRequir.text.toLowerCase().split(",");
          col.removeWhere((item) => item.length == 0);

          var jur = _controlJurusan.text.toLowerCase().split(",");
          jur.removeWhere((item) => item.length == 0);
          Map<String, dynamic> data = <String, dynamic>{
            "title": _controlJudul.text,
            "department": List.from(_controlJurusan.text.split(",")),
            "quota": int.parse(_controlKuota.text),
            "timeStartIntern": _tglMulai,
            "timeEndIntern": _tglAkhir,
            "requirement": col,
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
        } else {
          _showToast("Periode magang tidak sesuai", Colors.red);
        }
      }
    }
  }

  static const menutItem = <String>['kosong'];
  final List<DropdownMenuItem<String>> _dropDownJenisKel = menutItem
      .map((String value) => DropdownMenuItem<String>(
            value: value,
            child: new Text("Belum ada Mentor"),
          ))
      .toList();
  @override
  void initState() {
    super.initState();
    String jurs = widget.jurusanNya.join(',');
    _controlJudul.text =
        widget.judulLowonganNya == null ? "" : widget.judulLowonganNya;
    _controlJurusan.text = jurs;
    _controlKuota.text = widget.kuotaNya;
    _controlTglMulai.text = widget.startNya.toDate().toString() == null
        ? ""
        : widget.startNya.toDate().toString();
    _controlTglAkhir.text = widget.akhirNya.toDate().toString() == null
        ? ""
        : widget.akhirNya.toDate().toString();
    String s = widget.requireNya.join(',');
    _controlRequir.text = s;
    _controlDeskrip.text = widget.deskripNya == null ? "" : widget.deskripNya;
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
            child: ListView(
              children: <Widget>[
                new TextFormField(
                  controller: _controlJudul,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                      labelText: 'Judul Lowongan',
                      icon: new Icon(Icons.card_travel)),
                ),
                SizedBox(height: 16.0),
                new Divider(),
                SizedBox(height: 16.0),
                new Text(
                  "Jurusan dipisahkan dengan tanda koma ( , ) :",
                  style: TextStyle(color: Colors.grey),
                ),
                new TextFormField(
                  controller: _controlJurusan,
                  keyboardType: TextInputType.text,
                  decoration: new InputDecoration(
                      labelText: 'Jurusan Lowongan yang dibutuhkan',
                      icon: new Icon(Icons.account_balance_wallet)),
                ),
                new TextFormField(
                  controller: _controlKuota,
                  keyboardType: TextInputType.number,
                  decoration: new InputDecoration(
                      labelText: 'Kuota Lowongan',
                      icon: new Icon(Icons.looks_one)),
                ),
                SizedBox(height: 16.0),
                new Divider(),
                new StreamBuilder<QuerySnapshot>(
                  stream: Firestore.instance
                      .collection('users')
                      .where('data.agencyId', isEqualTo: widget.idOwner)
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
                  },
                ),
                SizedBox(height: 16.0),
                new Divider(),
                SizedBox(height: 16.0),
                new Text("Periode :"),
                DateTimePickerFormField(
                  controller: _controlTglMulai,
                  inputType: inputType,
                  onChanged: (mli) =>
                      setState(() => _tglMulai = Timestamp.fromDate(mli)),
                  format: formats[inputType],
                  decoration: InputDecoration(labelText: 'Tanggal Mulai'),
                ),
                DateTimePickerFormField(
                  controller: _controlTglAkhir,
                  onChanged: (akhr) =>
                      setState(() => _tglAkhir = Timestamp.fromDate(akhr)),
                  format: formats[inputType],
                  inputType: inputType,
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
              ],
            ),
          ),
        ));
  }
}
