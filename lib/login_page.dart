import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'auth.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginPage extends StatefulWidget {
  //construct
  LoginPage({this.auth, this.onSignedIn});
  final BaseAuth auth;
  final VoidCallback onSignedIn;
  @override
  _LoginPageState createState() => _LoginPageState();
}

enum FormType { login, register }

class _LoginPageState extends State<LoginPage> {
  final formKey = new GlobalKey<FormState>();

  String _email, _pass;
  FormType _formType = FormType.login;

  bool validateAndSave() {
    final form = formKey.currentState;
    if (form.validate()) {
      form.save();
      return true;
    }
    return false;
  }

// Future<void> _neverSatisfied() async {
//   return showDialog<void>(
//     context: context,
//     barrierDismissible: false, // user must tap button!
//     builder: (BuildContext context) {
//       return AlertDialog(
//         title: Text('Rewind and remember'),
//         content: SingleChildScrollView(
//           child: ListBody(
//             children: <Widget>[
//               Text('You will never be satisfied.'),
//               Text('You\’re like me. I’m never satisfied.'),
//             ],
//           ),
//         ),
//         actions: <Widget>[
//           FlatButton(
//             child: Text('Regret'),
//             onPressed: () {
//               Navigator.of(context).pop();
//             },
//           ),
//         ],
//       );
//     },
//   );
// }

  // void _showAlertWrongUser() {
  //   AlertDialog dialog = AlertDialog(
  //     content: new Text("Email / Pass tidak sesuai"),
  //   );

  //   showDialog(context: context, child: dialog);
  // }

  void _showToast(String pesan) {
    Fluttertoast.showToast(
      msg: pesan,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.CENTER,
      timeInSecForIos: 1,
      backgroundColor: Colors.red,
      textColor: Colors.white,
    );
  }

  Future<bool> checkUserAndNavigate(BuildContext context) async {
    return false;
  }

  void validateAndSubmit() async {
    if (validateAndSave()) {
      try {
        if (_formType == FormType.login) {
          FirebaseUser userId =
              await widget.auth.signInWithEmailAndPassword(_email, _pass);
          // FirebaseUser user = await FirebaseAuth.instance
          //   .signInWithEmailAndPassword(email: _email, password: _pass);
          // _showToast("Selamat datang");
          widget.onSignedIn();

          // if (!userId.isEmailVerified) {
          //   _showToast("Email belum diverifikasi");
          // } else {

          // }
          // if (userId.isEmailVerified) {

          // } else {

          // }
        } else {
          String userId =
              await widget.auth.createUserWithEmailAndPassword(_email, _pass);
          // FirebaseUser user = await FirebaseAuth.instance
          //   .signInWithEmailAndPassword(email: _email, password: _pass);
          print(userId);
        }
      } catch (e) {
        // _showToast(e.toString());
        print(e);
        // switch (e.code) {
        //   case '17009':

        //     break;
        //   default:
        // }
      }
    }
  }

