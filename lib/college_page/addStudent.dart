import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:uuid/uuid.dart';

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

class AddStudent extends StatefulWidget {
  AddStudent({this.idCollege});
  final String idCollege;
  @override
  _AddStudentState createState() => _AddStudentState();
}

class _AddStudentState extends State<AddStudent> {
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

  final formKeySave = new GlobalKey<FormState>();
  final _controlEmail = new TextEditingController();
  final _controlNomorStudent = new TextEditingController();
  String _emailStudent, _studentNumber, _tmpJurusan;
  bool dataSaveFire() {
    final form = formKeySave.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  bool tekan = true;

  void _inviteStudent() {
    if (_controlEmail.text == "" ||
        _controlNomorStudent.text == "" ||
        _tmpJurusan == null ||
        _tmpJurusan == "") {
      _showToast("Lengkapi data terlebih dahulu", Colors.red);
    } else {
      if (dataSaveFire()) {
        setState(() {
          tekan = false;
        });
        var uuid = new Uuid();
        String _idNya = uuid.v4();
        var today = new DateTime.now();

        Map<String, dynamic> data = <String, dynamic>{
          "collegeId": widget.idCollege,
          "createdAt": today,
          "dataId": _idNya,
          "department": _tmpJurusan,
          "email": _controlEmail.text,
          "studentIDNumber": _controlNomorStudent.text,
          "status": 1
        };

        Firestore.instance
            .collection("intern-invitation-link")
            .document("$_idNya")
            .setData(data)
            .whenComplete(() {
          _showToast("Berhasil undang Mahasiswa", Colors.greenAccent);
          Navigator.of(context).pop();
          setState(() {
            tekan = true;
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        backgroundColor: const Color(0xFFe87c55),
        title: new Text("Undang Mahasiswa"),
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
      body: Container(
        margin: const EdgeInsets.all(10.0),
        child: Form(
          key: formKeySave,
          child: ListView(
            children: <Widget>[
              new TextFormField(
                controller: _controlEmail,
                onSaved: (value) => _emailStudent = value,
                validator: (value) =>
                    value.isEmpty ? 'Isikan Email dahulu' : null,
                keyboardType: TextInputType.emailAddress,
                decoration: new InputDecoration(
                    labelText: 'Email Mahasiswa', icon: new Icon(Icons.email)),
              ),
              SizedBox(height: 16.0),
              new Divider(),
              new TextFormField(
                controller: _controlNomorStudent,
                onSaved: (value) => _studentNumber = value,
                validator: (value) =>
                    value.isEmpty ? 'Isikan Nomor Mahasiswa dahulu' : null,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                    labelText: 'Nomor Mahasiswa',
                    icon: new Icon(Icons.person_pin)),
              ),
              SizedBox(height: 16.0),
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
                        });
                      },
                      items: this._dropdownJurusan,
                    ),
                  ],
                ),
              ),
              ButtonTheme(
                minWidth: 200.0,
                height: 60.0,
                child: new RaisedButton(
                  color: const Color(0xFFff9977),
                  elevation: 4.0,
                  splashColor: Colors.blueGrey,
                  onPressed: tekan == true ? _inviteStudent : null,
                  padding: const EdgeInsets.only(),
                  child: new Text(
                    'Undang'.toUpperCase(),
                    style: TextStyle(fontSize: 20.0, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
