import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class InstansiProfil extends StatefulWidget {
  _InstansiProfilState createState() => _InstansiProfilState();
}

class _InstansiProfilState extends State<InstansiProfil> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        backgroundColor: const Color(0xFFe87c55),
        title: new Text("Profil Pemagang"),
        leading: InkWell(
          onTap: () {
            Navigator.of(context).pop();
          },
          child: new Icon(
            Icons.chevron_left,
            color: Colors.white,
          ),
        ),
        actions: <Widget>[
          new FlatButton(
            child: new Icon(Icons.settings, color: Colors.white),
            onPressed: () {
              Navigator.of(context).push(new MaterialPageRoute(
                builder: (BuildContext context) => new EditProfilInstansi(),
              ));
            },
          )
        ],
      ),
    );
  }
}

class EditProfilInstansi extends StatefulWidget {
  _EditProfilInstansiState createState() => _EditProfilInstansiState();
}

class _EditProfilInstansiState extends State<EditProfilInstansi> {
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
        title: new Text("data"),
      ),
    );
  }
}
