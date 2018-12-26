import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class InstansiData extends StatefulWidget {
  _InstansiDataState createState() => _InstansiDataState();
}

class _InstansiDataState extends State<InstansiData> {
  Future _getInstansi() async {
    var firestore = Firestore.instance;
    Stream<QuerySnapshot> qn = firestore
        .collection('users')
        .where('role', isEqualTo: 'agency')
        .snapshots();
    return qn;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: defaultTargetPlatform == TargetPlatform.android ? 5.0 : 0.0,
        backgroundColor: const Color(0xFFe87c55),
        title: new Text("Data Instansi"),
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
            child: new Icon(Icons.add, color: Colors.white),
            onPressed: () {},
          )
        ],
      ),
      body: new Container(
        margin: const EdgeInsets.all(10.0),
        child: new FutureBuilder(
          future: _getInstansi(),
          builder: (_, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: Text("Mengambil Data.."),
              );
            } else {
              return ListView.builder(
                  itemCount: 5,
                  itemBuilder: (_, index) {
                    return ListTile(
                      title: Text("Data Instansi"),
                      leading: new Icon(Icons.star),
                      onTap: () {},
                    );
                  });
            }
          },
        ),
      ),
    );
  }
}
