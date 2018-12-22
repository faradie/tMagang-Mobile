import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
// import 'package:flutter_html_view/flutter_html_view.dart';

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
  var _emailLoginController = TextEditingController();
  var _passLoginController = TextEditingController();
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

  @override
  void initState() {
    super.initState();
    _emailLoginController = TextEditingController(text: _email);
    _passLoginController = TextEditingController(text: _pass);
  }

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
        if (e.toString() ==
            "PlatformException(exception, The email address is badly formatted., null)") {
          _showToast("Email / Password salah");
        } else if (e.toString() ==
            "PlatformException(error, Given String is empty or null, null)") {
          _showToast("Lengkapi form terlebih dahulu");
        } else {
          _showToast(e.toString());
        }
      }
    }
  }

  void notSubmit() {}

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
      "isi":
          "1. <b>Tempatmagang</b> adalah fasilitas yang mempertemukan antara pencari magang dengan penyedia magang.\n2. Tempatmagang merupakan aplikasi yang memfasilitasi peraturan kementerian tenaga kerja dan transmigrasi No. 36 tahun 2016 tentang penyelenggaraan pemagangan dalam negeri."
    },
    {
      "judul": "Peraturan",
      "icon": Icons.power_input,
      "warna": Color(0xFF006885),
      "isi":
          "1. Untuk dapat menggunakan aplikasi Tempatmagang, institusi Pendidikan anda harus terdaftar di aplikasi Tempatmagang. Untuk keterangan kerjasama dapat menghubungi support@tempatmagang.com\n2. Untuk mendaftar sebagai penyedia magang, silahkan menghubungi client support kami di support@tempatmagang.com"
    },
    {
      "judul": "Tata Cara",
      "icon": Icons.settings,
      "warna": Color(0xFF006885),
      "isi":
          "1. Identitas pemagang adalah identitas resmi yang diberikan oleh institusi pendidikan asal calon peserta magang.\n2. Informasi lowongan magang bersifat umum, namun ada beberapa fitur yang kami sediakan untuk dapat mengoptimalkan pencarian tempat magang yang ideal sesuai dengan kompetensi pemagang dan kebutuhan penyedia magang."
    },
    {
      "judul": "Benefit",
      "icon": Icons.file_download,
      "warna": Color(0xFF006885),
      "isi":
          "1. Dengan menjadi anggota tempat magang, anda akan mendapatkan informasi, memilih dan direkomendasikan untuk lowongan magang yang sesuai dengan kompetensi ataupun kebutuhan dari penyedia magang.\n2. Kemudahan pengelolaan informasi magang bagi penyedia magang.\n3. Kemudahan penelusuran dan pencarian magang bagi institusi pendidikan.\n4. Report dan feedback sebagai pemagang ataupun penyedia magang"
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
      // resizeToAvoidBottomPadding: false,
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
                  Padding(
                    padding: const EdgeInsets.only(top: 100.0),
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 5.0, right: 5.0),
                    child: new Divider(
                      color: Color(0xFF006885),
                    ),
                  ),
                  FlatButton(
                    onPressed: () {},
                    child: Text(
                      "Tempatmagang.com Beta v1.0",
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Color(0xFF006885),
                        fontWeight: FontWeight.w300,
                      ),
                    ),
                  ),
                ],
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
        new TextField(
          controller: _emailLoginController,
          onChanged: (value) => value == null ? _email = null : _email = value,
          // validator: (value) => value.isEmpty ? 'Isikan Email dahulu' : null,
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
        new TextField(
          controller: _passLoginController,
          onChanged: (value) => value == null ? _pass = null : _pass = value,
          // validator: (value) => value.isEmpty ? 'Isikan Password dahulu' : null,
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
          // validator: (value) => value.isEmpty ? 'Isikan Email dahulu' : null,
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
          // validator: (value) => value.isEmpty ? 'Isikan Password dahulu' : null,
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
            onPressed: _emailLoginController.text.trim() == "" ||
                    _passLoginController.text.trim() == ""
                ? null
                : validateAndSubmit,
            shape: new RoundedRectangleBorder(
                borderRadius: new BorderRadius.circular(30.0)),
            padding: const EdgeInsets.only(),
            child: new Text(
              'Masuk'.toUpperCase(),
              style: TextStyle(fontSize: 20.0, color: Colors.white),
            ),
          ),
        ),
        // Padding(
        //   padding: const EdgeInsets.all(10.0),
        // ),
        // Container(
        //   child: Row(
        //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        //     children: <Widget>[
        //       FlatButton(
        //         onPressed: () {},
        //         child: Text(
        //           "lupa password?",
        //           style: TextStyle(
        //               fontSize: 12.0,
        //               color: Color(0xFFEAC324),
        //               fontWeight: FontWeight.w300,
        //               letterSpacing: 0.5),
        //         ),
        //       ),
        //       FlatButton(
        //         onPressed: moveToRegister,
        //         child: Text(
        //           "buat akun",
        //           style: TextStyle(
        //               fontSize: 12.0,
        //               color: Color(0xFFEAC324),
        //               fontWeight: FontWeight.w300,
        //               letterSpacing: 0.5),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
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
          new Scrollbar(
            child: new SingleChildScrollView(
                scrollDirection: Axis.vertical,
                reverse: true,
                child: Card(
                  margin: const EdgeInsets.all(10.0),
                  child: new Container(
                      padding: const EdgeInsets.all(10.0),
                      child: new Text("wew")),
                )),
          ),
        ],
      ),
    );
  }
}