  void moveToRegister() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.register;
    });
  }

  void moveToLogin() {
    formKey.currentState.reset();
    setState(() {
      _formType = FormType.login;
    });
  }

  var iconicon = [
    {
      "judul": "Informasi",
      "icon": Icons.info,
      "warna": Color(0xFF006885),
      "isi": "Ini isi dari inRformasi"
    },
    {
      "judul": "Peraturan",
      "icon": Icons.power_input,
      "warna": Color(0xFF006885),
      "isi": "Ini isi dari Peraturan"
    },
    {
      "judul": "Tata Cara",
      "icon": Icons.settings,
      "warna": Color(0xFF006885),
      "isi": "Ini isi dari Tata Cara"
    },
    {
      "judul": "Benefit",
      "icon": Icons.file_download,
      "warna": Color(0xFF006885),
      "isi": "Ini isi dari Benefit"
    },
  ];

  List<Container> listMyWidgets() {
    List<Container> list = new List();
    for (var i = 0; i < iconicon.length; i++) {
      final data = iconicon[i];
      final String judulpakai = data["judul"];
      final Color warnapakai = data["warna"];
      final IconData iconpakai = data["icon"];
      final String isipakai = data["isi"];

      list.add(Container(
        child: Column(
          children: <Widget>[
            new Hero(
              tag: judulpakai,
              child: new Material(
                color: Colors.transparent,
                child: new InkWell(
                  onTap: () => Navigator.of(context).push(new MaterialPageRoute(
                        builder: (BuildContext context) => new Detail(
                              judulDetail: judulpakai,
                              iconDetail: iconpakai,
                              warnaDetail: warnapakai,
                              isiDetail: isipakai,
                            ),
                      )),
                  child: Container(
                      padding: const EdgeInsets.all(7.0),
                      decoration: new BoxDecoration(
                        shape: BoxShape
                            .circle, // You can use like this way or like the below line
                        //borderRadius: new BorderRadius.circular(30.0),
                        color: warnapakai,
                      ),
                      child: Icon(
                        iconpakai,
                        color: Colors.white,
                      )),
                ),
              ),
            ),
            Text(judulpakai)
          ],
        ),
      ));
    }
    return list;
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light.copyWith(
      statusBarColor: Color(0xFFef5e2d), //or set color with: Color(0xFF0000FF)
    ));
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      body: Container(
        decoration: BoxDecoration(
            image: DecorationImage(
                image: AssetImage('img/background.png'), fit: BoxFit.fitWidth)),
        child: Container(
          // color: Colors.red,
          decoration: BoxDecoration(
              gradient: LinearGradient(
                  colors: [
                Color.fromRGBO(0, 0, 0, 0),
                Color.fromRGBO(255, 221, 255, 0.3),
              ],
                  begin: FractionalOffset.topCenter,
                  end: FractionalOffset.bottomCenter)),
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: <Widget>[
              ListView(
                children: <Widget>[
                  Container(
                    child: Row(
                      children: <Widget>[
                        Padding(
                          padding: const EdgeInsets.only(left: 20.0),
                        ),
                        new Image.asset(
                          'img/logoDoang.png',
                          width: 200.0,
                        ),
                      ],
                    ),
                    height: 60.0,
                    color: Color(0xFFe87c55),
                  ),
                  Container(
                    height: 20.0,
                    color: const Color(0xFF006885),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                  ),
                  Container(
                    // padding: const EdgeInsets.only(
                    //     bottom: 20.0, top: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: listMyWidgets(),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(25.0),
                    child: new Form(
                      key: formKey,
                      child: Theme(
                        data: new ThemeData(
                            brightness: Brightness.light,
                            primarySwatch: Colors.cyan,
                            inputDecorationTheme: new InputDecorationTheme(
                                labelStyle: new TextStyle(
                              // color: const Color(0xFFE59B1A),
                              fontSize: 20.0,
                            ))),
                        child: new Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: buildInputs() + buildSubmitBtn(),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              FlatButton(
                onPressed: null,
                child: Text(
                  "Tempatmagang.com Beta v1.0",
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFF006885),
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildInputs() {
    if (_formType == FormType.login) {
      return [
        new TextFormField(
          onSaved: (value) => _email = value,
          validator: (value) => value.isEmpty ? 'Isikan Email dahulu' : null,
          keyboardType: TextInputType.emailAddress,
          decoration: new InputDecoration(
              labelText: 'Email',
              // labelStyle: TextStyle(color: Color(0xFFEAC324)),
              suffixIcon: Icon(
                Icons.email,
                color: Color(0xFF006885),
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
        ),
        new TextFormField(
          onSaved: (value) => _pass = value,
          validator: (value) => value.isEmpty ? 'Isikan Password dahulu' : null,
          obscureText: true,
          keyboardType: TextInputType.text,
          decoration: new InputDecoration(
              labelText: 'Password',
              // labelStyle: TextStyle(color: Color(0xFFEAC324)),
              suffixIcon: Icon(
                Icons.lock,
                color: Color(0xFF006885),
              )),
        ),
      ];
    } else {
      return [
        new TextFormField(
          onSaved: (value) => _email = value,
          validator: (value) => value.isEmpty ? 'Isikan Email dahulu' : null,
          keyboardType: TextInputType.emailAddress,
          decoration: new InputDecoration(
              labelText: 'Email',
              // labelStyle: TextStyle(color: Color(0xFFEAC324)),
              suffixIcon: Icon(
                Icons.email,
                color: Color(0xFFEAC324),
              )),
        ),
        Padding(
          padding: const EdgeInsets.all(5.0),
        ),
        new TextFormField(
          onSaved: (value) => _pass = value,
          validator: (value) => value.isEmpty ? 'Isikan Password dahulu' : null,
          obscureText: true,
          keyboardType: TextInputType.text,
          decoration: new InputDecoration(
              labelText: 'Password',
              // labelStyle: TextStyle(color: Color(0xFFEAC324)),
              suffixIcon: Icon(
                Icons.lock,
                color: Color(0xFF3f51b5),
              )),
        ),
      ];
    }
  }

  List<Widget> buildSubmitBtn() {
    if (_formType == FormType.login) {
      return [
        Padding(
          padding: const EdgeInsets.all(20.0),
        ),
        ButtonTheme(
          minWidth: 200.0,
          height: 60.0,
          child: new RaisedButton(
            color: const Color(0xFFff9977),
            elevation: 4.0,
            splashColor: Colors.blueGrey,
            onPressed: validateAndSubmit,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            padding: const EdgeInsets.only(),
            child: new Text(
              'Masuk'.toUpperCase(),
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                onPressed: () {},
                child: Text(
                  "lupa password?",
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFFEAC324),
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5),
                ),
              ),
              FlatButton(
                onPressed: moveToRegister,
                child: Text(
                  "buat akun",
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFFEAC324),
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ),
      ];
    } else {
      return [
        Padding(
          padding: const EdgeInsets.all(20.0),
        ),
        ButtonTheme(
          minWidth: 200.0,
          height: 60.0,
          child: new RaisedButton(
            color: const Color(0xFFE59B1A),
            elevation: 4.0,
            splashColor: Colors.blueGrey,
            onPressed: validateAndSubmit,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            padding: const EdgeInsets.only(),
            child: new Text(
              'Buat Akun'.toUpperCase(),
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(10.0),
        ),
        Container(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              FlatButton(
                onPressed: () {},
                child: Text(
                  "lupa password?",
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFFEAC324),
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5),
                ),
              ),
              FlatButton(
                onPressed: moveToLogin,
                child: Text(
                  "Masuk",
                  style: TextStyle(
                      fontSize: 12.0,
                      color: Color(0xFFEAC324),
                      fontWeight: FontWeight.w300,
                      letterSpacing: 0.5),
                ),
              ),
            ],
          ),
        ),
      ];
    }
  }
}

class Detail extends StatelessWidget {
  Detail({this.judulDetail, this.iconDetail, this.isiDetail, this.warnaDetail});

  final String judulDetail, isiDetail;
  final IconData iconDetail;
  final Color warnaDetail;

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      body: new ListView(
        children: <Widget>[
          new Container(
            color: warnaDetail,
            height: 80.0,
            child: new Hero(
              tag: judulDetail,
              child: new Material(
                child: new InkWell(
                  child: new Container(
                    color: warnaDetail,
                    child: new Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          new Icon(
                            iconDetail,
                            color: Colors.white,
                          ),
                          new Text(
                            judulDetail.toUpperCase(),
                            style:
                                TextStyle(color: Colors.white, fontSize: 20.0),
                          ),
                          new Icon(
                            iconDetail,
                            color: Colors.white,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
