// import 'package:cloud_functions/cloud_functions.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class CreateIntern extends StatefulWidget {
  @override
  _CreateInternState createState() => _CreateInternState();
}

class _CreateInternState extends State<CreateIntern> {
  final _controlEmail = new TextEditingController();
  final _controlPassword = new TextEditingController();
  final _controlConfirmPass = new TextEditingController();
  final _controlNoTelp = new TextEditingController();
  final _controlNamaPemagang = new TextEditingController();
  final formKeySave = new GlobalKey<FormState>();

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
                      "Tambah Pemagang",
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

  // void callCloudFunction() async {
  //   try {
  //     final result = await CloudFunctions.instance
  //         .call(functionName: 'createUser', parameters: <String, dynamic>{
  //       'password': '12345678987',
  //       'email': 'm.alfin04@gmail.com',
  //       'phoneNumber': '08623184123',
  //       'displayName': 'andaGad',
  //     });
  //     print('Result: $result');
  //   } catch (e) {
  //     print('Error: $e');
  //   }
  // }

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

    Future.delayed(Duration.zero, () => showAlert(context));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        backgroundColor: const Color(0xFFe87c55),
        title: new Text("Tambah Pemagang"),
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
              controller: _controlEmail,
              validator: (_controlEmail) =>
                  _controlEmail.isEmpty ? 'Isikan Email dahulu' : null,
              keyboardType: TextInputType.emailAddress,
              decoration: new InputDecoration(
                  labelText: 'Email Pemagang',
                  icon: new Icon(Icons.card_travel)),
            ),
            new TextFormField(
              controller: _controlPassword,
              obscureText: true,
              validator: (_controlPassword) =>
                  _controlPassword.isEmpty ? 'Isikan Password dahulu' : null,
              keyboardType: TextInputType.text,
              decoration: new InputDecoration(
                  labelText: 'Password',
                  icon: new Icon(Icons.account_balance_wallet)),
            ),
            new TextFormField(
              controller: _controlConfirmPass,
              obscureText: true,
              validator: (_controlConfirmPass) => _controlConfirmPass.isEmpty
                  ? 'Isikan Konfirmasi Password dahulu'
                  : null,
              keyboardType: TextInputType.text,
              decoration: new InputDecoration(
                  labelText: 'Konfirmasi Password',
                  icon: new Icon(Icons.looks_one)),
            ),
            new TextFormField(
              controller: _controlNoTelp,
              validator: (_controlNoTelp) =>
                  _controlNoTelp.isEmpty ? 'Isikan No Telp dahulu' : null,
              keyboardType: TextInputType.number,
              decoration: new InputDecoration(
                  labelText: 'Nomor Telepon', icon: new Icon(Icons.looks_one)),
            ),
            new TextFormField(
              controller: _controlNamaPemagang,
              validator: (_controlNamaPemagang) =>
                  _controlNamaPemagang.isEmpty ? 'Isikan Nama dahulu' : null,
              keyboardType: TextInputType.text,
              decoration: new InputDecoration(
                  labelText: 'Nama Pemagang', icon: new Icon(Icons.looks_one)),
            ),
            // Container(
            //   child: Row(
            //     children: <Widget>[tglMulai, tglAkhir],
            //   ),
            // )
            SizedBox(height: 16.0),
            ButtonTheme(
              minWidth: 200.0,
              height: 60.0,
              child: new FlatButton(
                color: const Color(0xFFff9977),
                splashColor: Colors.blueGrey,
                onPressed: () {
                  if (dataSaveFire()) {
                    // callCloudFunction();
                  }
                },
                padding: const EdgeInsets.only(),
                child: new Text(
                  'Daftarkan'.toUpperCase(),
                  style: TextStyle(fontSize: 20.0, color: Colors.white),
                ),
              ),
            ),

            SizedBox(height: 16.0),
          ]),
        ),
      ),
    );
  }
}
