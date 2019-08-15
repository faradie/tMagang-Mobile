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

class AddMentor extends StatefulWidget {
  AddMentor({this.idAgency});
  final String idAgency;
  @override
  _AddMentorState createState() => _AddMentorState();
}

class _AddMentorState extends State<AddMentor> {
  final formKeySave = new GlobalKey<FormState>();
  final _controlEmail = new TextEditingController();
  final _controlNomorMentor = new TextEditingController();
  String _emailMentor, _mentorNumber;
  bool dataSaveFire() {
    final form = formKeySave.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

  bool tekan = true;

  void _inviteMentor() {
    if (_controlEmail.text == "" || _controlNomorMentor.text == "") {
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
          "agencyId": widget.idAgency,
          "createdAt": today,
          "dataId": _idNya,
          "email": _controlEmail.text,
          "employeeIDNumber": _controlNomorMentor.text,
          "status": 1
        };

        Firestore.instance
            .collection("mentor-invitation-link")
            .document("$_idNya")
            .setData(data)
            .whenComplete(() {
          _showToast("Berhasil undang Mentor", Colors.greenAccent);
          print("ini data lowongan $data");
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
        title: new Text("Undang Mentor"),
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
                onSaved: (value) => _emailMentor = value,
                validator: (value) =>
                    value.isEmpty ? 'Isikan Email dahulu' : null,
                keyboardType: TextInputType.emailAddress,
                decoration: new InputDecoration(
                    labelText: 'Email Mentor', icon: new Icon(Icons.email)),
              ),
              SizedBox(height: 16.0),
              new Divider(),
              new TextFormField(
                controller: _controlNomorMentor,
                onSaved: (value) => _mentorNumber = value,
                validator: (value) =>
                    value.isEmpty ? 'Isikan Nomor karyawan dahulu' : null,
                keyboardType: TextInputType.text,
                decoration: new InputDecoration(
                    labelText: 'Nomor Karyawan',
                    icon: new Icon(Icons.person_pin)),
              ),
              SizedBox(height: 16.0),
              ButtonTheme(
                minWidth: 200.0,
                height: 60.0,
                child: new RaisedButton(
                  color: const Color(0xFFff9977),
                  elevation: 4.0,
                  splashColor: Colors.blueGrey,
                  onPressed: tekan == true ? _inviteMentor : null,
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
